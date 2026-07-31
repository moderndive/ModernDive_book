#!/usr/bin/env Rscript
# Cross-reference & navigation scans for ModernDive.
#
# Scan 7: Dead anchors — every `@sec-X` / `@fig-X` / `@tbl-X` reference resolves
#         to a label that actually exists somewhere in the book.
# Scan 8: Stale forward refs — list every "we'll see in Chapter N" / "in @sec-X"
#         forward-pointing prose sentence so the author can spot-check that the
#         target chapter still contains the promised material.
# Scan 9: Glossary coverage — every bolded vocabulary term in chapter prose has
#         a glossary entry (or is in an explicit allowlist of non-vocabulary
#         bolding like `**Note**`, `**Q1.**`, `**(b)**`, etc.).

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

qmd_files <- list.files(".", pattern = "\\.qmd$", full.names = FALSE)
qmd_files <- sort(qmd_files)
chap_lines <- lapply(qmd_files, function(f) readLines(f, warn = FALSE))
names(chap_lines) <- qmd_files

# --- Helper: classify each line as prose vs code/fence (same as prior scans) ---
classify_lines <- function(lines) {
  in_chunk <- FALSE
  state <- character(length(lines))
  for (i in seq_along(lines)) {
    l <- lines[i]
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; state[i] <- "fence" }
    else if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; state[i] <- "fence" }
    else if (in_chunk) state[i] <- "code"
    else state[i] <- "prose"
  }
  state
}
chap_state <- lapply(chap_lines, classify_lines)
names(chap_state) <- qmd_files

# --- Helper: extract chunk labels (give us implicit fig/tbl anchors) ---
chunk_label <- function(line) {
  m <- str_match(line, "^```\\{(?:r|webr-r)\\s+([A-Za-z0-9_-]+)")
  if (is.na(m[1, 2])) NA_character_ else m[1, 2]
}

# --- Build complete anchor inventory ---
# An anchor exists if:
#   (a) An explicit `{#name}` appears anywhere
#   (b) A chunk label like `fig-X`, `tbl-X` is declared (Quarto auto-creates @fig-X / @tbl-X)
all_anchors <- character()
anchor_origin <- list()  # anchor -> (file, line)

for (f in qmd_files) {
  lines <- chap_lines[[f]]
  for (i in seq_along(lines)) {
    # Explicit anchors
    matches <- str_extract_all(lines[i], "\\{#([a-zA-Z0-9_:.-]+)")[[1]]
    for (m in matches) {
      anc <- sub("^\\{#", "", m)
      anc <- sub("[.]+$", "", anc)
      if (!(anc %in% all_anchors)) {
        all_anchors <- c(all_anchors, anc)
        anchor_origin[[anc]] <- list(file = f, line = i)
      }
    }
    # Chunk labels — register as fig-X / tbl-X auto-anchors
    lab <- chunk_label(lines[i])
    if (!is.na(lab) && (grepl("^fig-", lab) || grepl("^tbl-", lab))) {
      if (!(lab %in% all_anchors)) {
        all_anchors <- c(all_anchors, lab)
        anchor_origin[[lab]] <- list(file = f, line = i)
      }
    }
  }
}

cat(sprintf("Anchor inventory: %d unique labels across %d files\n\n",
            length(all_anchors), length(qmd_files)))

# ============================================================
# SCAN 7: Dead anchors
# ============================================================
cat("========== SCAN 7: DEAD ANCHORS ==========\n")
cat("Every @sec-* / @fig-* / @tbl-* reference must resolve to an anchor.\n\n")

# Strip HTML comments (single-line `<!-- ... -->` and multi-line spans) from a
# copy of the lines used for *reference* scanning. References inside a comment
# don't render and shouldn't be flagged.
strip_html_comments <- function(lines) {
  in_comment <- FALSE
  out <- lines
  for (i in seq_along(out)) {
    if (in_comment) {
      if (grepl("-->", out[i])) {
        out[i] <- sub("^.*?-->", "", out[i])
        in_comment <- FALSE
      } else {
        out[i] <- ""
      }
    }
    if (!in_comment) {
      # Strip any single-line comments
      out[i] <- gsub("<!--.*?-->", "", out[i])
      # If a `<!--` starts but no `-->` on this line, mark in_comment
      if (grepl("<!--", out[i])) {
        out[i] <- sub("<!--.*$", "", out[i])
        in_comment <- TRUE
      }
    }
  }
  out
}

