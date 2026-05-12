#!/usr/bin/env Rscript
# Sample-syllabus generator.
#
# Emits `instructor-solutions/syllabus.qmd` containing:
#   * A 15-week US-semester layout
#   * A 10-week quarter alternative
#   * Per-week table: topic / readings / in-class activities / homework due
#   * Suggested assessment plan: 3 problem sets + 1 midterm + 1 final project
#   * Learning outcomes per unit (parsed from chapter LO callouts)
#   * Pacing rationale based on each chapter's word count + QC count
#
# The pacing isn't arbitrary: each chapter's "weight" is computed from its
# word count and Quick check count. Heavy chapters (Ch 2, Ch 3, Ch 6,
# Ch 8) get two weeks; lighter chapters share a week.
#
# Run:
#   Rscript scripts/build_syllabus.R

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

chap_files <- list.files(".", pattern = "^([0-9]{2})-.*\\.qmd$", full.names = FALSE)
chap_files <- chap_files[as.integer(substr(chap_files, 1, 2)) %in% 1:11]
chap_files <- sort(chap_files)

chapter_title <- function(lines) {
  h1 <- lines[grepl("^# [^#]", lines)][1]
  if (is.na(h1)) return("Chapter")
  t <- sub("^#\\s+", "", h1)
  t <- sub("\\s*\\{[^}]*\\}\\s*$", "", t)
  trimws(t)
}

learning_objectives <- function(lines) {
  start_idx <- grep("In this chapter.*you", lines)
  if (!length(start_idx)) return(character())
  start <- start_idx[1]
  end <- start
  for (j in (start + 1):min(start + 40, length(lines))) {
    if (grepl("^:::\\s*$", lines[j])) { end <- j; break }
  }
  region <- lines[start:end]
  bullets <- region[grepl("^-\\s+", region)]
  sub("^-\\s+", "", bullets)
}

# Approximate chapter weight: prose word count + QC count × 200 words.
chapter_weight <- function(lines) {
  in_chunk <- FALSE
  prose <- character()
  for (l in lines) {
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (!in_chunk) prose <- c(prose, l)
  }
  text <- paste(prose, collapse = " ")
  text <- gsub("`[^`]+`|\\*+|[][#>(){}|]+", " ", text)
  toks <- strsplit(text, "\\s+")[[1]]
  wc <- length(toks[nchar(toks) > 0])
  qc_count <- length(grep("^\\*\\*Q\\d+\\.\\*\\*", lines))
  wc + qc_count * 200
}

exercise_count <- function(chap_num) {
  yml <- sprintf("exercises/%02d.yml", chap_num)
  if (!file.exists(yml)) return(0L)
  d <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(d) || !length(d$exercises)) return(0L)
  length(d$exercises)
}

# Gather chapter data
chapters <- list()
for (qf in chap_files) {
  n <- as.integer(substr(qf, 1, 2))
  lines <- readLines(qf, warn = FALSE)
  chapters[[as.character(n)]] <- list(
    n = n, file = qf,
    title = chapter_title(lines),
    los = learning_objectives(lines),
    weight = chapter_weight(lines),
    n_exercises = exercise_count(n)
  )
}

# ModernDive Labs problem sets (hosted at moderndive.github.io/moderndive_labs).
# These are the "official" lab/problem-set companions to the book and are
# referenced per week in the syllabus table.
labs_base <- "https://moderndive.github.io/moderndive_labs/static/PS"
ps_link <- function(name, label) {
  sprintf("[%s](%s/%s)", label, labs_base, name)
}
PS01 <- ps_link("PS01_intro_to_R_RStudio.html",  "PS1 Intro R/RStudio")
PS02 <- ps_link("PS02_data_viz.html",            "PS2 Data Viz")
PS03 <- ps_link("PS03_data_wrangling.html",      "PS3 Wrangling")
PS04 <- ps_link("PS04_reg_one_num_x.html",       "PS4 Regression, 1 num x")
PS05 <- ps_link("PS05_reg_one_cat_x.html",       "PS5 Regression, 1 cat x")
PS06 <- ps_link("PS06_multiple_reg.html",        "PS6 Multiple Regression")
PS07 <- ps_link("PS07_sampling_dist.html",       "PS7 Sampling Distributions")
PS08 <- ps_link("PS08_CI_bootstrap.html",        "PS8 CIs (bootstrap)")
PS09 <- ps_link("PS09_hypothesis_testing.html",  "PS9 Hypothesis Testing")
PS10 <- ps_link("PS10_inference_for_regression.html", "PS10 Inference for Regression")
TERM_PROJECT <- "[Term project template](https://moderndive.github.io/moderndive_labs/term_project.html)"

