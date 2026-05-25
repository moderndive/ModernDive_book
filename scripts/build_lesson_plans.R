#!/usr/bin/env Rscript
# Lesson plan generator.
#
# For each chapter, reads:
#   * Learning objectives (the "::: {.callout-note title='In this chapter...'}"
#     callout near the top of each chapter)
#   * Section + subsection structure
#   * Quick-check count
#   * Inline learncheck count
#   * End-of-chapter exercise distribution by difficulty + group
#   * Page word count (rough reading-time estimate)
#
# Emits `instructor-solutions/lesson-plans.html` — one section per chapter
# containing a teaching plan with suggested class-time allocation.
#
# Run: Rscript scripts/build_lesson_plans.R

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

htmltools_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  x <- gsub(">", "&gt;", x, fixed = TRUE)
  x
}

chap_titles <- c(
  "1" = "Getting Started with Data in R",
  "2" = "Data Visualization",
  "3" = "Data Wrangling",
  "4" = "Data Importing and Tidy Data",
  "5" = "Simple Linear Regression",
  "6" = "Multiple Regression",
  "7" = "Sampling",
  "8" = "Confidence Intervals",
  "9" = "Hypothesis Testing",
  "10" = "Inference for Regression",
  "11" = "Tell Your Story with Data"
)

# Crude word count from a body of prose, after stripping code chunks and
# common markdown noise.
prose_word_count <- function(lines) {
  in_chunk <- FALSE
  prose <- character()
  for (l in lines) {
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (!in_chunk) prose <- c(prose, l)
  }
  text <- paste(prose, collapse = " ")
  text <- gsub("`[^`]+`", " ", text)
  text <- gsub("\\*+", " ", text)
  text <- gsub("[][#>(){}|]+", " ", text)
  toks <- strsplit(text, "\\s+")[[1]]
  toks <- toks[nchar(toks) > 0]
  length(toks)
}

# Pull a chapter's "In this chapter, you'll learn how to:" bullet list.
# Defensive: callout markup varies slightly chapter-to-chapter.
extract_learning_objectives <- function(lines) {
  start_idx <- grep("In this chapter.*you", lines)
  if (!length(start_idx)) return(character())
  start <- start_idx[1]
  # Walk forward until the closing ::: of the callout
  end <- start
  for (j in (start + 1):min(start + 40, length(lines))) {
    if (grepl("^:::\\s*$", lines[j])) { end <- j; break }
  }
  region <- lines[start:end]
  bullets <- region[grepl("^-\\s+", region)]
  sub("^-\\s+", "", bullets)
}

# Chapter section structure: list of (line, level, title) for h2/h3.
extract_sections <- function(lines) {
  in_chunk <- FALSE
  rows <- list()
  for (i in seq_along(lines)) {
    if (!in_chunk && grepl("^```\\{", lines[i])) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", lines[i])) { in_chunk <- FALSE; next }
    if (in_chunk) next
    m <- str_match(lines[i], "^(##+)\\s+([^{]+?)(?:\\s*\\{[^}]*\\})?\\s*$")
    if (!is.na(m[1, 1])) {
      lvl <- nchar(m[1, 2])
      if (lvl <= 3) {
        rows[[length(rows) + 1]] <- list(level = lvl, title = trimws(m[1, 3]))
      }
    }
  }
  rows
}

count_quick_checks <- function(lines) {
  qc_start <- grep("^## Quick checks", lines)
  if (!length(qc_start)) return(0L)
  s <- qc_start[1]
  next_h2 <- which(grepl("^## ", lines) & seq_along(lines) > s)
  e <- if (length(next_h2)) next_h2[1] - 1 else length(lines)
  length(grep("^\\*\\*Q[0-9]+\\.\\*\\*", lines[s:e]))
}

count_learning_checks <- function(lines) {
  length(grep("^::: \\{\\.learncheck\\}", lines))
}

read_exercise_summary <- function(chap) {
  yml <- sprintf("exercises/%02d.yml", chap)
  if (!file.exists(yml)) return(NULL)
  d <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(d) || !length(d$exercises)) return(NULL)
  diffs <- sapply(d$exercises, function(e) as.integer(e$difficulty %||% NA))
  groups <- sapply(d$exercises, function(e) e$group %||% "—")
  list(
    n_total = length(d$exercises),
    diff = table(factor(diffs, levels = 1:3)),
    n_groups = length(unique(groups)),
    extensions_count = sum(groups == "Extensions"),
    critical_count = sum(grepl("^Critical thinking", groups))
  )
}