dead_refs <- list()
ref_total <- 0

for (f in qmd_files) {
  lines <- strip_html_comments(chap_lines[[f]])
  for (i in seq_along(lines)) {
    refs <- str_extract_all(lines[i], "@(sec-[A-Za-z0-9_-]+|fig-[A-Za-z0-9_-]+|tbl-[A-Za-z0-9_-]+)")[[1]]
    if (!length(refs)) next
    for (r in refs) {
      ref_total <- ref_total + 1
      anc <- sub("^@", "", r)
      # Strip trailing punctuation/hyphens (en-dash ranges like sec-X--sec-Y
      # absorb the trailing `--` into the captured anchor)
      anc <- sub("-+$", "", sub("[.]+$", "", anc))
      if (!(anc %in% all_anchors)) {
        snippet <- substr(trimws(lines[i]), 1, 160)
        dead_refs[[length(dead_refs) + 1]] <- list(
          file = f, line = i, anchor = anc, raw = r, context = snippet
        )
      }
    }
  }
}

cat(sprintf("Total cross-references scanned: %d\n", ref_total))
cat(sprintf("Dead references found: %d\n\n", length(dead_refs)))

if (length(dead_refs)) {
  by_file <- split(dead_refs, sapply(dead_refs, function(x) x$file))
  for (f in names(by_file)) {
    cat(sprintf("  [%s]\n", f))
    for (d in by_file[[f]]) {
      cat(sprintf("    L%-5d @%s -- not found\n      %s\n",
                  d$line, d$anchor, d$context))
    }
  }
}

# ============================================================
# SCAN 8: Stale forward refs
# ============================================================
cat("\n\n========== SCAN 8: STALE FORWARD-REFERENCE PROSE ==========\n")
cat("List forward-pointing prose sentences for spot-check verification.\n")
cat("Each entry shows the source location, the promise, and what's at the target.\n\n")

# Quick chapter-number lookup from filename
file_to_chap_num <- function(f) {
  m <- str_match(f, "^([0-9]+)")
  if (is.na(m[1, 2])) NA_integer_ else as.integer(m[1, 2])
}

# Map @sec-X -> file (so we can show target chapter for each forward ref)
anchor_to_file <- function(anc) {
  o <- anchor_origin[[anc]]
  if (is.null(o)) NA_character_ else o$file
}

# Forward-ref detection: look for "we'll see ... @sec-X" / "in Chapter N" /
# "in the upcoming @sec-X" / "in @sec-X" type prose
forward_patterns <- c(
  "we'?ll see",
  "we'?ll cover",
  "we'?ll explore",
  "we'?ll revisit",
  "we'?ll learn",
  "we'?ll discuss",
  "we'?ll formalize",
  "we'?ll formally",
  "you'?ll see",
  "you'?ll learn",
  "you'?ll meet",
  "in the upcoming",
  "in upcoming",
  "in a later (chapter|section)",
  "in @sec-",
  "in Chapter [0-9]+",
  "see @sec-",
  "Starting (with|in)",
  "preview of",
  "covered in",
  "discussed in",
  "introduced in",
  "formally (defined|introduced|covered) in",
  "is the subject of",
  "is the topic of"
)
forward_re <- paste0("(?i)", paste(forward_patterns, collapse = "|"))

