#!/usr/bin/env Rscript
# Exercise coverage map.
#
# For each chapter (1–11), reads `exercises/NN.yml` and produces an
# instructor-facing HTML report that shows:
#
#   * Per-section: a list of exercise IDs (collapsed to en-dash ranges)
#     and a difficulty histogram (counts of ★, ★★, ★★★).
#   * Per-subsection (where present): same.
#   * A chapter summary header with total exercise count + total difficulty
#     distribution.
#
# Writes to `instructor-solutions/coverage-map.html` (gitignored — the
# coverage map is a snapshot, regenerated on demand).
#
# Run:  Rscript scripts/exercise_coverage_map.R

suppressPackageStartupMessages({
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Minimal HTML escape so section names with `<`, `>`, `&` render correctly.
htmltools_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;",  x, fixed = TRUE)
  x <- gsub(">", "&gt;",  x, fixed = TRUE)
  x
}

# Collapse consecutive ex_nums into en-dash ranges. Cribbed from
# scripts/exercise_helpers.R to avoid sourcing the full helper (which
# pulls in render-time deps).
collapse_runs <- function(ids) {
  if (!length(ids)) return("")
  parts <- character()
  start <- ids[1]; prev <- ids[1]
  flush <- function(s, e) {
    if (e - s >= 2) sprintf("%d&ndash;%d", s, e)
    else if (e == s) sprintf("%d", s)
    else sprintf("%d, %d", s, e)
  }
  for (i in seq_along(ids)[-1]) {
    if (ids[i] == prev + 1) prev <- ids[i]
    else {
      parts <- c(parts, flush(start, prev))
      start <- ids[i]; prev <- ids[i]
    }
  }
  parts <- c(parts, flush(start, prev))
  paste(parts, collapse = ", ")
}

# Build per-chapter section / subsection summaries
chapter_summary <- function(chap) {
  yml_path <- sprintf("exercises/%02d.yml", chap)
  if (!file.exists(yml_path)) return(NULL)
  d <- yaml::read_yaml(yml_path)
  if (!length(d$exercises)) return(NULL)

  rows <- lapply(d$exercises, function(e) data.frame(
    ex_num     = as.integer(e$ex_num),
    difficulty = as.integer(e$difficulty %||% NA),
    section    = e$book_section    %||% "(unspecified)",
    subsection = e$book_subsection %||% "(unspecified)",
    stringsAsFactors = FALSE
  ))
  ex <- do.call(rbind, rows)

  list(
    chap = chap,
    coverage_note = d$chapter_meta$coverage_note %||% NA_character_,
    n_total = nrow(ex),
    diff_dist = table(factor(ex$difficulty, levels = 1:3)),
    section_order = unique(ex$section),
    by_section = lapply(unique(ex$section), function(s) {
      sub_ex <- ex[ex$section == s, , drop = FALSE]
      list(
        section = s,
        n = nrow(sub_ex),
        ids = collapse_runs(sort(sub_ex$ex_num)),
        diff_dist = table(factor(sub_ex$difficulty, levels = 1:3)),
        by_subsection = lapply(unique(sub_ex$subsection), function(ss) {
          ssx <- sub_ex[sub_ex$subsection == ss, , drop = FALSE]
          list(
            subsection = ss,
            n = nrow(ssx),
            ids = collapse_runs(sort(ssx$ex_num)),
            diff_dist = table(factor(ssx$difficulty, levels = 1:3))
          )
        })
      )
    })
  )
}

# Render a per-row coverage cell: e.g.,
#   "12 — EX5.2&ndash;EX5.4, EX5.10 ★★★ (3 × 1, 5 × 2, 4 × 3)"
diff_badge <- function(d) {
  stars <- c("★", "★★", "★★★")
  vals <- as.integer(d)
  parts <- character()
  for (i in seq_along(vals)) {
    if (vals[i] > 0) parts <- c(parts, sprintf("%s &times;%d", stars[i], vals[i]))
  }
  if (!length(parts)) return("")
  paste0("<span class='diff'>", paste(parts, collapse = " &middot; "), "</span>")
}

# Build the HTML
all_summaries <- Filter(Negate(is.null), lapply(1:11, chapter_summary))

html <- c(
  '<!DOCTYPE html>',
  '<html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Exercise coverage map</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1100px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.4; }',
  '  h1   { font-size: 1.6em; margin-bottom: 0.2em; }',
  '  h2   { font-size: 1.3em; border-bottom: 1px solid #ccc; padding-bottom: 0.2em; margin-top: 2.5em; }',
  '  h3   { font-size: 1.05em; color: #444; margin-top: 1.4em; }',
  '  table { border-collapse: collapse; margin: 0.6em 0 1em; width: 100%; }',
  '  th   { background: #f4f4f4; padding: 0.35em 0.6em; text-align: left; font-weight: 600; }',
  '  td   { padding: 0.35em 0.6em; border-top: 1px solid #eee; vertical-align: top; }',
  '  td.section { font-weight: 500; }',
  '  td.subsection { color: #555; padding-left: 1.6em; font-size: 0.92em; }',
  '  td.n   { text-align: right; width: 4em; color: #666; }',
  '  td.ids { font-family: ui-monospace, "Cascadia Mono", "JetBrains Mono", monospace; font-size: 0.92em; color: #04395e; }',
  '  td.diff { width: 14em; font-size: 0.85em; color: #555; }',
  '  .summary { background: #f8fafc; padding: 0.7em 1em; border-left: 4px solid #5b9bd5; margin: 1em 0; }',
  '  .note { background: #fff8e1; padding: 0.7em 1em; border-left: 4px solid #f0a500; font-size: 0.93em; margin: 1em 0; }',
  '  .total-tag { color: #888; font-weight: normal; font-size: 0.85em; }',
  '  .low-coverage { color: #c0392b; font-weight: 600; }',
  '</style></head><body>',
  '<h1>ModernDive &mdash; Exercise coverage map</h1>',
  sprintf('<p>Snapshot generated %s. Per-chapter exercise distribution by section / subsection, with difficulty histograms. <em>Low coverage</em> = sections with 1 or 0 exercises.</p>',
          format(Sys.Date(), "%Y-%m-%d"))
)

for (s in all_summaries) {
  total_diff <- diff_badge(s$diff_dist)
  html <- c(html,
    sprintf('<h2>Chapter %d <span class="total-tag">(%d exercises &middot; %s)</span></h2>',
            s$chap, s$n_total, total_diff))
  if (!is.na(s$coverage_note)) {
    html <- c(html,
      sprintf('<div class="note">%s</div>',
              gsub("\n", "<br>", s$coverage_note)))
  }
  html <- c(html,
    '<table>',
    '<tr><th>Section / subsection</th><th class="n">N</th><th>Exercise IDs</th><th>Difficulty</th></tr>')
  for (sec in s$by_section) {
    low <- if (sec$n <= 1) " low-coverage" else ""
    html <- c(html,
      sprintf('<tr><td class="section%s">%s</td><td class="n">%d</td><td class="ids">EX%d.%s</td><td class="diff">%s</td></tr>',
              low, htmltools_escape(sec$section), sec$n, s$chap, sec$ids, diff_badge(sec$diff_dist)))
    for (sub in sec$by_subsection) {
      if (identical(sub$subsection, sec$section)) next  # same name; don't duplicate
      html <- c(html,
        sprintf('<tr><td class="subsection">%s</td><td class="n">%d</td><td class="ids">EX%d.%s</td><td class="diff">%s</td></tr>',
                htmltools_escape(sub$subsection), sub$n, s$chap, sub$ids, diff_badge(sub$diff_dist)))
    }
  }
  html <- c(html, '</table>')
}

html <- c(html, '</body></html>')

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out_path <- "instructor-solutions/_site/coverage-map.html"
writeLines(html, out_path)
cat(sprintf("Wrote %s (%d chapters covered)\n", out_path, length(all_summaries)))
