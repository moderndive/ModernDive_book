#!/usr/bin/env Rscript
# Exam question bank: stratified-sample exam templates.
#
# Generates printable exam templates by stratified sampling from the
# end-of-chapter exercise pool. Each template:
#
#   * Targets a chapter range (Ch 1-5 midterm, Ch 6-10 second midterm, full
#     final, single-chapter quiz).
#   * Targets a difficulty mix (e.g., 40% ★ / 40% ★★ / 20% ★★★).
#   * Excludes Extensions (those are stretch material, not exam fodder).
#   * Excludes exercises whose prompt explicitly references "Carried over
#     from Chapter X" (they double-test earlier material).
#   * Lays out questions print-ready with space for student work,
#     point values, and a link back to each exercise's solution page.
#
# We generate THREE shuffled samples per template so instructors have
# version A/B/C parallel forms ready to go.
#
# Run:  Rscript scripts/build_exam_bank.R

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Templates: name, chapter range, target count, difficulty mix (proportions).
templates <- list(
  list(id = "ch1-quiz",  name = "Chapter 1 quiz",            chs = 1,        n = 5,  mix = c(`1` = 0.6, `2` = 0.4, `3` = 0)),
  list(id = "ch2-quiz",  name = "Chapter 2 quiz",            chs = 2,        n = 6,  mix = c(`1` = 0.5, `2` = 0.4, `3` = 0.1)),
  list(id = "ch3-quiz",  name = "Chapter 3 quiz",            chs = 3,        n = 6,  mix = c(`1` = 0.4, `2` = 0.4, `3` = 0.2)),
  list(id = "midterm-1", name = "Midterm I (Ch 1-4)",        chs = 1:4,      n = 10, mix = c(`1` = 0.3, `2` = 0.5, `3` = 0.2)),
  list(id = "midterm-2", name = "Midterm II (Ch 5-7)",       chs = 5:7,      n = 10, mix = c(`1` = 0.2, `2` = 0.5, `3` = 0.3)),
  list(id = "final",     name = "Final exam (all chapters)", chs = 1:11,     n = 14, mix = c(`1` = 0.25, `2` = 0.45, `3` = 0.30)),
  list(id = "infer-only",name = "Inference unit (Ch 7-10)",  chs = 7:10,     n = 10, mix = c(`1` = 0.2, `2` = 0.5, `3` = 0.3))
)

# Load all exercises with full metadata + chapter.
pool <- list()
for (ch in 1:11) {
  yml <- sprintf("exercises/%02d.yml", ch)
  if (!file.exists(yml)) next
  d <- tryCatch(read_yaml(yml), error = function(e) NULL)
  exes <- if (is.list(d) && !is.null(d$exercises)) d$exercises else list()
  for (ex in exes) {
    if (!is.list(ex)) next
    group <- (ex$group %||% "")
    # Skip Extensions + carry-overs
    if (identical(tolower(group), "extensions")) next
    if (grepl("Carried over from", ex$prompt %||% "", ignore.case = TRUE)) next
    pool[[length(pool) + 1]] <- list(
      chap = ch, ex_num = ex$ex_num,
      difficulty = as.integer(ex$difficulty %||% NA),
      group = group, book_section = ex$book_section %||% "",
      prompt = ex$prompt %||% "", webr = ex$webr %||% ""
    )
  }
}

cat("Pool:", length(pool), "non-Extension non-carryover exercises across 11 chapters\n")