forward_refs <- list()
for (f in qmd_files) {
  lines  <- chap_lines[[f]]
  states <- chap_state[[f]]
  src_chap <- file_to_chap_num(f)
  for (i in seq_along(lines)) {
    if (states[i] != "prose") next
    if (!grepl(forward_re, lines[i], perl = TRUE)) next
    # Extract any @sec-X / @fig-X / @tbl-X refs on this line
    refs <- str_extract_all(lines[i], "@(sec-[A-Za-z0-9_-]+|fig-[A-Za-z0-9_-]+|tbl-[A-Za-z0-9_-]+)")[[1]]
    chapnum_refs <- str_extract_all(lines[i], "Chapter [0-9]+")[[1]]
    refs <- c(refs, chapnum_refs)
    if (!length(refs)) next
    # Determine if any reference points forward (target chapter > source chapter)
    forward_targets <- character()
    for (r in refs) {
      if (grepl("^@", r)) {
        anc <- sub("[.]+$", "", sub("^@", "", r))
        target_file <- anchor_to_file(anc)
        if (is.na(target_file)) next
        target_chap <- file_to_chap_num(target_file)
        if (!is.na(src_chap) && !is.na(target_chap) && target_chap > src_chap) {
          forward_targets <- c(forward_targets, sprintf("%s -> Ch %d", r, target_chap))
        }
      } else if (grepl("^Chapter ", r)) {
        n <- as.integer(sub("^Chapter ", "", r))
        if (!is.na(src_chap) && !is.na(n) && n > src_chap) {
          forward_targets <- c(forward_targets, sprintf("%s -> Ch %d", r, n))
        }
      }
    }
    if (length(forward_targets)) {
      forward_refs[[length(forward_refs) + 1]] <- list(
        file = f, line = i, targets = forward_targets, context = lines[i]
      )
    }
  }
}

cat(sprintf("Forward-pointing prose sentences found: %d\n\n", length(forward_refs)))
if (length(forward_refs)) {
  by_file <- split(forward_refs, sapply(forward_refs, function(x) x$file))
  for (f in names(by_file)) {
    cat(sprintf("  [%s]\n", f))
    for (fr in by_file[[f]]) {
      snippet <- substr(trimws(gsub("\\s+", " ", fr$context)), 1, 200)
      cat(sprintf("    L%-5d (-> %s)\n      %s\n",
                  fr$line, paste(fr$targets, collapse = ", "), snippet))
    }
  }
}

# ============================================================
# SCAN 9: Glossary coverage
# ============================================================
cat("\n\n========== SCAN 9: GLOSSARY COVERAGE ==========\n")
cat("Every bolded vocabulary term in chapter prose should have a glossary entry.\n")
cat("Filtered: structural bolding (Q1., (b), Solution, Note:, etc.) and short tokens.\n\n")

# Load glossary terms (titles) AND key in-body terms (emphasized via `**bold**`
# inside an entry body — those are explicit cross-references like "biased",
# "unbiased", "two-sided" mentioned within Estimator / Alternative hypothesis).
gloss_lines <- readLines("96-glossary.qmd", warn = FALSE)
gloss_text <- paste(gloss_lines, collapse = "\n")
entries <- str_match_all(
  gloss_text,
  "##\\s+([^\\n{]+?)\\s*\\{#sec-gloss-[^}]+\\}([^#]*?)(?=\\n##\\s|$)"
)[[1]]
glossary_terms <- if (length(entries) > 0) trimws(entries[, 2]) else character()
glossary_bodies <- if (length(entries) > 0) entries[, 3] else character()
# Normalize titles for matching
norm_glossary <- tolower(gsub("\\s*\\(.*$", "", glossary_terms))
norm_glossary <- gsub("`", "", norm_glossary)
norm_glossary <- trimws(norm_glossary)
# Extract bolded AND italicized cross-reference terms from glossary entry
# bodies and add them to the lookup set. By convention the glossary uses
# *italic* for cross-references to other glossary entries (e.g., the Estimator
# entry says "an estimator is *unbiased* if..." — that italic term is an
# implicit alias for the Estimator entry).
gloss_body_bold <- unique(unlist(lapply(glossary_bodies, function(b) {
  bold <- str_match_all(b, "\\*\\*([^*]{2,40})\\*\\*")[[1]]
  ital <- str_match_all(b, "(?<!\\*)\\*([^*\\n]{2,40}?)\\*(?!\\*)")[[1]]
  out <- character()
  if (nrow(bold) > 0) out <- c(out, bold[, 2])
  if (nrow(ital) > 0) out <- c(out, ital[, 2])
  tolower(gsub("`", "", trimws(out)))
})))
norm_glossary_lookup <- unique(c(norm_glossary, gloss_body_bold))

