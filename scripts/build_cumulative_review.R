#!/usr/bin/env Rscript
# Cumulative review pages.
#
# For each major milestone in the course (after Ch 4, after Ch 7, after
# Ch 11), produce a study-guide page that:
#
#   * Pulls a small set of representative exercises from earlier chapters,
#     emphasising concepts that recur in later chapters (so reviewing them
#     pays double).
#   * Highlights cross-chapter concept threads (e.g., "Distributions:
#     from Ch 2 histograms to Ch 7 sampling distributions to Ch 8 bootstrap
#     distributions").
#   * Lists vocabulary the student should be comfortable with by that
#     milestone, drawn from the glossary entries whose intro chapter is at
#     or before the milestone.
#
# Differs from the exam bank: those are summative-assessment templates with
# point values, parallel forms, and workspace. Cumulative review is
# formative — student-facing study material the instructor can hand out
# before exams, or that motivated students can use on their own.
#
# Run:  Rscript scripts/build_cumulative_review.R

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

chap_titles <- c(
  "1" = "Getting started",          "2"  = "Visualization",
  "3" = "Wrangling",                "4"  = "Tidy data",
  "5" = "Regression",               "6"  = "Multiple regression",
  "7" = "Sampling",                 "8"  = "Confidence intervals",
  "9" = "Hypothesis testing",       "10" = "Inference for regression",
  "11" = "Tell your story with data"
)

# Milestones to produce a review for.
milestones <- list(
  list(id = "after-ch4",  name = "After Chapter 4 (data manipulation)",
       through = 4, target_per_chapter = 3,
       thread_text = "The first four chapters build a complete data-manipulation toolkit: R/RStudio basics (Ch 1) → ggplot visualization (Ch 2) → dplyr wrangling (Ch 3) → tidyr reshaping + readr import (Ch 4). Review focuses on the verbs and grammar; you'll lean on every one of these tools throughout the modeling and inference chapters."),
  list(id = "after-ch7",  name = "After Chapter 7 (modeling + sampling)",
       through = 7, target_per_chapter = 3,
       thread_text = "Chapters 5-7 introduce two new modes of thinking. Chapters 5-6 cover regression as a way to summarize relationships in data. Chapter 7 introduces sampling — the bridge between data we have and the larger population we want to draw conclusions about. Review covers the data-toolkit one more time (lighter) plus the new modeling + sampling concepts (heavier)."),
  list(id = "final",      name = "Final review (all chapters)",
       through = 11, target_per_chapter = 2,
       thread_text = "The full arc: from raw data to statistical inference. The infer workflow (specify → hypothesize → generate → calculate) introduced in Ch 7-9 returns in Ch 10 applied to regression coefficients. Practice problems span all major topics; weight your time toward the inference chapters (7-10), which compound the most prior material.")
)

# Load all exercises (include Extensions this time — review is OK to include
# stretch material; but exclude carry-overs to avoid double-counting).
pool <- list()
for (ch in 1:11) {
  yml <- sprintf("exercises/%02d.yml", ch)
  if (!file.exists(yml)) next
  d <- tryCatch(read_yaml(yml), error = function(e) NULL)
  exes <- if (is.list(d) && !is.null(d$exercises)) d$exercises else list()
  for (ex in exes) {
    if (!is.list(ex)) next
    if (grepl("Carried over from", ex$prompt %||% "", ignore.case = TRUE)) next
    pool[[length(pool) + 1]] <- list(
      chap = ch, ex_num = ex$ex_num,
      difficulty = as.integer(ex$difficulty %||% NA),
      group = ex$group %||% "",
      book_section = ex$book_section %||% "",
      prompt = ex$prompt %||% "",
      webr = ex$webr %||% ""
    )
  }
}
cat("Pool:", length(pool), "exercises\n")

# Per-milestone: pick `target_per_chapter` exercises from each prior
# chapter, biased toward medium difficulty (★★) so the review isn't all
# warm-ups or all stumpers.
sample_review <- function(milestone, seed = 7L) {
  set.seed(seed + milestone$through)
  out <- list()
  for (ch in seq_len(milestone$through)) {
    cands <- Filter(function(e) e$chap == ch && !is.na(e$difficulty), pool)
    if (!length(cands)) next
    # Sort by closeness to difficulty 2 (medium) for variety
    pri <- abs(vapply(cands, `[[`, integer(1), "difficulty") - 2L)
    cands <- cands[order(pri + runif(length(pri)) * 0.5)]
    out <- c(out, head(cands, milestone$target_per_chapter))
  }
  out
}

# Glossary anchors → intro chapter (lean on the same heuristic as
# audit_exercise_lexicon.R, but loaded inline so this script stays
# standalone).
glossary_terms <- function() {
  gf <- "96-glossary.qmd"
  if (!file.exists(gf)) return(character())
  lines <- readLines(gf, warn = FALSE)
  # Entries look like:  ### TERM {#g-anchor}
  entries <- str_match(lines, "^###\\s+(.+?)\\s*\\{#g-")
  terms <- entries[!is.na(entries[, 2]), 2]
  unique(trimws(terms))
}
all_terms <- glossary_terms()

# Map glossary term → first chapter where it appears in prose (backticked
# or plain). Approximate; this is just for the "vocab by milestone" sidebar.
term_intro <- list()
for (ch in 1:11) {
  qmd <- list.files(".", pattern = sprintf("^%02d-.*\\.qmd$", ch))
  if (!length(qmd)) next
  text <- tolower(paste(readLines(qmd[1], warn = FALSE), collapse = " "))
  for (term in all_terms) {
    tl <- tolower(term)
    if (is.null(term_intro[[term]]) && grepl(paste0("\\b", tl, "\\b"), text, fixed = FALSE)) {
      term_intro[[term]] <- ch
    }
  }
}