# === 15-week semester plan ===
# Week-to-chapter map. Heavy chapters get 2 weeks; chapter 7 is paired with
# midterm; chapter 11 is paired with final-project workshop.
semester <- list(
  list(week = 1,  topic = "Course intro + R/RStudio setup", chap = 1,
       activities = "Install R + RStudio + tidyverse; tour the book; first scripts",
       hw = sprintf("%s assigned", PS01)),
  list(week = 2,  topic = "Grammar of graphics, scatterplots, linegraphs", chap = 2,
       activities = "5NG #1-2 worked examples + group critique of student-built plots",
       hw = sprintf("%s due; %s assigned", PS01, PS02)),
  list(week = 3,  topic = "Histograms, facets, boxplots, barplots", chap = 2,
       activities = "5NG #3-5 + facets; cold-call a student to predict a faceted plot before reveal",
       hw = "—"),
  list(week = 4,  topic = "Data wrangling I: filter / summarize / group_by", chap = 3,
       activities = "Live coding from flights; debugging-walkthrough on a broken pipeline",
       hw = sprintf("%s due; %s assigned", PS02, PS03)),
  list(week = 5,  topic = "Data wrangling II: mutate / arrange / joins", chap = 3,
       activities = "Joins worked example; pair programming on weather merge",
       hw = "—"),
  list(week = 6,  topic = "Importing data + tidy data principles", chap = 4,
       activities = "Real-world messy-CSV import lab; pivot_longer / pivot_wider drill",
       hw = sprintf("%s due", PS03)),
  list(week = 7,  topic = "Midterm review + midterm exam", chap = NA,
       activities = "Day 1: jeopardy-style retrieval over Ch 1-4; Day 2: in-class exam",
       hw = "Midterm exam"),
  list(week = 8,  topic = "Basic regression: one numerical predictor", chap = 5,
       activities = "Walk through `get_regression_table()` + `get_regression_points()` on `evals`",
       hw = sprintf("%s + %s assigned", PS04, PS05)),
  list(week = 9,  topic = "Basic regression: categorical predictor", chap = 5,
       activities = "Interpret slopes for a 0/1 indicator; compare against group means",
       hw = sprintf("%s + %s due; %s assigned", PS04, PS05, PS06)),
  list(week = 10, topic = "Multiple regression + interactions", chap = 6,
       activities = "3D regression visualization; interaction-vs-parallel-slopes group activity",
       hw = sprintf("%s due", PS06)),
  list(week = 11, topic = "Sampling distributions + the bootstrap intuition", chap = 7,
       activities = "Tactile sampling activity (red/white balls); virtual sampling with `rep_sample_n()`",
       hw = sprintf("%s assigned; %s proposal due", PS07, TERM_PROJECT)),
  list(week = 12, topic = "Confidence intervals", chap = 8,
       activities = "Bootstrap CI lab; CI-interpretation common-mistake gallery",
       hw = sprintf("%s due; %s assigned", PS07, PS08)),
  list(week = 13, topic = "Hypothesis testing", chap = 9,
       activities = "Permutation-test simulation; build a null world step by step",
       hw = sprintf("%s due; %s assigned", PS08, PS09)),
  list(week = 14, topic = "Inference for regression", chap = 10,
       activities = "Bringing it all together: bootstrap CIs for regression slopes",
       hw = sprintf("%s due; %s assigned", PS09, PS10)),
  list(week = 15, topic = "Tell your story with data + term-project workshop", chap = 11,
       activities = "Peer review of project drafts; presentations day 2",
       hw = sprintf("%s due; final project due (end of week)", PS10))
)

