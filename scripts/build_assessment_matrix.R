#!/usr/bin/env Rscript
# Assessment alignment matrix.
#
# Cross-references each chapter's Learning Objectives (the bulleted list in
# the chapter's `::: {.callout-note title="In this chapter, you'll learn how
# to:"}` callout) against the exercises that follow. For each LO we surface
# which exercises (by ex_num, book_section, difficulty) plausibly assess
# that objective.
#
# The match heuristic: take the LO's key verb and code-formatted nouns
# (backticked terms) and look for those terms in each exercise's prompt
# + webr field. A simple bag-of-keywords overlap with light stemming.
# Surface the top 3 matching exercises per LO so an instructor can quickly
# see "is this objective tested? Where?"
#
# This is necessarily approximate — the real authoritative mapping lives
# in the chapter author's head. But the matrix catches the obvious gaps
# ("no exercise mentions `pivot_wider` even though it's an LO") and lets
# the author iterate.
#
# Run:  Rscript scripts/build_assessment_matrix.R

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

chap_titles <- c(
  "1" = "Getting started",          "2"  = "Visualization",
  "3" = "Wrangling",                "4"  = "Tidy data",
  "5" = "Regression",               "6"  = "Multiple regression",
  "7" = "Sampling",                 "8"  = "Confidence intervals",
  "9" = "Hypothesis testing",       "10" = "Inference for regression",
  "11" = "Tell your story with data"
)

# --- Parse Learning Objectives per chapter ---------------------------------
parse_los <- function(qmd_path) {
  txt <- paste(readLines(qmd_path, warn = FALSE), collapse = "\n")
  # Block between the callout-note title and its closing :::.
  m <- str_match(
    txt,
    "(?s):::\\s*\\{\\.callout-note\\s+title=\"In this chapter, you'll learn how to:\"\\}(.*?):::"
  )
  if (is.na(m[1, 1])) return(character(0))
  body <- m[1, 2]
  # Each bullet is a `- ...` line; strip the dash + leading whitespace.
  bullets <- str_match_all(body, "(?m)^\\s*-\\s*(.+)$")[[1]]
  if (nrow(bullets) == 0) return(character(0))
  trimws(bullets[, 2])
}

# Extract weighted keywords from an LO. We give higher weight to
# backticked code (e.g., `pivot_longer`) since those are the most
# specific signal, and discount very common stopwords.
lo_keywords <- function(lo) {
  # Code: backticked tokens
  code <- str_match_all(lo, "`([^`]+)`")[[1]]
  code_tokens <- if (nrow(code)) tolower(str_extract(code[, 2], "[A-Za-z_][A-Za-z0-9_]*")) else character()
  # Prose: italic and bold emphasis (often a key noun)
  emph <- unlist(str_extract_all(lo, "(?<=\\*)([A-Za-z][A-Za-z'-]+)(?=\\*)"))
  emph_tokens <- if (length(emph)) tolower(emph) else character()
  # Rest of the prose words >= 4 chars
  prose <- tolower(gsub("`[^`]+`", "", lo))
  prose <- gsub("[*_(){}\\[\\].,:;!?\"'\\\\]", " ", prose)
  prose <- gsub("\\s+", " ", prose)
  words <- str_extract_all(prose, "[a-z][a-z']{3,}")[[1]]
  stopwords <- c("with", "from", "into", "that", "this", "they", "them", "their",
                 "have", "what", "when", "where", "which", "your", "will", "more",
                 "than", "then", "each", "some", "such", "between", "across",
                 "using", "use", "used", "build", "construct", "make", "made",
                 "data", "frame", "variable", "value", "values", "result", "results",
                 "kind", "kinds", "type", "types", "step", "steps", "set", "sets",
                 "chapter", "common", "case", "cases", "another", "different",
                 "appropriate", "argument", "argum", "called", "always", "first",
                 "second", "third", "next")
  prose_tokens <- setdiff(words, stopwords)
  list(code = code_tokens, emph = emph_tokens, prose = prose_tokens)
}

