#!/usr/bin/env Rscript
# Audit: book section-number references in the exercise files.
#
# Every reference to a numbered book section ("Section 1.3.2", "§ 6.1.3",
# "8.2.3", ...) that appears in `exercises/*.yml` must point at a section that
# actually exists in the book, with the number matching its title. Sections are
# renumbered whenever headings are added/removed/reordered, so these references
# drift silently. This audit rebuilds the canonical section map from the chapter
# .qmd headings and flags two kinds of ERROR:
#
#   1. dead reference   — the cited "N.M[.K]" number does not exist in the book.
#   2. wrong number     — a reference embeds a title (in `book_section` /
#                         `book_subsection` fields, or as `Section N.M "Title"`)
#                         whose text uniquely matches a DIFFERENT section's
#                         number. e.g. cited `1.3.3 Package loading`, but
#                         "Package loading" is section 1.3.2.
#
# Paraphrased labels (the cited title differs from the book title but does not
# match any other section) are reported as INFO only and do NOT fail the build —
# authors deliberately use short coverage labels like "Scatterplots" for
# "5NG#1: Scatterplots". Only a provably wrong *number* fails CI.
#
# Run:  Rscript scripts/audit_section_refs.R   (nonzero exit on any ERROR)

suppressPackageStartupMessages(library(stringr))

book <- "/Users/chesterismay/repos/ModernDive_book"
setwd(book)

# --- Build the canonical section map from chapter headings --------------------
# Chapter number comes from the NN- filename prefix (matches the book's
# sequential chapter numbering). Within a chapter, numbered ## / ### / ####
# headings increment the section counters; {.unnumbered} headings are skipped,
# exactly as Quarto numbers them. Code chunks and YAML front matter are ignored.
build_secmap <- function() {
  files <- sort(c(list.files(".", "^0[1-9]-.*\\.qmd$"),
                  list.files(".", "^1[0-9]-.*\\.qmd$")))
  sec <- character()        # named vector: "1.3.2" -> "Package loading"
  for (f in files) {
    ch <- as.integer(sub("^(\\d+)-.*", "\\1", f))
    lines <- readLines(f, warn = FALSE)
    in_code <- FALSE; in_yaml <- FALSE
    l2 <- 0L; l3 <- 0L; l4 <- 0L
    for (i in seq_along(lines)) {
      ln <- lines[i]
      if (i == 1L && grepl("^---\\s*$", ln)) { in_yaml <- TRUE; next }
      if (in_yaml) { if (grepl("^---\\s*$", ln)) in_yaml <- FALSE; next }
      if (grepl("^```", ln)) { in_code <- !in_code; next }
      if (in_code) next
      m <- str_match(ln, "^(#{2,4})\\s+(.*)$")
      if (is.na(m[1, 1])) next
      level <- nchar(m[1, 2]); rest <- m[1, 3]
      if (grepl("\\{[^}]*\\.unnumbered[^}]*\\}\\s*$", rest)) next
      title <- trimws(sub("\\s*\\{[^}]*\\}\\s*$", "", rest))
      if (level == 2L) { l2 <- l2 + 1L; l3 <- 0L; l4 <- 0L
        num <- sprintf("%d.%d", ch, l2)
      } else if (level == 3L) { l3 <- l3 + 1L; l4 <- 0L
        num <- sprintf("%d.%d.%d", ch, l2, l3)
      } else { l4 <- l4 + 1L
        num <- sprintf("%d.%d.%d.%d", ch, l2, l3, l4) }
      sec[num] <- title
    }
  }
  sec
}

norm <- function(t) {
  t <- tolower(t)
  t <- gsub("[`*]", "", t)
  t <- gsub("[^a-z0-9 ]", " ", t)
  trimws(gsub("\\s+", " ", t))
}

sec <- build_secmap()
# reverse index: paste(chapter, norm(title)) -> character vector of numbers
rev_idx <- list()
for (num in names(sec)) {
  key <- paste(sub("\\..*", "", num), norm(sec[[num]]))
  rev_idx[[key]] <- c(rev_idx[[key]], num)
}

errors <- character()
infos  <- character()

# Returns the unique correct number for a cited (num, title), or NA.
correct_number <- function(num, title) {
  ch <- sub("\\..*", "", num)
  hits <- rev_idx[[paste(ch, norm(title))]]
  if (length(hits) == 1L && hits != num) return(hits)
  NA_character_
}

check_titled <- function(file, where, num, title) {
  title <- trimws(gsub("^['\"]|['\"]$", "", title))
  if (is.na(sec[num])) {
    errors[[length(errors) + 1L]] <<-
      sprintf("%s %s: section %s does NOT exist (cited title: '%s')",
              file, where, num, title)
    return(invisible())
  }
  if (norm(sec[num]) == norm(title)) return(invisible())
  fix <- correct_number(num, title)
  if (!is.na(fix)) {
    errors[[length(errors) + 1L]] <<-
      sprintf("%s %s: cited %s '%s' but that title is section %s (book says %s = '%s')",
              file, where, num, title, fix, num, sec[num])
  } else {
    infos[[length(infos) + 1L]] <<-
      sprintf("%s %s: label '%s' for %s (book %s = '%s')",
              file, where, title, num, num, sec[num])
  }
}

num_re <- "[0-9]+(?:\\.[0-9]+)+"
for (f in sort(list.files("exercises", "\\.yml$", full.names = TRUE))) {
  lines <- readLines(f, warn = FALSE)
  base <- basename(f)
  for (i in seq_along(lines)) {
    ln <- lines[i]
    # book_section: / book_subsection:  ->  "NUM Title"
    m <- str_match(ln, sprintf("^\\s*book_(?:sub)?section:\\s*(%s)\\s+(.+?)\\s*$", num_re))
    if (!is.na(m[1, 1])) {
      check_titled(base, sprintf("L%d book_section", i), m[1, 2], m[1, 3])
    }
    # Section NUM "Title"  (solution_ref / prose with a quoted title)
    q <- str_match_all(ln, sprintf('Section\\s+(%s)\\s+"([^"]+)"', num_re))[[1]]
    if (nrow(q) > 0) {
      for (r in seq_len(nrow(q)))
        check_titled(base, sprintf("L%d titled-ref", i), q[r, 2], q[r, 3])
    }
    # Existence-only for every "Section N.M" / "§ N.M"
    e <- str_match_all(ln, sprintf("(?:Section|§)\\s+(%s)", num_re))[[1]]
    if (nrow(e) > 0) {
      for (r in seq_len(nrow(e))) {
        num <- e[r, 2]
        if (is.na(sec[num]))
          errors[[length(errors) + 1L]] <<-
            sprintf("%s L%d: referenced section %s does NOT exist", base, i, num)
      }
    }
  }
}

errors <- unique(errors)
infos  <- unique(infos)

cat(sprintf("Canonical sections parsed: %d\n", length(sec)))
cat(sprintf("Section-reference ERRORS: %d\n", length(errors)))
if (length(errors)) {
  cat("\n--- ERRORS (wrong or dead section numbers) ---\n")
  cat(paste0("  ", errors, collapse = "\n"), "\n")
}
cat(sprintf("\nParaphrased labels (informational, not failing): %d\n", length(infos)))

if (length(errors)) {
  cat("\n::error::Section-number references are out of date. Fix the numbers above.\n")
  quit(status = 1L)
}
cat("\n✓ All section-number references resolve correctly.\n")
