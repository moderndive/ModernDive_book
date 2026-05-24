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

# Templates: id, name, chapter range, conceptual MCQ count, computational
# exercise count, computational difficulty mix.
#
# Each template has TWO sections:
#   * Section A: Conceptual (multiple-choice, sourced from chapter Quick checks)
#   * Section B: Computational (free-response, sourced from end-of-chapter exercises)
#
# Quick-check exposure tends to be conceptual ("what is X?", "why does Y
# happen?"); the exercise pool tends to be computational ("filter to ...",
# "fit lm(...)"). Mixing both gives a more balanced assessment than either
# alone — quizzes lean conceptual (60/40), midterms balance (50/50), finals
# lean computational (40/60).
templates <- list(
  list(id = "ch1-quiz",  name = "Chapter 1 quiz",            chs = 1,    mcq_n = 5, comp_n = 3,  mix = c(`1` = 0.6, `2` = 0.4, `3` = 0)),
  list(id = "ch2-quiz",  name = "Chapter 2 quiz",            chs = 2,    mcq_n = 5, comp_n = 4,  mix = c(`1` = 0.5, `2` = 0.4, `3` = 0.1)),
  list(id = "ch3-quiz",  name = "Chapter 3 quiz",            chs = 3,    mcq_n = 5, comp_n = 4,  mix = c(`1` = 0.4, `2` = 0.4, `3` = 0.2)),
  list(id = "midterm-1", name = "Midterm I (Ch 1-4)",        chs = 1:4,  mcq_n = 6, comp_n = 6,  mix = c(`1` = 0.3, `2` = 0.5, `3` = 0.2)),
  list(id = "midterm-2", name = "Midterm II (Ch 5-7)",       chs = 5:7,  mcq_n = 6, comp_n = 6,  mix = c(`1` = 0.2, `2` = 0.5, `3` = 0.3)),
  list(id = "final",     name = "Final exam (all chapters)", chs = 1:11, mcq_n = 8, comp_n = 12, mix = c(`1` = 0.25, `2` = 0.45, `3` = 0.30)),
  list(id = "infer-only",name = "Inference unit (Ch 7-10)",  chs = 7:10, mcq_n = 6, comp_n = 6,  mix = c(`1` = 0.2, `2` = 0.5, `3` = 0.3))
)

# Quick check parser (mirrors build_misconceptions.R; kept inline so this
# script stays standalone).
parse_quick_checks <- function(lines) {
  qc_idx <- grep("^##\\s+Quick checks", lines)
  if (!length(qc_idx)) return(list())
  next_h <- grep("^## ", lines)
  next_h <- next_h[next_h > qc_idx[1]]
  end <- if (length(next_h)) next_h[1] - 1 else length(lines)
  block_text <- paste(lines[qc_idx[1]:end], collapse = "\n")
  qs <- str_match_all(block_text,
    "(?s)\\*\\*Q(\\d+)\\.\\*\\*\\s+(.+?)(?=\\n\\*\\*Q\\d+\\.\\*\\*|\\Z)")[[1]]
  out <- list()
  if (!nrow(qs)) return(out)
  for (i in seq_len(nrow(qs))) {
    raw <- qs[i, 3]
    stem <- sub("(?s)\\n[a-d]\\.\\s.*", "", raw, perl = TRUE)
    stem <- trimws(stem)
    opt_match <- str_match_all(raw, "(?m)^([a-d])\\.\\s+(.+)$")[[1]]
    options <- if (nrow(opt_match)) setNames(opt_match[, 3], opt_match[, 2]) else character()
    ans <- str_match(raw,
      "(?s):::\\s*\\{\\.callout-tip[^}]*\\}\\s*\\n\\*\\*\\(([a-d])\\)\\*\\*\\s*(.*?)\\n:::")
    correct <- if (!is.na(ans[1, 2])) ans[1, 2] else ""
    out[[length(out) + 1]] <- list(
      n = as.integer(qs[i, 2]), stem = stem, options = options,
      correct = correct
    )
  }
  out
}

# Collect Quick checks for every chapter — the conceptual pool.
mcq_pool <- list()
for (ch in 1:11) {
  qmd <- list.files(".", pattern = sprintf("^%02d-.*\\.qmd$", ch))
  if (!length(qmd)) next
  for (q in parse_quick_checks(readLines(qmd[1], warn = FALSE))) {
    if (length(q$options) && nzchar(q$correct)) {
      mcq_pool[[length(mcq_pool) + 1]] <- c(q, list(chap = ch))
    }
  }
}
cat("MCQ pool:", length(mcq_pool), "Quick check items across 11 chapters\n")