# Stratified sampler: aim for the difficulty mix within the chapter range.
sample_exam <- function(tmpl, seed) {
  set.seed(seed)
  candidates <- Filter(function(e) e$chap %in% tmpl$chs && !is.na(e$difficulty), pool)
  if (!length(candidates)) return(list())
  by_diff <- split(candidates, vapply(candidates, `[[`, integer(1), "difficulty"))
  picks <- list()
  for (d in c("1", "2", "3")) {
    target <- round(tmpl$n * tmpl$mix[[d]])
    bucket <- by_diff[[d]] %||% list()
    if (length(bucket) && target > 0) {
      picks <- c(picks, bucket[sample(length(bucket), min(target, length(bucket)))])
    }
  }
  # If we under-shot due to small buckets, top up from any remaining
  remaining <- setdiff(seq_along(candidates), match(picks, candidates))
  while (length(picks) < tmpl$n && length(remaining)) {
    add <- sample(remaining, 1)
    picks <- c(picks, list(candidates[[add]]))
    remaining <- setdiff(remaining, add)
  }
  picks[seq_len(min(length(picks), tmpl$n))]
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

render_exam <- function(tmpl, version, seed) {
  picks <- sample_exam(tmpl, seed)
  if (!length(picks)) return(NULL)
  total_pts <- sum(vapply(picks, function(p) c(1L, 2L, 3L)[p$difficulty], integer(1)))
  qs <- character()
  for (i in seq_along(picks)) {
    p <- picks[[i]]
    pts <- c(1L, 2L, 3L)[p$difficulty]
    qs <- c(qs, sprintf(
      '<div class="exam-q">
         <div class="q-head"><span class="q-num">Q%d</span><span class="q-pts">%d pt%s</span><span class="q-meta">Ch %d &middot; %s &middot; <a href="solutions/index.html#ex-%d-%d">solution</a></span></div>
         <div class="q-prompt">%s</div>
         %s
         <div class="q-workspace">Workspace:<br>&nbsp;</div>
       </div>',
      i, pts, if (pts == 1) "" else "s",
      p$chap, escape_html(p$book_section), p$chap, p$ex_num,
      md_inline(p$prompt),
      if (nzchar(p$webr)) sprintf('<pre class="q-starter">%s</pre>', escape_html(p$webr)) else ""
    ))
  }
  list(
    header = sprintf(
      '<section class="exam"><h2 id="%s-%s">%s &middot; Version %s</h2>
       <p class="exam-meta">%d questions &middot; %d points &middot; chapters %s</p>',
      tmpl$id, version, escape_html(tmpl$name), version,
      length(picks), total_pts,
      paste(range(tmpl$chs), collapse = "-")),
    body = paste(qs, collapse = "\n"),
    footer = '</section>'
  )
}

versions <- c("A", "B", "C")
all_sections <- character()
for (tmpl in templates) {
  for (v_idx in seq_along(versions)) {
    rendered <- render_exam(tmpl, versions[v_idx],
                            seed = 1000L * v_idx + sum(utf8ToInt(tmpl$id)))
    if (is.null(rendered)) next
    all_sections <- c(all_sections, rendered$header, rendered$body, rendered$footer)
  }
}

toc <- character()
for (tmpl in templates) {
  toc <- c(toc, sprintf(
    '<li><strong>%s</strong> &mdash; <a href="#%s-A">v.A</a> &middot; <a href="#%s-B">v.B</a> &middot; <a href="#%s-C">v.C</a></li>',
    escape_html(tmpl$name), tmpl$id, tmpl$id, tmpl$id))
}

html <- paste(c(
  '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Exam question bank</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 920px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.6em; color: #1F3A6B; margin-bottom: 0.2em; }',
  '  h2 { font-size: 1.25em; margin-top: 2.5em; padding-bottom: 0.3em; border-bottom: 2px solid #1A6FBE; color: #1F3A6B; }',
  '  .exam-meta { color: #555; font-style: italic; font-size: 0.92em; margin-top: 0.2em; }',
  '  .exam-q { background: #FAFBFD; border: 1px solid #E0E6EC; border-left: 4px solid #4D93D3; padding: 1em 1.2em; margin: 1em 0; border-radius: 4px; }',
  '  .q-head { display: flex; gap: 1em; align-items: baseline; margin-bottom: 0.5em; }',
  '  .q-num { font-weight: 700; color: #1F3A6B; font-size: 1.05em; }',
  '  .q-pts { background: #E8F3E5; color: #4A7A2C; padding: 0.1em 0.5em; border-radius: 3px; font-size: 0.85em; font-weight: 600; }',
  '  .q-meta { color: #6B7B8E; font-size: 0.83em; margin-left: auto; }',
  '  .q-meta a { color: #1A6FBE; }',
  '  .q-prompt { margin-bottom: 0.5em; }',
  '  .q-starter { background: #2D2D2D; color: #F8F8F2; padding: 0.7em 0.9em; border-radius: 3px; font-size: 0.88em; overflow-x: auto; white-space: pre-wrap; }',
  '  .q-workspace { background: white; border: 1px dashed #BBB; padding: 0.5em 0.8em; margin-top: 0.6em; border-radius: 3px; color: #888; font-size: 0.85em; min-height: 3em; }',
  '  code { background: #F0F4F8; padding: 0.05em 0.3em; border-radius: 3px; font-size: 0.92em; color: #1F3A6B; }',
  '  .toc { background: #F0F4F8; padding: 0.8em 1.2em; border-radius: 6px; }',
  '  .toc ul { margin: 0.4em 0; padding-left: 1.4em; }',
  '  .toc li { margin: 0.25em 0; }',
  '  @media print { body { max-width: 100%; } .toc { display: none; } .exam-q { break-inside: avoid; } }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>Exam question bank</h1>',
  sprintf('<p>Generated %s. Each template is a stratified random sample (versions A/B/C are different seeds, so they can be used as parallel forms). Point value = difficulty (★=1, ★★=2, ★★★=3). Extensions and "Carried over" exercises are excluded from the pool. Solutions linked per question (instructor-only).</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<div class="toc"><strong>Templates</strong><ul>',
  paste(toc, collapse = "\n"),
  '</ul></div>',
  paste(all_sections, collapse = "\n"),
  '</body></html>'
), collapse = "\n")

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out <- "instructor-solutions/_site/exam-bank.html"
writeLines(html, out)
cat(sprintf("Wrote %s (%d templates × 3 versions = %d exams)\n",
            out, length(templates), length(templates) * 3))