# Suggested class allocation (per chapter)
suggest_class_time <- function(word_count, n_sections, n_quick_checks, n_lc) {
  # ~150 words/min reading + ~3 min per QC + ~2 min per LC + section overhead
  read_min   <- round(word_count / 150)
  qc_min     <- 3 * n_quick_checks
  lc_min     <- 2 * n_lc
  section_min <- 3 * n_sections
  total_min  <- read_min + qc_min + lc_min + section_min
  list(
    read_min = read_min,
    qc_min = qc_min,
    lc_min = lc_min,
    section_min = section_min,
    total_min = total_min,
    sessions_50min = ceiling(total_min / 50)
  )
}

# Build a per-chapter plan
chapter_plan <- function(chap) {
  f <- list.files(".", pattern = sprintf("^%02d-.*\\.qmd$", chap),
                  full.names = FALSE)
  if (!length(f)) return(NULL)
  lines <- readLines(f[1], warn = FALSE)
  list(
    chap = chap,
    file = f[1],
    title = chap_titles[as.character(chap)],
    learning_objectives = extract_learning_objectives(lines),
    sections = extract_sections(lines),
    n_quick_checks = count_quick_checks(lines),
    n_learning_checks = count_learning_checks(lines),
    exercises = read_exercise_summary(chap),
    word_count = prose_word_count(lines)
  )
}

# Render a per-chapter HTML block
render_chapter <- function(p) {
  time <- suggest_class_time(p$word_count, length(p$sections),
                              p$n_quick_checks, p$n_learning_checks)
  diff_str <- if (!is.null(p$exercises)) {
    sprintf("%d total &mdash; %d&starf; / %d&starf;&starf; / %d&starf;&starf;&starf;",
            p$exercises$n_total,
            as.integer(p$exercises$diff[["1"]] %||% 0),
            as.integer(p$exercises$diff[["2"]] %||% 0),
            as.integer(p$exercises$diff[["3"]] %||% 0))
  } else "(no exercises)"

  objectives_html <- if (length(p$learning_objectives)) {
    # Learning objectives can contain inline markdown (**LINE conditions**,
    # *grammar of graphics*, `ggplot2`). md_inline_html (from _hub_nav.R)
    # renders the inline syntax and handles HTML escaping in one pass.
    paste0("<ul>", paste(sprintf("<li>%s</li>",
                                  sapply(p$learning_objectives, md_inline_html)),
                          collapse = ""),
           "</ul>")
  } else "<em>(no learning-objectives callout found)</em>"

  sections_html <- paste(sapply(p$sections, function(s) {
    indent <- if (s$level == 2) "" else "&nbsp;&nbsp;&nbsp;&nbsp;"
    bullet <- if (s$level == 2) "&bull;" else "&deg;"
    sprintf("<li class=\"sec-l%d\">%s%s %s</li>",
            # Section titles in chapter qmds may contain inline markdown
            # (italics for emphasis, backticks for code). Render via shared
            # md_inline_html so they appear correctly.
            s$level, indent, bullet, md_inline_html(s$title))
  }), collapse = "")

  paste(c(
    sprintf('<section class="chapter">'),
    sprintf('<h2>Chapter %d — %s</h2>', p$chap, p$title),
    sprintf('<p class="meta"><strong>File:</strong> <code>%s</code> &middot; <strong>~%d words</strong> &middot; <strong>%d sections / subsections</strong></p>',
            p$file, p$word_count, length(p$sections)),
    '<div class="grid">',
    '<div class="card"><h3>Learning objectives</h3>',
    objectives_html,
    '</div>',
    '<div class="card"><h3>Time budget (approx.)</h3>',
    sprintf('<table><tr><th>Reading prose (~150 wpm)</th><td>%d min</td></tr><tr><th>%d Quick check%s (~3 min each)</th><td>%d min</td></tr><tr><th>%d learning check%s (~2 min each)</th><td>%d min</td></tr><tr><th>Section transitions (~3 min each)</th><td>%d min</td></tr><tr class="total"><th>Total</th><td><strong>%d min &asymp; %d 50-min session%s</strong></td></tr></table>',
            time$read_min,
            p$n_quick_checks, if (p$n_quick_checks == 1) "" else "s", time$qc_min,
            p$n_learning_checks, if (p$n_learning_checks == 1) "" else "s", time$lc_min,
            time$section_min,
            time$total_min, time$sessions_50min, if (time$sessions_50min == 1) "" else "s"),
    '</div>',
    '<div class="card"><h3>Exercise mix</h3>',
    sprintf('<p>%s</p>', diff_str),
    if (!is.null(p$exercises))
      sprintf('<p><small>%d distinct exercise group%s &middot; %d Extension exercise%s &middot; %d critical-thinking exercise%s</small></p>',
              p$exercises$n_groups, if (p$exercises$n_groups == 1) "" else "s",
              p$exercises$extensions_count, if (p$exercises$extensions_count == 1) "" else "s",
              p$exercises$critical_count, if (p$exercises$critical_count == 1) "" else "s")
    else "",
    '</div>',
    '</div>',
    '<details><summary>Section outline</summary>',
    '<ul class="sections">',
    sections_html,
    '</ul></details>',
    '</section>'
  ), collapse = "\n")
}

