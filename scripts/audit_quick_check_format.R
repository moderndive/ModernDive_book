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
#   2. A `Show answer` callout-tip follows the options.
#   3. The callout opens with `**(X)**` where X is one of `a`/`b`/`c`/`d` —
#      this `**(X)**` marker IS the correctness indicator (options themselves
#      are NOT bolded in this book's convention).
#
# Exits non-zero on any structural violation.

suppressPackageStartupMessages({
  library(stringr)
})

# Resolve the book root from this script's own location (scripts/..), with an
# env-var override; a hardcoded absolute path broke whenever the repo moved.
book <- Sys.getenv("MODERNDIVE_BOOK_DIR", unset = NA)
if (is.na(book)) {
  args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  book <- if (length(args)) dirname(dirname(normalizePath(sub("^--file=", "", args[1])))) else "."
}
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
  q_idx <- grep("^\\*\\*Q[0-9]+-[0-9]+\\.\\*\\*", qc_block)
  if (!length(q_idx)) next

  for (qi in seq_along(q_idx)) {
    total_qcs <- total_qcs + 1
    qn <- str_match(qc_block[q_idx[qi]], "^\\*\\*Q[0-9]+-([0-9]+)\\.")[1, 2]
    s <- q_idx[qi]
    e <- if (qi < length(q_idx)) q_idx[qi + 1] - 1 else length(qc_block)
    block <- qc_block[s:e]

    # Find option lines (a. / b. / c. / d.) and the answer callout.
    # The book's convention: options are plain (NOT bolded) — the correctness
    # indicator is the `**(X)**` marker at the start of the Show-answer callout.
    opt_re <- "^([a-d])\\.\\s+(.+)$"
    opt_lines <- grep(opt_re, block)
    opt_letters <- character()
    for (j in opt_lines) {
      m <- str_match(block[j], opt_re)
      opt_letters <- c(opt_letters, m[1, 2])
    }

    # Check 1: exactly 4 options in order a, b, c, d
    if (!identical(opt_letters, c("a", "b", "c", "d"))) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: expected options a/b/c/d in order, got [%s]",
        f, qn, paste(opt_letters, collapse = "/")))
      next
    }
    # Check 2: Show-answer callout follows
    callout_idx <- grep("^::: \\{\\.callout-tip[^}]*title=\"Show answer\"", block)
    if (!length(callout_idx)) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: missing `Show answer` callout-tip", f, qn))
      next
    }
    # Check 3: callout opens with **(X)** where X is one of a/b/c/d
    callout_start <- callout_idx[1]
    callout_body <- block[(callout_start + 1):min(callout_start + 3, length(block))]
    answer_marker <- str_match(callout_body[1], "^\\*\\*\\(([a-d])\\)\\*\\*")[1, 2]
    if (is.na(answer_marker)) {
      errors <- c(errors, sprintf(
        "[%s] Q%s: Show-answer callout doesn't start with **(a/b/c/d)** marker",
        f, qn))
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