# Instructor-authored EXTRAS pool — supplemental questions beyond the book's
# exercises and Quick checks. Lets instructors add their own conceptual,
# applied, or essay-style assessments that fit the same chapter scaffolding.
# File format (yaml list under `items`):
#
#   items:
#     - chap: 5
#       kind: mcq           # mcq | short | essay
#       difficulty: 2        # 1-3 (drives point value)
#       prompt: "Question text (markdown OK)"
#       options:             # required if kind: mcq
#         a: "..."
#         b: "..."
#         c: "..."
#         d: "..."
#       correct: c           # required if kind: mcq
#       rubric: "Brief grading rubric"   # optional; useful for short/essay
#
# File path: instructor-solutions/exam-bank-extras.yml (gitignored if you
# want — the script handles missing file silently). A starter file with
# example items ships in the repo to show the format.
extras_pool <- list()
extras_file <- "instructor-solutions/exam-bank-extras.yml"
if (file.exists(extras_file)) {
  ex_data <- tryCatch(read_yaml(extras_file), error = function(e) NULL)
  if (!is.null(ex_data) && length(ex_data$items)) {
    extras_pool <- lapply(ex_data$items, function(it) {
      list(
        chap = as.integer(it$chap %||% 0L),
        kind = it$kind %||% "short",
        difficulty = as.integer(it$difficulty %||% 2L),
        prompt = it$prompt %||% "",
        options = it$options,
        correct = it$correct %||% "",
        rubric = it$rubric %||% ""
      )
    })
  }
}
cat("Extras pool:", length(extras_pool), "instructor-authored items",
    if (file.exists(extras_file)) sprintf("from %s", extras_file) else "(no extras file present)",
    "\n")

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

# Sample COMPUTATIONAL items from exercises (existing logic, renamed).
sample_computational <- function(tmpl, seed) {
  set.seed(seed)
  n_total <- tmpl$comp_n
  candidates <- Filter(function(e) e$chap %in% tmpl$chs && !is.na(e$difficulty), pool)
  if (!length(candidates) || n_total <= 0) return(list())
  by_diff <- split(candidates, vapply(candidates, `[[`, integer(1), "difficulty"))
  picks <- list()
  for (d in c("1", "2", "3")) {
    target <- round(n_total * tmpl$mix[[d]])
    bucket <- by_diff[[d]] %||% list()
    if (length(bucket) && target > 0) {
      picks <- c(picks, bucket[sample(length(bucket), min(target, length(bucket)))])
    }
  }
  remaining <- setdiff(seq_along(candidates), match(picks, candidates))
  while (length(picks) < n_total && length(remaining)) {
    add <- sample(remaining, 1)
    picks <- c(picks, list(candidates[[add]]))
    remaining <- setdiff(remaining, add)
  }
  picks[seq_len(min(length(picks), n_total))]
}

# Sample CONCEPTUAL MCQs from Quick checks (Section A).
sample_conceptual <- function(tmpl, seed) {
  set.seed(seed + 7L)
  candidates <- Filter(function(q) q$chap %in% tmpl$chs, mcq_pool)
  # Also fold in any extras items with kind == "mcq" within the chapter range.
  extras_mcq <- Filter(function(it) it$chap %in% tmpl$chs && it$kind == "mcq",
                       extras_pool)
  if (length(extras_mcq)) candidates <- c(candidates, extras_mcq)
  n_total <- tmpl$mcq_n
  if (!length(candidates) || n_total <= 0) return(list())
  if (length(candidates) <= n_total) return(candidates)
  candidates[sample(length(candidates), n_total)]
}