# --- Render HTML -----------------------------------------------------------
escape_html <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;",  s, fixed = TRUE)
  s <- gsub(">", "&gt;",  s, fixed = TRUE)
  s
}
md_inline <- function(s) {
  s <- escape_html(s)
  s <- gsub("`([^`]+)`", "<code>\\1</code>", s)
  s <- gsub("\\*\\*([^*]+)\\*\\*", "<strong>\\1</strong>", s)
  s <- gsub("\\*([^*]+)\\*", "<em>\\1</em>", s)
  s
}
diff_stars <- function(d) {
  if (is.null(d) || is.na(d)) return("")
  paste(rep("&#9733;", as.integer(d)), collapse = "")
}

milestone_blocks <- character()
for (ms in milestones) {
  picks <- sample_review(ms)
  vocab <- sort(names(Filter(function(c) c <= ms$through, term_intro)))
  by_chap <- split(picks, vapply(picks, `[[`, integer(1), "chap"))
  chap_html <- character()
  for (ch in sort(as.integer(names(by_chap)))) {
    items <- vapply(by_chap[[as.character(ch)]], function(p) {
      sprintf('<li><strong>EX %d.%d</strong> %s <span class="ex-meta">&middot; %s</span><div class="ex-prompt">%s</div></li>',
              p$chap, p$ex_num, diff_stars(p$difficulty),
              md_inline_html(p$book_section), md_inline(p$prompt))
    }, character(1))
    chap_html <- c(chap_html, sprintf(
      '<div class="chap-block"><h3>Chapter %d: %s</h3><ol class="ex-list">%s</ol></div>',
      ch, escape_html(chap_titles[[as.character(ch)]]), paste(items, collapse = "")))
  }
  vocab_html <- if (length(vocab)) {
    paste0('<details class="vocab"><summary>Vocabulary you should know (',
           length(vocab), ' terms)</summary><p>',
           paste(sprintf('<code>%s</code>', escape_html(vocab)), collapse = " "),
           '</p></details>')
  } else ""
  milestone_blocks <- c(milestone_blocks, paste0(
    sprintf('<section class="milestone" id="%s">', ms$id),
    sprintf('<h2>%s</h2>', escape_html(ms$name)),
    sprintf('<p class="thread">%s</p>', escape_html(ms$thread_text)),
    vocab_html,
    paste(chap_html, collapse = "\n"),
    '</section>'
  ))
}

html <- paste(c(
  '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Cumulative review</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1080px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.6em; color: #1F3A6B; margin-bottom: 0.2em; }',
  '  h2 { font-size: 1.3em; margin-top: 2em; color: #1F3A6B; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; }',
  '  h3 { font-size: 1.05em; color: #1F3A6B; margin-top: 1.5em; }',
  '  .milestone { margin-top: 2em; }',
  '  .thread { background: #F0F4F8; border-left: 4px solid #1A6FBE; padding: 0.8em 1em; border-radius: 4px; font-size: 0.95em; color: #1B2E4E; }',
  '  details.vocab { margin: 0.8em 0; }',
  '  details.vocab summary { cursor: pointer; font-weight: 600; color: #1A6FBE; padding: 0.4em 0; }',
  '  details.vocab p { background: #FAFBFD; padding: 0.8em; border-radius: 4px; line-height: 1.9; }',
  '  details.vocab code { background: #E8F3E5; color: #4A7A2C; padding: 0.1em 0.4em; border-radius: 3px; font-size: 0.88em; margin: 0 0.15em; }',
  '  .chap-block { margin: 1em 0; }',
  '  ol.ex-list { padding-left: 1.4em; }',
  '  ol.ex-list li { margin: 0.7em 0; padding: 0.6em 0.8em; background: #FAFBFD; border-left: 3px solid #4D93D3; border-radius: 3px; }',
  '  .ex-meta { color: #6B7B8E; font-size: 0.85em; font-style: italic; }',
  '  .ex-prompt { margin-top: 0.3em; font-size: 0.94em; }',
  '  code { background: #F0F4F8; padding: 0.05em 0.3em; border-radius: 3px; font-size: 0.92em; color: #1F3A6B; }',
  '  nav.milestone-jump { margin: 1em 0; }',
  '  nav.milestone-jump a { display: inline-block; margin-right: 0.6em; color: #1A6FBE; text-decoration: none; padding: 0.3em 0.7em; background: #F0F4F8; border-radius: 4px; }',
  '  nav.milestone-jump a:hover { background: #E0EBF5; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>Cumulative review</h1>',
  sprintf('<p>Generated %s. Three milestone study guides, each pulling a curated handful of medium-difficulty exercises from every prior chapter plus a vocabulary checklist. Hand these to students before midterms / finals, or as voluntary self-study material. (For exam <em>delivery</em>, see the <a href="exam-bank.html">exam question bank</a>; for individual chapter pacing, see <a href="lesson-plans.html">lesson plans</a>.)</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<nav class="milestone-jump">',
  paste(vapply(milestones, function(ms) sprintf('<a href="#%s">%s</a>', ms$id, escape_html(ms$name)), character(1)), collapse = ""),
  '</nav>',
  paste(milestone_blocks, collapse = "\n"),
  '</body></html>'
), collapse = "\n")

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out <- "instructor-solutions/_site/cumulative-review.html"
writeLines(html, out)
n_ex <- sum(vapply(milestones, function(ms) length(sample_review(ms)), integer(1)))
cat(sprintf("Wrote %s (%d milestones, %d total review exercises)\n",
            out, length(milestones), n_ex))
