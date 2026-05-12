#!/usr/bin/env Rscript
# Quick check (QC) format validator.
#
# For each chapter qmd, finds the `## Quick checks` section and verifies
# that every `**QN.** ...` stem follows this canonical structure:
#
#   **QN.** <stem text>
#
#   a. Option A
#   b. Option B
#   c. **Option C** (correct answer wrapped in **bold**)
#   d. Option D
#
#   ::: {.callout-tip collapse="true" title="Show answer"}
#   **(c)** Explanation referencing the correct option.
#   :::
#
# Checks per question:
#   1. Has exactly 4 options, labeled `a.`, `b.`, `c.`, `d.` (in order).
#   2. Exactly one option contains bold (**...**) text — the correct answer.
#   3. A `Show answer` callout-tip follows the options.
#   4. The callout opens with `**(X)**` where X matches the bolded option.
#
# Exits non-zero on any structural violation.

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

qmd_files <- list.files(".", pattern = "^[0-9]+-.*\\.qmd$")
qmd_files <- sort(qmd_files)

errors <- character()
total_qcs <- 0

for (f in qmd_files) {
  lines <- readLines(f, warn = FALSE)
  # Find the Quick checks section
  qc_start <- which(grepl("^## Quick checks", lines))
  if (!length(qc_start)) next
  qc_start <- qc_start[1]
  # End at next h2 or end of file
  next_h2 <- which(grepl("^## ", lines) & seq_along(lines) > qc_start)
  qc_end <- if (length(next_h2)) next_h2[1] - 1 else length(lines)
  qc_block <- lines[qc_start:qc_end]

  # Locate every **Qn.** stem
  q_idx <- grep("^\\*\\*Q[0-9]+\\.\\*\\*", qc_block)
  if (!length(q_idx)) next

  for (qi in seq_along(q_idx)) {
    total_qcs <- total_qcs + 1
    qn <- str_match(qc_block[q_idx[qi]], "^\\*\\*Q([0-9]+)\\.")[1, 2]
    s <- q_idx[qi]
    e <- if (qi < length(q_idx)) q_idx[qi + 1] - 1 else length(qc_block)
    block <- qc_block[s:e]

    # Find option lines (a. / b. / c. / d.) and the answer callout
    opt_re <- "^([a-d])\\.\\s+(.+)$"
    opt_lines <- grep(opt_re, block)
    opt_letters <- character()
    bolded_letter <- character()
    for (j in opt_lines) {
      m <- str_match(block[j], opt_re)
      letter <- m[1, 2]
      content <- m[1, 3]
      opt_letters <- c(opt_letters, letter)
      if (grepl("\\*\\*[^*]+\\*\\*", content)) bolded_letter <- c(bolded_letter, letter)
    }

    # Check 1: exactly 4 options in order a, b, c, d
    if (!identical(opt_letters, c("a", "b", "c", "d"))) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: expected options a/b/c/d in order, got [%s]",
        f, qn, paste(opt_letters, collapse = "/")))
      next
    }
    # Check 2: exactly one bolded option
    if (length(bolded_letter) != 1) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: expected exactly one bolded (correct) option, found %d (%s)",
        f, qn, length(bolded_letter),
        if (length(bolded_letter) > 0) paste(bolded_letter, collapse = "/") else "none"))
      next
    }
    # Check 3: Show-answer callout follows
    callout_idx <- grep("^::: \\{\\.callout-tip[^}]*title=\"Show answer\"", block)
    if (!length(callout_idx)) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: missing `Show answer` callout-tip", f, qn))
      next
    }
    # Check 4: callout opens with **(X)** matching bolded option
    callout_start <- callout_idx[1]
    callout_body <- block[(callout_start + 1):min(callout_start + 3, length(block))]
    answer_marker <- str_match(callout_body[1], "^\\*\\*\\(([a-d])\\)\\*\\*")[1, 2]
    if (is.na(answer_marker) || answer_marker != bolded_letter) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: callout opens with **%s** but bolded option was (%s)",
        f, qn,
        if (is.na(answer_marker)) "(no marker)" else paste0("(", answer_marker, ")"),
        bolded_letter))
    }
  }
}

cat(sprintf("Scanned %d Quick check questions across %d chapter files.\n",
            total_qcs, length(qmd_files)))
cat(sprintf("Format violations: %d\n\n", length(errors)))

if (length(errors)) {
  for (e in errors) cat("  ", e, "\n", sep = "")
  quit(status = 1)
}
cat("All Quick checks pass format validation.\n")