cat(sprintf("Glossary has %d terms\n\n", length(glossary_terms)))

# Allowlist of bolded patterns that are NOT vocabulary
structural_patterns <- c(
  # Quick check question numbers
  "^Q[0-9]+\\.?$", "^Q[0-9]+\\.\\s",
  # Multiple-choice option markers in answer keys
  "^\\([a-eA-E]\\)$",
  # Learning Check numbers
  "^\\(LC[0-9]+\\.[0-9]+\\)$",
  # Generic labels
  "^Note:?$", "^Warning:?$", "^Tip:?$", "^Important:?$",
  "^Solution:?$", "^Answer:?$", "^Solution\\.?$",
  "^Why:?$", "^How to apply:?$",
  "^Step [0-9]+\\.?$",
  "^Example:?$",
  # Section heading prefixes that show up bolded for emphasis
  "^[A-Za-z]\\.$",
  # Numbers/digits
  "^[0-9]+$", "^[0-9]+\\.?[0-9]*$",
  # Single words too short to be vocabulary
  "^[A-Za-z]$", "^[A-Za-z]{1,2}$"
)
structural_re <- paste0("(", paste(structural_patterns, collapse = "|"), ")")

# Common book vocabulary that's bolded for emphasis but doesn't need a glossary
# entry (it's everyday or chapter-specific terminology already explained inline)
# These are heuristic allowlist entries based on common patterns.
emphasis_allowlist <- c(
  "yes", "no", "true", "false", "always", "never", "but", "and", "or", "not",
  "if", "then", "else", "n", "m", "x", "y", "z", "h_0", "h_a",
  "errors", "warnings", "messages",  # Ch 1 §1.2 emphasis
  "errors", "warning", "warnings", "message", "messages", "error",
  "intercept", "slope",  # Often emphasized in Ch 5 but covered there
  "observed", "fitted", "residual", "residuals",
  "data distribution", "population distribution", "sampling distribution",  # Already in glossary or chapter
  "fail to reject", "reject", "accept",
  "left", "right", "center", "middle",
  "above", "below", "around",
  "show answer", "show question",
  "common mistake",
  "by the end of this chapter"
)

# Extract bolded terms from chapter prose (NOT exercise prompts, NOT chunks).
# Build the candidate flag list.
glossary_flags <- list()
candidate_total <- 0

# Files to scan for glossary candidates. Skip:
#   - the glossary itself, references, and the index home page
#   - the foreword/preface (lots of non-vocabulary author-bio and list bolding)
#   - exercise solutions (instructor-facing — exempt from no-new-terms rule)
glossary_scan_files <- setdiff(qmd_files, c(
  "00-foreword.qmd", "00-preface.qmd",
  "96-glossary.qmd", "99-references.qmd", "index.qmd"
))