# Score how well an exercise (prompt + webr text) matches an LO's keywords.
score_match <- function(ex_text, kws) {
  ex_low <- tolower(ex_text)
  s <- 0
  for (tok in kws$code)  if (nzchar(tok) && grepl(paste0("\\b", tok, "\\b"), ex_low)) s <- s + 5
  for (tok in kws$emph)  if (nzchar(tok) && grepl(paste0("\\b", tok, "\\b"), ex_low)) s <- s + 2
  for (tok in kws$prose) if (nzchar(tok) && grepl(paste0("\\b", tok, "\\b"), ex_low)) s <- s + 1
  s
}

# --- Per-chapter alignment -------------------------------------------------
chapters <- sprintf("%02d", 1:11)
results <- list()
for (ch in chapters) {
  qmd <- list.files(".", pattern = paste0("^", ch, "-.*\\.qmd$"))
  if (!length(qmd)) next
  yml <- sprintf("exercises/%s.yml", ch)
  los <- parse_los(qmd[1])
  if (!length(los)) next
  ex_data <- tryCatch(read_yaml(yml), error = function(e) NULL)
  exercises <- if (is.list(ex_data) && !is.null(ex_data$exercises)) ex_data$exercises else list()
  per_lo <- list()
  for (lo in los) {
    kws <- lo_keywords(lo)
    scored <- lapply(exercises, function(ex) {
      if (!is.list(ex)) return(NULL)
      text <- paste(c(ex$prompt %||% "", ex$webr %||% ""), collapse = " ")
      list(ex_num = ex$ex_num, difficulty = ex$difficulty,
           group = ex$group %||% "", book_section = ex$book_section %||% "",
           score = score_match(text, kws),
           prompt = substr(ex$prompt %||% "", 1, 110))
    })
    scored <- Filter(function(x) !is.null(x) && x$score > 0, scored)
    scored <- scored[order(-vapply(scored, `[[`, numeric(1), "score"))]
    per_lo[[length(per_lo) + 1]] <- list(lo = lo, top = head(scored, 4))
  }
  results[[ch]] <- list(chap = as.integer(ch),
                        title = chap_titles[[as.character(as.integer(ch))]],
                        los = per_lo, n_ex = length(exercises))
}

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# --- Render HTML -----------------------------------------------------------
escape_html <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;",  s, fixed = TRUE)
  s <- gsub(">", "&gt;",  s, fixed = TRUE)
  s
}
diff_stars <- function(d) {
  if (is.null(d) || is.na(d)) return("")
  paste(rep("★", as.integer(d)), collapse = "")
}

chap_sections <- character(0)
for (r in results) {
  rows <- character()
  for (entry in r$los) {
    lo_html <- escape_html(entry$lo)
    # Convert backticks → <code>, italics → <em> (lightweight markdown)
    lo_html <- gsub("`([^`]+)`", "<code>\\1</code>", lo_html)
    lo_html <- gsub("\\*([^*]+)\\*", "<em>\\1</em>", lo_html)
    if (!length(entry$top)) {
      tops <- '<td class="gap"><strong>No matching exercise</strong> &mdash; this objective may be under-assessed.</td>'
    } else {
      items <- vapply(entry$top, function(m) {
        sprintf(
          '<li><strong>EX %d.%d</strong> %s <span class="ex-meta">%s &middot; %s &middot; score=%d</span><br><span class="ex-prompt">%s…</span></li>',
          r$chap, m$ex_num, diff_stars(m$difficulty),
          escape_html(m$group), escape_html(m$book_section),
          m$score, escape_html(m$prompt)
        )
      }, character(1))
      tops <- paste0('<td><ul class="match-list">', paste(items, collapse = ""), '</ul></td>')
    }
    rows <- c(rows, sprintf('<tr><td class="lo">%s</td>%s</tr>', lo_html, tops))
  }
  chap_sections <- c(chap_sections, paste0(
    sprintf('<h2 id="ch%d">Chapter %d: %s <span class="ex-count">(%d exercises)</span></h2>',
            r$chap, r$chap, escape_html(r$title), r$n_ex),
    '<table class="lo-matrix">',
    '<tr><th class="lo-col">Learning objective</th><th class="ex-col">Top-matched exercises</th></tr>',
    paste(rows, collapse = "\n"),
    '</table>'
  ))
}