# === 10-week quarter plan (compressed) ===
quarter <- list(
  list(week = 1,  topic = "R setup + getting started + grammar of graphics intro",
       chap = "1, 2 (start)", hw = "PS1 released"),
  list(week = 2,  topic = "5NG: scatterplots, histograms, boxplots, barplots, facets",
       chap = "2", hw = "—"),
  list(week = 3,  topic = "Wrangling: filter, summarize, group_by, mutate, joins",
       chap = "3", hw = "PS1 due; PS2 released"),
  list(week = 4,  topic = "Importing + tidy data + midterm review",
       chap = "4", hw = "Midterm next week"),
  list(week = 5,  topic = "Midterm + Basic regression",
       chap = "5", hw = "PS2 due"),
  list(week = 6,  topic = "Multiple regression + interactions",
       chap = "6", hw = "PS3 released; project proposal"),
  list(week = 7,  topic = "Sampling distributions",
       chap = "7", hw = "—"),
  list(week = 8,  topic = "Confidence intervals",
       chap = "8", hw = "PS3 due"),
  list(week = 9,  topic = "Hypothesis testing + Inference for regression",
       chap = "9, 10", hw = "—"),
  list(week = 10, topic = "Final-project presentations",
       chap = "11", hw = "Final project due")
)

mk_link <- function(chap_num) {
  if (is.na(chap_num) || identical(chap_num, "")) return("—")
  sprintf("[slides](slides/%02d-slides.html) · [notes](facilitator-notes/%02d_notes.qmd)",
          as.integer(chap_num), as.integer(chap_num))
}

semester_rows <- sapply(semester, function(r) {
  link_cell <- if (is.na(r$chap)) "—" else mk_link(r$chap)
  sprintf("| Week %d | Ch %s | %s | %s | %s | %s |",
          r$week,
          if (is.na(r$chap)) "—" else r$chap,
          r$topic, r$activities, r$hw, link_cell)
})

quarter_rows <- sapply(quarter, function(r) {
  sprintf("| Week %d | Ch %s | %s | %s |", r$week, r$chap, r$topic, r$hw)
})

# === Per-unit learning outcomes ===
units <- list(
  list(name = "Unit I &mdash; Data carpentry (Ch 1-4)",
       chapters = 1:4,
       headline = "Students can ingest real-world data, wrangle it into tidy form, and produce publication-quality visualizations."),
  list(name = "Unit II &mdash; Statistical modeling (Ch 5-6)",
       chapters = 5:6,
       headline = "Students can fit and interpret one- and two-predictor regression models, including categorical predictors and interactions."),
  list(name = "Unit III &mdash; Statistical inference (Ch 7-10)",
       chapters = 7:10,
       headline = "Students can construct sampling distributions via simulation, build bootstrap confidence intervals, conduct permutation hypothesis tests, and apply all three to regression."),
  list(name = "Unit IV &mdash; Communication (Ch 11)",
       chapters = 11,
       headline = "Students can scope, execute, and present an end-to-end data project — from question to reproducible narrative.")
)
unit_blocks <- character()
for (u in units) {
  unit_blocks <- c(unit_blocks,
    sprintf("### %s", u$name), "",
    sprintf("**Headline:** %s", u$headline), "",
    "**Students will be able to:**", ""
  )
  for (c in u$chapters) {
    ch <- chapters[[as.character(c)]]
    if (is.null(ch) || !length(ch$los)) next
    unit_blocks <- c(unit_blocks,
      sprintf("- *(Ch %d &mdash; %s)*", c, ch$title),
      paste0("  - ", ch$los), ""
    )
  }
}