plans <- Filter(Negate(is.null), lapply(1:11, chapter_plan))

html <- c(
  '<!DOCTYPE html>',
  '<html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Per-chapter lesson plans</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1200px; margin: 2em auto; padding: 0 1.5em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.7em; margin-bottom: 0.2em; color: #1F3A6B; }',
  '  h2 { color: #1F3A6B; }',
  '  section.chapter { margin: 2.5em 0; padding: 1em 1.4em 1.5em; border-radius: 8px; background: #f7f9fc; border-left: 5px solid #1A6FBE; }',
  '  section.chapter > h2 { margin: 0; font-size: 1.35em; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; }',
  '  p.meta { color: #555; font-size: 0.95em; margin: 0.3em 0 1em; }',
  '  .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1em; margin-top: 1em; }',
  '  .card { background: white; padding: 1em 1.2em; border-radius: 6px; border: 1px solid #e0e0e0; }',
  '  .card h3 { margin: 0 0 0.6em; font-size: 1em; color: #1f4e79; }',
  '  .card table { width: 100%; border-collapse: collapse; font-size: 0.92em; }',
  '  .card th, .card td { padding: 0.25em 0.5em; text-align: left; }',
  '  .card th { font-weight: normal; color: #555; }',
  '  .card td { text-align: right; }',
  '  .card tr.total th, .card tr.total td { border-top: 1px solid #ccc; padding-top: 0.45em; }',
  '  .card ul { padding-left: 1.3em; margin: 0.3em 0; }',
  '  details { margin-top: 1em; padding: 0.5em 0.9em; background: white; border-radius: 4px; border: 1px solid #e0e0e0; }',
  '  details summary { cursor: pointer; color: #1f4e79; font-weight: 600; }',
  '  ul.sections { padding-left: 0; list-style: none; font-family: ui-monospace, "Cascadia Mono", monospace; font-size: 0.88em; line-height: 1.6; }',
  '  ul.sections li.sec-l2 { font-weight: 600; margin-top: 0.4em; }',
  '  ul.sections li.sec-l3 { color: #555; }',
  '  .intro { background: #fff3cd; padding: 1em 1.4em; border-radius: 6px; border-left: 5px solid #f0a500; margin: 1em 0 2em; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>ModernDive &mdash; Per-chapter lesson plans</h1>',
  sprintf('<p>Generated %s. Instructor-facing teaching plan for each chapter: learning objectives, section outline, exercise difficulty mix, and a rough class-time budget (reading prose at ~150 wpm + ~3 min per Quick check + ~2 min per inline Learning Check + section-transition overhead). These estimates are deliberately conservative — your students may need more or less time. Time budgets are <em>guidance</em>, not gospel.</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<div class="intro"><strong>How to use this document:</strong> Each chapter card below summarizes everything you need to plan a class session or homework set — learning objectives at the top, time budget on the side, exercise mix to choose homework from. Expand the <em>Section outline</em> to see the chapter\'s exact structure. Use this alongside the <em>exercise coverage map</em> (which shows per-section exercise coverage) and the <em>concept dependency map</em> (which shows chapter-to-chapter dependencies).</div>',
  unlist(lapply(plans, render_chapter)),
  '</body></html>'
)

dir.create("instructor-solutions", showWarnings = FALSE)
dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out_path <- "instructor-solutions/_site/lesson-plans.html"
writeLines(html, out_path)
cat(sprintf("Wrote %s (%d chapters)\n", out_path, length(plans)))