for (f in glossary_scan_files) {
  lines  <- chap_lines[[f]]
  states <- chap_state[[f]]
  for (i in seq_along(lines)) {
    if (states[i] != "prose") next
    matches <- str_match_all(lines[i], "\\*\\*([^*]{2,80})\\*\\*")[[1]]
    if (nrow(matches) == 0) next
    for (k in seq_len(nrow(matches))) {
      term_raw <- matches[k, 2]
      candidate_total <- candidate_total + 1
      term <- gsub("`", "", term_raw)
      term <- trimws(term)
      # Filter: inline R code expressions like `r paste0(...)` that ended up bolded
      if (grepl("^r\\s+\\w+\\(|paste0\\(|\\(LC\\b", term)) next
      # Filter: math expressions (start with $ or have <- assignment)
      if (grepl("^\\$|\\\\.|<-", term)) next
      # Filter: quoted phrases (these are typically emphasis/illustrative, not vocab)
      if (grepl('^[\"\']', term)) next
      # Filter: structural patterns (Q1., (b), Note:, etc.)
      if (grepl(structural_re, term, perl = TRUE)) next
      # Filter: known emphasis allowlist
      if (tolower(term) %in% emphasis_allowlist) next
      # Filter: mostly non-alphabetic content
      if (nchar(gsub("[^A-Za-z]", "", term)) < 4) next
      # Filter: term ends with `:` (Step 1:, Note:, ...)
      if (grepl(":$", term)) next
      # Filter: bolded sentences (commas, semicolons) — likely emphasis
      if (grepl("[,;]", term)) next
      # Filter: long (likely a phrase being emphasized, not a vocab term)
      if (nchar(term) > 50) next
      # Filter: "Learning Check" callout heading
      if (tolower(term) %in% c("learning check", "common mistake",
                               "show answer", "show question",
                               "in this chapter, you'll learn how to:")) next
      # Filter: capitalized full names (e.g., "Chester Ismay") — multiple words
      # with each starting capital — these are author/proper names
      if (grepl("^[A-Z][a-z]+\\s+[A-Z]", term) &&
          !grepl("(distribution|hypothesis|variable|interval|error|test|regression|sampling|estimate|estimator|population|statistic)", tolower(term))) next
      # Match against glossary (case-insensitive, strip backticks/parens)
      term_norm <- tolower(term)
      term_norm <- gsub("\\s*\\(.*$", "", term_norm)
      term_norm <- trimws(term_norm)
      term_singular <- sub("s$", "", term_norm)
      # Match if exact title, singular form, substring of a title, or
      # bolded cross-ref inside an existing entry's body.
      in_glossary <- term_norm %in% norm_glossary_lookup ||
                     term_singular %in% norm_glossary_lookup ||
                     any(grepl(paste0("(^|\\s)", term_norm, "($|\\s)"), norm_glossary)) ||
                     any(grepl(paste0("(^|\\s)", term_norm, "($|\\s)"), gloss_body_bold)) ||
                     # NEW: bolded phrase contains a glossary title as a phrase
                     # ("sampling distribution of the sample mean" contains "sampling distribution")
                     any(sapply(norm_glossary,
                                function(g) grepl(paste0("(^|\\s)", g, "($|\\s)"),
                                                  term_norm, fixed = FALSE)))
      if (in_glossary) next
      # Filter: Quick check answer key lines (start with **(X)** ...)
      if (grepl("^\\*\\*\\([a-eA-E]\\)\\*\\*", lines[i])) next
      glossary_flags[[length(glossary_flags) + 1]] <- list(
        file = f, line = i, term = term, context = trimws(lines[i])
      )
    }
  }
}

cat(sprintf("Bolded candidates scanned: %d\n", candidate_total))
cat(sprintf("Candidates that don't match glossary (after filters): %d\n\n",
            length(glossary_flags)))

# Bucket by term frequency
if (length(glossary_flags)) {
  term_counts <- table(sapply(glossary_flags, function(x) x$term))
  term_counts <- sort(term_counts, decreasing = TRUE)
  cat("Most-bolded non-glossary terms (top 30):\n")
  for (i in seq_len(min(30, length(term_counts)))) {
    cat(sprintf("  %-50s : %d\n", names(term_counts)[i], term_counts[i]))
  }
  cat("\nDetails per file (capped at 50 entries):\n")
  by_file <- split(glossary_flags, sapply(glossary_flags, function(x) x$file))
  shown <- 0
  for (f in names(by_file)) {
    if (shown >= 50) break
    cat(sprintf("\n  [%s]\n", f))
    for (g in by_file[[f]]) {
      if (shown >= 50) break
      snippet <- substr(g$context, 1, 140)
      cat(sprintf("    L%-5d **%s** :: %s\n", g$line, g$term, snippet))
      shown <- shown + 1
    }
  }
}

cat("\n========== DONE ==========\n")
