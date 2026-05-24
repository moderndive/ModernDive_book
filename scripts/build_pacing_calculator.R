#!/usr/bin/env Rscript
# Course-pacing calculator.
#
# Interactive HTML page: instructor inputs how many weeks the course runs
# and how many class-minutes per week. Output: a suggested chapter-per-week
# allocation that fits inside the budget, plus a flagged set of sections
# that could be trimmed if you need to compress further.
#
# Chapter time budgets come from `suggest_class_time()` in
# build_lesson_plans.R (~150 wpm reading + 3 min/Quick check + 2 min/Learning
# Check + 3 min/section transition). We compute that here from each
# chapter's qmd so this script is self-contained — no source() into the
# lesson-plans script (CI invokes the scripts independently).
#
# All the layout-fitting happens client-side in pure JS so the page is
# self-contained and reactive.
#
# Run:  Rscript scripts/build_pacing_calculator.R

suppressPackageStartupMessages({
  library(stringr)
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

# Per-chapter metrics: word count, section count, Quick check count,
# Learning check count. Same heuristics as build_lesson_plans.R.
chapter_metrics <- function(qmd) {
  lines <- readLines(qmd, warn = FALSE)
  in_chunk <- FALSE
  prose <- character()
  for (l in lines) {
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (in_chunk) next
    prose <- c(prose, l)
  }
  prose_text <- paste(prose, collapse = " ")
  # Strip markdown markers, math, code
  prose_text <- gsub("`[^`]*`", "", prose_text)
  prose_text <- gsub("\\$[^$]*\\$", "", prose_text)
  prose_text <- gsub("[#*_\\[\\]()<>|]", " ", prose_text)
  words <- str_extract_all(prose_text, "[A-Za-z]+")[[1]]
  # Count "real" sections (## headings that aren't Needed packages / Quick
  # checks / Exercises / Conclusion / Additional resources).
  section_lines <- grep("^##\\s+", lines, value = TRUE)
  skip_names <- c("Needed packages", "Quick checks", "Exercises", "Conclusion",
                  "Additional resources")
  n_sections <- sum(!vapply(section_lines, function(s) {
    any(vapply(skip_names, function(nm) grepl(nm, s, fixed = TRUE), logical(1)))
  }, logical(1)))
  list(
    word_count        = length(words),
    n_sections        = n_sections,
    n_quick_checks    = 0L,  # filled in later
    n_learning_checks = length(grep(".learncheck", lines, fixed = TRUE))
  )
}

# Simpler & more reliable Quick-check count
qc_count <- function(qmd) {
  txt <- paste(readLines(qmd, warn = FALSE), collapse = "\n")
  m <- str_extract_all(txt, "\\*\\*Q\\d+\\.\\*\\*")[[1]]
  length(m)
}

suggest_minutes <- function(word_count, n_sections, n_qc, n_lc) {
  read_min   <- as.integer(round(word_count / 150))
  qc_min     <- 3L * as.integer(n_qc)
  lc_min     <- 2L * as.integer(n_lc)
  section_min <- 3L * as.integer(n_sections)
  as.integer(read_min + qc_min + lc_min + section_min)
}

chapter_data <- list()
for (ch in 1:11) {
  qmd <- list.files(".", pattern = sprintf("^%02d-.*\\.qmd$", ch))
  if (!length(qmd)) next
  metrics <- chapter_metrics(qmd[1])
  metrics$n_quick_checks <- qc_count(qmd[1])
  total_min <- suggest_minutes(metrics$word_count, metrics$n_sections,
                               metrics$n_quick_checks, metrics$n_learning_checks)
  chapter_data[[length(chapter_data) + 1]] <- list(
    chap = ch,
    title = chap_titles[[as.character(ch)]],
    total_min = total_min,
    word_count = metrics$word_count,
    n_sections = metrics$n_sections,
    n_quick_checks = metrics$n_quick_checks,
    n_learning_checks = metrics$n_learning_checks
  )
}

# JS-ready data
chap_json <- paste0(
  vapply(chapter_data, function(c) {
    sprintf(
      '{"chap":%d,"title":"%s","total_min":%d,"words":%d,"sections":%d,"qcs":%d,"lcs":%d}',
      c$chap, c$title, c$total_min, c$word_count, c$n_sections,
      c$n_quick_checks, c$n_learning_checks
    )
  }, character(1)),
  collapse = ","
)

# --- Render HTML -----------------------------------------------------------
html <- paste(c(
  '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Course-pacing calculator</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1080px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.6em; color: #1F3A6B; margin-bottom: 0.2em; }',
  '  h2 { font-size: 1.2em; margin-top: 2em; color: #1F3A6B; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; }',
  '  .controls { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1em; background: #F0F4F8; padding: 1.2em; border-radius: 8px; margin: 1em 0; }',
  '  .control label { display: block; font-size: 0.85em; color: #555; margin-bottom: 0.2em; }',
  '  .control input { width: 100%; padding: 0.45em 0.6em; border: 1px solid #C5D5E5; border-radius: 4px; font-size: 1em; }',
  '  .summary { background: #FAFBFD; border-left: 4px solid #76BC43; padding: 0.8em 1em; margin: 1em 0; border-radius: 4px; }',
  '  .summary.warn { border-left-color: #f0ad4e; background: #FFF6E5; }',
  '  .summary.over  { border-left-color: #C0392B; background: #FFEDEA; }',
  '  table.plan { border-collapse: collapse; width: 100%; margin: 1em 0; }',
  '  table.plan th { background: #F0F4F8; padding: 0.5em 0.8em; text-align: left; font-size: 0.9em; }',
  '  table.plan td { padding: 0.5em 0.8em; border-bottom: 1px solid #E5E5E5; vertical-align: top; }',
  '  table.plan .week-label { font-weight: 600; color: #1F3A6B; white-space: nowrap; }',
  '  table.plan .mins { font-variant-numeric: tabular-nums; color: #555; font-size: 0.92em; }',
  '  table.plan .over .mins { color: #C0392B; font-weight: 600; }',
  '  ul.compress-list { font-size: 0.92em; }',
  '  ul.compress-list li { margin: 0.3em 0; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>Course-pacing calculator</h1>',
  sprintf('<p>Generated %s. Plug in how long your term is and how much class time you have; the calculator fits chapters into weeks using each chapter\'s word count, section count, and Quick-/Learning-check counts. Time per chapter is conservative (~150 wpm + 3 min/QC + 2 min/LC + 3 min/section transition).</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<div class="controls">',
  '  <div class="control"><label>Weeks of instruction</label><input type="number" id="weeks" value="15" min="6" max="20"></div>',
  '  <div class="control"><label>Class minutes / week</label><input type="number" id="class-mpw" value="150" min="50" max="500" step="10"></div>',
  '  <div class="control"><label>Out-of-class study min / week</label><input type="number" id="study-mpw" value="180" min="0" max="600" step="15"></div>',
  '</div>',
  '<div id="summary" class="summary"></div>',
  '<h2>Suggested chapter-by-week plan</h2>',
  '<table class="plan" id="plan-table"><thead><tr><th>Week</th><th>Chapters</th><th class="mins">Required minutes</th><th class="mins">Cumulative</th></tr></thead><tbody></tbody></table>',
  '<h2>If you need to compress further</h2>',
  '<p>If the plan above shows chapters running over the per-week budget, consider tightening these (ranked by skippability — chapters with the most Quick checks have the most fat to trim):</p>',
  '<ul class="compress-list" id="compress-list"></ul>',
  '<h2>Per-chapter time budget (raw)</h2>',
  '<table class="plan" id="budget-table"><thead><tr><th>Chapter</th><th>Title</th><th class="mins">Words</th><th class="mins">Sections</th><th class="mins">QCs</th><th class="mins">LCs</th><th class="mins">Total min</th></tr></thead><tbody></tbody></table>',
  '<script>',
  sprintf('const chapters = [%s];', chap_json),
  '  const fmt = n => Number.isFinite(n) ? n.toLocaleString() : "—";',
  '  function render() {',
  '    const weeks    = +document.getElementById("weeks").value || 15;',
  '    const class_m  = +document.getElementById("class-mpw").value || 150;',
  '    const study_m  = +document.getElementById("study-mpw").value || 180;',
  '    const budget_m = class_m + study_m;',
  '    const total_m  = chapters.reduce((s,c) => s+c.total_min, 0);',
  '    const target_per_week = total_m / weeks;',
  '    // Greedy bin-pack chapters into weeks, never splitting a chapter',
  '    const plan = []; let cur = []; let curMin = 0; let cum = 0;',
  '    for (const c of chapters) {',
  '      if (curMin > 0 && curMin + c.total_min > budget_m * 1.2 && plan.length < weeks - 1) {',
  '        plan.push({chs: cur, mins: curMin}); cur = []; curMin = 0;',
  '      }',
  '      cur.push(c); curMin += c.total_min;',
  '    }',
  '    if (cur.length) plan.push({chs: cur, mins: curMin});',
  '    // Pad to # weeks',
  '    while (plan.length < weeks) plan.push({chs: [], mins: 0});',
  '    // Summary block',
  '    const summary = document.getElementById("summary");',
  '    const fits = plan.length <= weeks && Math.max(...plan.map(p=>p.mins)) <= budget_m * 1.2;',
  '    summary.className = "summary" + (fits ? "" : (plan.length > weeks ? " over" : " warn"));',
  '    summary.innerHTML = `<strong>Total course load:</strong> ${fmt(total_m)} min across ${chapters.length} chapters. ` +',
  '      `<strong>Your budget:</strong> ${fmt(weeks * budget_m)} min (${weeks} weeks × ${budget_m} min/wk = ${class_m} class + ${study_m} out-of-class). ` +',
  '      (fits ? "<span style=\\"color:#4A7A2C\\">Fits comfortably.</span>" :',
  '              plan.length > weeks ? "<span style=\\"color:#C0392B\\">Overflowing &mdash; will not fit; consider trimming sections.</span>" :',
  '                                    "<span style=\\"color:#8a6d3b\\">Tight &mdash; some weeks above per-week budget.</span>");',
  '    // Plan table',
  '    const planBody = document.querySelector("#plan-table tbody");',
  '    planBody.innerHTML = "";',
  '    let running = 0;',
  '    for (let i = 0; i < weeks; i++) {',
  '      const p = plan[i] || {chs:[], mins:0};',
  '      running += p.mins;',
  '      const tr = document.createElement("tr");',
  '      if (p.mins > budget_m * 1.2) tr.classList.add("over");',
  '      tr.innerHTML = `<td class="week-label">Week ${i+1}</td>` +',
  '        `<td>${p.chs.length ? p.chs.map(c => `Ch ${c.chap}: <em>${c.title}</em>`).join("<br>") : "<span style=\\"color:#aaa\\">(buffer)</span>"}</td>` +',
  '        `<td class="mins">${fmt(p.mins)} / ${fmt(budget_m)}</td>` +',
  '        `<td class="mins">${fmt(running)}</td>`;',
  '      planBody.appendChild(tr);',
  '    }',
  '    // Compress list — chapters sorted by QC density (more QCs = more skippable)',
  '    const compress = [...chapters].sort((a,b) => (b.qcs/Math.max(1,b.sections)) - (a.qcs/Math.max(1,a.sections))).slice(0,5);',
  '    const cl = document.getElementById("compress-list");',
  '    cl.innerHTML = compress.map(c => `<li><strong>Ch ${c.chap}: ${c.title}</strong> — ${c.qcs} Quick checks across ${c.sections} sections (~${c.total_min} min). Skipping or assigning Quick checks as homework instead of in-class would save ~${3*c.qcs} min.</li>`).join("");',
  '    // Budget table',
  '    const budgetBody = document.querySelector("#budget-table tbody");',
  '    budgetBody.innerHTML = chapters.map(c =>',
  '      `<tr><td>Ch ${c.chap}</td><td><em>${c.title}</em></td><td class="mins">${fmt(c.words)}</td><td class="mins">${c.sections}</td><td class="mins">${c.qcs}</td><td class="mins">${c.lcs}</td><td class="mins"><strong>${fmt(c.total_min)}</strong></td></tr>`).join("");',
  '  }',
  '  document.querySelectorAll("#weeks, #class-mpw, #study-mpw").forEach(el => el.addEventListener("input", render));',
  '  render();',
  '</script>',
  '</body></html>'
), collapse = "\n")

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out <- "instructor-solutions/_site/pacing-calculator.html"
writeLines(html, out)
total_min <- sum(vapply(chapter_data, function(c) as.integer(c$total_min), integer(1)))
cat(sprintf("Wrote %s (%d chapters, total %d min budget)\n",
            out, length(chapter_data), total_min))