html <- paste(c(
  '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Assessment alignment matrix</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1180px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.6em; margin-bottom: 0.2em; color: #1F3A6B; }',
  '  h2 { font-size: 1.2em; margin-top: 2.2em; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; color: #1F3A6B; }',
  '  .ex-count { font-size: 0.85em; color: #555; font-weight: normal; }',
  '  table.lo-matrix { border-collapse: collapse; width: 100%; margin: 0.5em 0 1.5em 0; }',
  '  table.lo-matrix th { background: #F0F4F8; padding: 0.7em 1em; text-align: left; border-bottom: 2px solid #C5D5E5; }',
  '  table.lo-matrix th.lo-col { width: 38%; }',
  '  table.lo-matrix td { padding: 0.7em 1em; border-bottom: 1px solid #E5E5E5; vertical-align: top; }',
  '  table.lo-matrix td.lo { font-weight: 500; background: #FAFBFD; }',
  '  table.lo-matrix td.gap { background: #FFF6E5; color: #8a6d3b; border-left: 3px solid #f0ad4e; }',
  '  ul.match-list { margin: 0; padding-left: 1.2em; font-size: 0.92em; }',
  '  ul.match-list li { margin-bottom: 0.5em; }',
  '  .ex-meta { color: #6B7B8E; font-size: 0.86em; font-style: italic; }',
  '  .ex-prompt { color: #555; font-size: 0.88em; }',
  '  code { background: #F0F4F8; padding: 0.05em 0.3em; border-radius: 3px; font-size: 0.92em; color: #1F3A6B; }',
  '  nav.chapter-jump { margin: 1em 0; font-size: 0.92em; }',
  '  nav.chapter-jump a { display: inline-block; margin-right: 0.6em; color: #1A6FBE; text-decoration: none; padding: 0.2em 0.5em; border-radius: 3px; }',
  '  nav.chapter-jump a:hover { background: #F0F4F8; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>Assessment alignment matrix</h1>',
  sprintf('<p>Generated %s. Each chapter\'s <em>learning objectives</em> (the bulleted list in the "In this chapter, you\'ll learn how to:" callout) cross-referenced against its end-of-chapter exercises. The matcher scores each exercise by keyword overlap with the LO (code identifiers count strongest, emphasised nouns next, then plain prose). The top 4 matches per LO are shown.</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<p><strong>How to use:</strong> Look for LOs with <span style="color:#8a6d3b; background:#FFF6E5; padding:0.1em 0.3em">no matching exercise</span> &mdash; those objectives may be under-assessed and worth adding a problem for. Conversely, an LO with many high-score matches is well-covered.</p>',
  '<nav class="chapter-jump">Jump to: ',
  paste(sprintf('<a href="#ch%d">Ch %d</a>', 1:11, 1:11), collapse = ""),
  '</nav>',
  paste(chap_sections, collapse = "\n"),
  '</body></html>'
), collapse = "\n")

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out <- "instructor-solutions/_site/assessment-matrix.html"
writeLines(html, out)
n_los <- sum(vapply(results, function(r) length(r$los), integer(1)))
n_gaps <- sum(vapply(results, function(r) sum(vapply(r$los, function(x) length(x$top) == 0, logical(1))), integer(1)))
cat(sprintf("Wrote %s (%d chapters, %d learning objectives, %d gaps flagged)\n",
            out, length(results), n_los, n_gaps))