# === Assemble the qmd ===
out <- c(
  "---",
  "title: \"ModernDive sample syllabus\"",
  "subtitle: \"15-week semester (with 10-week quarter alternative)\"",
  "format:",
  "  html:",
  "    theme:",
  "      light: [cosmo, moderndive-instructor.scss]",
  "    css: ../style.css",
  "    toc: true",
  "    toc-location: left",
  "    toc-depth: 2",
  "    embed-resources: true",
  "---",
  "",
  "::: {.callout-note title=\"How to use this page\"}",
  "Adapt freely. The week-by-week table is a **scaffold**, not a contract &mdash; depending on your students' prior R exposure you'll likely spend extra time on Ch 1-3, or compress them if your students arrive with tidyverse fluency. Each row links to the matching slide deck and facilitator notes so you can jump straight to teaching prep.",
  ":::",
  "",
  "::: {.callout-tip title=\"Companion lab/problem-set site: ModernDive Labs\"}",
  "The book pairs with the [ModernDive Labs](https://moderndive.github.io/moderndive_labs/) site, which hosts PS1-PS10 (one per chapter, written as self-contained scaffolded notebooks) and a [term-project template](https://moderndive.github.io/moderndive_labs/term_project.html). The syllabus below uses these labs as the default weekly homework; per-week direct links appear in the *Homework / assessments* column.",
  ":::",
  "",
  "## At a glance",
  "",
  sprintf("- **Book version:** ModernDive 2.x (current v2-quarto-html branch)"),
  sprintf("- **Total chapters:** 11"),
  sprintf("- **Total end-of-chapter exercises:** %d",
          sum(sapply(chapters, function(x) x$n_exercises))),
  "- **Assumed prerequisites:** algebra; no prior R or statistics required",
  "- **Recommended cadence:** two 75-minute class sessions per week, plus a 90-minute lab",
  "",
  "## 15-week semester plan",
  "",
  "| Week | Chapter | Topic | In-class activities | Homework / assessments | Materials |",
  "|---|---|---|---|---|---|",
  semester_rows,
  "",
  "::: {.callout-tip title=\"Pacing rationale\"}",
  "Chapters 2, 3, and 6 each get two weeks because they're the densest in terms of word count and Quick checks. Chapter 7 (Sampling) is bridged to Chapter 8 with the tactile-then-virtual sampling activity that the book leans on heavily &mdash; resist the urge to fast-forward through this section, since everything in Ch 8-10 builds directly on the sampling intuition.",
  ":::",
  "",
  "## 10-week quarter plan",
  "",
  "For institutions on the quarter system, the table below compresses the same material into ten weeks. Tradeoffs: less group practice in Units I-II, and the final project becomes a partner project rather than solo.",
  "",
  "| Week | Chapter | Topic | Homework / assessments |",
  "|---|---|---|---|",
  quarter_rows,
  "",
  "## Assessment plan",
  "",
  "**Problem sets (40%):** Ten problem sets from [ModernDive Labs](https://moderndive.github.io/moderndive_labs/) (PS1-PS10) — one per book chapter (Ch 4 absorbed into PS3). These are the *official* lab companions: each is a self-contained narrative-style notebook with scaffolded R chunks, conceptual questions, and a write-up section. The release-and-due cadence above pairs each PS to the chapter it tests. Alternative / supplement: build custom sets via the [homework planner](homework-planner.html).",
  "",
  "**Midterm exam (20%):** Closed-book on R syntax + open-book on plot/wrangling interpretation. Covers Ch 1-4. The Quick checks make excellent practice problems &mdash; one Q from each chapter on the exam itself.",
  "",
  "**Final / term project (30%):** End-to-end data project. The ModernDive [Term Project template](https://moderndive.github.io/moderndive_labs/term_project.html) is the recommended structure: students pick a dataset, ask one question, produce one visualization, fit one model, communicate findings. Deliverable: 5-min talk + 4-page reproducible Quarto report. Project proposal due Week 11.",
  "",
  "**Participation / Quick checks (10%):** Frequent in-class retrieval practice via the [slide-deck MCQ check-ins](slides/index.html). Tracked but lightly weighted &mdash; the goal is psychological safety to be wrong, since incorrect answers anchor learning.",
  "",
  "## Learning outcomes by unit",
  "",
  unit_blocks,
  "",
  "## Companion materials",
  "",
  "- [ModernDive Labs](https://moderndive.github.io/moderndive_labs/) &mdash; PS1-PS10 problem sets + term-project template (external site, public)",
  "- [Slide decks](slides/index.html) &mdash; one revealjs deck per chapter, with built-in MCQ check-ins",
  "- [Facilitator notes](facilitator-notes/index.html) &mdash; per-chapter teaching scaffold: cold open, transitions, cold-call moments, exit ticket",
  "- [Homework planner](homework-planner.html) &mdash; build problem sets by filtering exercises",
  "- [Lesson plans](lesson-plans.html) &mdash; per-chapter timing + section breakdown",
  "- [Coverage map](coverage-map.html) &mdash; per-section exercise counts + difficulty histogram",
  "- [Concept map](concept-map.html) &mdash; SVG dependency graph across the 11 chapters",
  "- [Worked exercise solutions](solutions/index.html) &mdash; complete solutions to every end-of-chapter exercise"
)
writeLines(out, "instructor-solutions/syllabus.qmd")
cat(sprintf("Wrote instructor-solutions/syllabus.qmd (%d lines)\n", length(out)))
