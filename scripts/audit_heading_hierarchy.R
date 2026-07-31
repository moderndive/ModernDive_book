#!/usr/bin/env Rscript
# Heading hierarchy audit.
#
# For each chapter qmd, verifies that heading levels never skip — i.e., an
# h3 must follow an h2 (not jump from h1 → h3), an h4 must follow an h3,
# etc. Skipping levels is bad for accessibility (screen readers expose the
# outline based on heading levels) and for navigation (TOC nesting gets
# weird).
#
# Output: per-chapter list of any heading sequence violations. Exits
# non-zero if any chapter has a violation.

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

qmd_files <- list.files(".", pattern = "\\.qmd$")
qmd_files <- qmd_files[!grepl("^(96-glossary|99-references|index)", qmd_files)]
qmd_files <- sort(qmd_files)

violations <- list()
total_headings <- 0

for (f in qmd_files) {
  lines <- readLines(f, warn = FALSE)
  # Track whether we're inside a code chunk fence (don't count # comments as headings)
  in_chunk <- FALSE
  prev_level <- 0
  prev_line <- 0
  for (i in seq_along(lines)) {
    l <- lines[i]
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (in_chunk) next
    # Heading lines: ^#+ space
    m <- str_match(l, "^(#+)\\s+(.+?)(?:\\s*\\{[^}]*\\})?\\s*$")
    if (is.na(m[1, 1])) next
    level <- nchar(m[1, 2])
    title <- trimws(m[1, 3])
    total_headings <- total_headings + 1
    if (prev_level > 0 && level > prev_level + 1) {
      violations[[length(violations) + 1]] <- list(
        file = f, line = i, level = level, title = title,
        prev_level = prev_level, prev_line = prev_line
      )
    }
    prev_level <- level
    prev_line <- i
  }
}

cat(sprintf("Scanned %d files, %d headings\n", length(qmd_files), total_headings))
cat(sprintf("Heading-level skips: %d\n\n", length(violations)))

if (length(violations)) {
  cat("=== VIOLATIONS ===\n")
  for (v in violations) {
    cat(sprintf("  [%s] L%d: h%d \"%s\"\n",
                v$file, v$line, v$level, substr(v$title, 1, 60)))
    cat(sprintf("    (previous heading at L%d was h%d — should be h%d, not h%d)\n",
                v$prev_line, v$prev_level, v$prev_level + 1, v$level))
  }
  quit(status = 1)
}
cat("All heading hierarchies OK.\n")
