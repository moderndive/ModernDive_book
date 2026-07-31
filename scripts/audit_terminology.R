#!/usr/bin/env Rscript
# Terminology consistency audit.
#
# Catches inconsistent forms of the same term used across chapters.
# Each `pairs` entry is `(preferred, variants)`: if a chapter uses
# any variant when the preferred form is established as the standard,
# flag the inconsistency.
#
# Heuristic: count occurrences of each form. The "preferred" form is
# the one we've decided to standardize on; report when a variant
# outnumbers the preferred, OR when both forms appear in the same
# chapter (mixed usage).

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

# (preferred, variants...) — case-insensitive word-boundary matching.
# Note: order matters when a preferred form contains a variant
# (e.g., "dataset" before "data set" so we don't double-count).
pairs <- list(
  list(preferred = "dataset",      variants = c("data set", "data-set")),
  list(preferred = "tidyverse",    variants = c("tidy verse", "tidy-verse")),
  list(preferred = "p-value",      variants = c("p value")),
  list(preferred = "t-distribution", variants = c("t distribution")),
  list(preferred = "Quick check",  variants = c("quick-check")),
  list(preferred = "Learning Check", variants = c("learning check", "learning-check")),
  list(preferred = "boxplot",      variants = c("box plot", "box-plot")),
  list(preferred = "barplot",      variants = c("bar plot", "bar-plot")),
  list(preferred = "scatterplot",  variants = c("scatter plot", "scatter-plot")),
  list(preferred = "histogram",    variants = c("histo gram")),
  list(preferred = "filename",     variants = c("file name")),
  list(preferred = "online",       variants = c("on-line", "on line"))
)

# Chapter qmds (skip glossary/refs/index)
qmd_files <- list.files(".", pattern = "^[0-9A-z]+.*\\.qmd$")
qmd_files <- qmd_files[!grepl("^(96-glossary|99-references|index)", qmd_files)]
qmd_files <- sort(qmd_files)

count_word <- function(text, word) {
  # Word-boundary match, case-insensitive
  pattern <- paste0("\\b", str_replace_all(word, " ", "\\\\s+"), "\\b")
  length(unlist(regmatches(text, regexpr(pattern, text, ignore.case = TRUE,
                                          perl = TRUE))))
}

count_word_all <- function(text, word) {
  pattern <- paste0("\\b", str_replace_all(word, " ", "\\\\s+"), "\\b")
  length(unlist(str_extract_all(tolower(text), tolower(pattern))))
}

flags <- list()
for (f in qmd_files) {
  lines <- readLines(f, warn = FALSE)
  # Strip code chunks for this check (terminology in chapter prose only)
  in_chunk <- FALSE
  prose <- character()
  for (l in lines) {
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (!in_chunk) prose <- c(prose, l)
  }
  text <- paste(prose, collapse = "\n")
  # Also strip inline code
  text <- str_replace_all(text, "`[^`]+`", " ")

  for (p in pairs) {
    pref_n <- count_word_all(text, p$preferred)
    for (v in p$variants) {
      var_n <- count_word_all(text, v)
      if (var_n > 0) {
        flags[[length(flags) + 1]] <- list(
          file = f, preferred = p$preferred, variant = v,
          preferred_count = pref_n, variant_count = var_n
        )
      }
    }
  }
}

cat(sprintf("Scanned %d files. Variant-form occurrences: %d\n\n",
            length(qmd_files), length(flags)))
if (length(flags)) {
  cat("=== Variants found (consider standardizing) ===\n")
  for (fl in flags) {
    cat(sprintf("  [%s] \"%s\" x%d (preferred \"%s\" x%d)\n",
                fl$file, fl$variant, fl$variant_count,
                fl$preferred, fl$preferred_count))
  }
  # Don't fail CI — terminology consistency is informational, not a hard rule.
  cat("\n(Informational only — no failure.)\n")
}
cat("Done.\n")