# Sample EXTRAS short-answer/essay items (folds into the computational section).
sample_extras_freeform <- function(tmpl, seed) {
  set.seed(seed + 13L)
  picks <- Filter(function(it) it$chap %in% tmpl$chs && it$kind %in% c("short", "essay"),
                  extras_pool)
  picks
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

render_mcq_html <- function(q, idx) {
  opts_html <- paste(vapply(c("a","b","c","d"), function(lt) {
    val <- q$options[[lt]]
    if (is.null(val) || !nzchar(val)) return("")
    sprintf('<li>(%s) %s</li>', lt, md_inline(val))
  }, character(1)), collapse = "")
  sprintf(
    '<div class="exam-q mcq-q">
       <div class="q-head"><span class="q-num">Q%d</span><span class="q-pts">1 pt</span><span class="q-meta">Ch %d &middot; concept check &middot; <a href="misconceptions.html#ch%d">answer key</a></span></div>
       <div class="q-prompt">%s</div>
       <ol class="mcq-options">%s</ol>
       <div class="q-mcq-mark">Mark one: &nbsp; (a) &nbsp; (b) &nbsp; (c) &nbsp; (d)</div>
     </div>',
    idx, q$chap, q$chap, md_inline(q$stem), opts_html
  )
}

render_comp_html <- function(p, idx) {
  pts <- c(1L, 2L, 3L)[p$difficulty]
  meta <- if (!is.null(p$ex_num)) {
    sprintf('Ch %d &middot; %s &middot; <a href="solutions/index.html#ex-%d-%d">solution</a>',
            p$chap, escape_html(p$book_section %||% ""), p$chap, p$ex_num)
  } else {
    sprintf('Ch %d &middot; instructor-authored', p$chap)
  }
  rubric <- if (!is.null(p$rubric) && nzchar(p$rubric)) {
    sprintf('<div class="q-rubric"><strong>Rubric (instructor):</strong> %s</div>', md_inline(p$rubric))
  } else ""
  sprintf(
    '<div class="exam-q comp-q">
       <div class="q-head"><span class="q-num">Q%d</span><span class="q-pts">%d pt%s</span><span class="q-meta">%s</span></div>
       <div class="q-prompt">%s</div>
       %s
       %s
       <div class="q-workspace">Workspace:<br>&nbsp;</div>
     </div>',
    idx, pts, if (pts == 1) "" else "s",
    meta,
    md_inline(p$prompt %||% ""),
    if (nzchar(p$webr %||% "")) sprintf('<pre class="q-starter">%s</pre>', escape_html(p$webr)) else "",
    rubric
  )
}

render_exam <- function(tmpl, version, seed) {
  mcqs    <- sample_conceptual(tmpl, seed)
  comps   <- sample_computational(tmpl, seed)
  extras  <- sample_extras_freeform(tmpl, seed)
  if (!length(mcqs) && !length(comps) && !length(extras)) return(NULL)

  mcq_pts  <- length(mcqs)
  comp_pts <- sum(vapply(comps,  function(p) c(1L, 2L, 3L)[p$difficulty], integer(1)))
  extra_pts <- sum(vapply(extras, function(p) c(1L, 2L, 3L)[p$difficulty], integer(1)))
  total_pts <- mcq_pts + comp_pts + extra_pts
  total_q   <- length(mcqs) + length(comps) + length(extras)

  body <- character()
  q_idx <- 0L
  if (length(mcqs)) {
    body <- c(body, '<h3 class="exam-section-head">Section A &mdash; Concepts (multiple choice, 1 pt each)</h3>')
    for (q in mcqs) { q_idx <- q_idx + 1L; body <- c(body, render_mcq_html(q, q_idx)) }
  }
  if (length(comps) || length(extras)) {
    body <- c(body, '<h3 class="exam-section-head">Section B &mdash; Application (free response)</h3>')
    for (p in comps)  { q_idx <- q_idx + 1L; body <- c(body, render_comp_html(p, q_idx)) }
    for (p in extras) { q_idx <- q_idx + 1L; body <- c(body, render_comp_html(p, q_idx)) }
  }

  list(
    header = sprintf(
      '<section class="exam"><h2 id="%s-%s">%s &middot; Version %s</h2>
       <p class="exam-meta">%d questions (%d MCQ + %d free response) &middot; %d points &middot; chapters %s</p>',
      tmpl$id, version, escape_html(tmpl$name), version,
      total_q, length(mcqs), length(comps) + length(extras), total_pts,
      paste(range(tmpl$chs), collapse = "-")),
    body = paste(body, collapse = "\n"),
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
  '  h3.exam-section-head { margin: 1.3em 0 0.4em 0; color: #1F3A6B; font-size: 1.05em; border-bottom: 1px solid #C5D5E5; padding-bottom: 0.25em; }',
  '  .mcq-q { background: #F8FBFF; border-left-color: #76BC43; }',
  '  .comp-q { background: #FAFBFD; border-left-color: #4D93D3; }',
  '  ol.mcq-options { padding-left: 1.4em; margin: 0.4em 0; }',
  '  ol.mcq-options li { list-style: none; padding: 0.25em 0; }',
  '  .q-mcq-mark { margin-top: 0.5em; font-family: ui-monospace, monospace; color: #555; font-size: 0.9em; letter-spacing: 0.05em; }',
  '  .q-rubric { background: #FFFDE7; border-left: 3px solid #f0ad4e; padding: 0.4em 0.7em; margin-top: 0.5em; font-size: 0.88em; }',
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
