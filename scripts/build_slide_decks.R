#!/usr/bin/env Rscript
# ModernDive slide-deck generator.
#
# For each chapter qmd (01-getting-started ... 11-tell-your-story...), emits
# `instructor-solutions/slides/NN-slides.qmd` — a revealjs deck themed in the
# ModernDive hex-sticker palette (navy / blue / green) with learning-sciences
# retrieval-practice features baked in:
#
#   * Title slide                               — hex watermark + chapter title
#   * Learning objectives                       — pulled from chapter callout
#   * "From last time" warm-up (Ch >= 2)        — pulls 1 QC from prior chapter
#   * Per `##` section:
#       - Section divider slide
#       - Skeleton content slide(s)
#       - One MCQ check-in slide (rotates through chapter's Quick checks so
#         every QC ends up on a slide; instructors pick which to use live)
#   * Wrap-up retrieval slide (3 reflection prompts)
#   * Cliffhanger pointing to next chapter
#
# Quick checks already follow a uniform format (`**QN.** stem`, lettered
# options, `::: {.callout-tip ... } **(X)** explanation :::`) — the parser
# below extracts these into structured MCQs that the slide template renders
# as click-to-vote / click-to-reveal blocks.
#
# Output is gitignored; regenerate at any time:
#   Rscript scripts/build_slide_decks.R

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

slides_dir <- "instructor-solutions/slides"
dir.create(slides_dir, showWarnings = FALSE, recursive = TRUE)

chap_files <- list.files(".", pattern = "^([0-9]{2})-.*\\.qmd$", full.names = FALSE)
chap_files <- chap_files[as.integer(substr(chap_files, 1, 2)) %in% 1:11]
chap_files <- sort(chap_files)

# Pretty chapter titles (extracted from the `# Title {#sec-x}` line).
chapter_title <- function(lines) {
  h1 <- lines[grepl("^# [^#]", lines)][1]
  if (is.na(h1)) return("Chapter")
  t <- sub("^#\\s+", "", h1)
  t <- sub("\\s*\\{[^}]*\\}\\s*$", "", t)
  trimws(t)
}

# Top-level `## Section` headings. Skip "Needed packages", "Quick checks",
# "Exercises", "Conclusion" — those become their own slides separately.
section_headings <- function(lines) {
  hits <- grep("^## [^#]", lines, value = TRUE)
  titles <- sub("^##\\s+", "", hits)
  titles <- sub("\\s*\\{[^}]*\\}\\s*$", "", titles)
  skip <- c("Needed packages", "Quick checks", "Exercises", "Conclusion",
            "Additional resources")
  titles <- titles[!titles %in% skip]
  trimws(titles)
}

# Learning objectives from "you'll learn" callout.
learning_objectives <- function(lines) {
  # Book convention: `::: {.callout-note title="In this chapter, you'll learn how to:"}`
  # — heading text lives in the callout's title attribute, not as a `##`. Find that
  # line, walk forward to the closing `:::`, collect bullets.
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

# Parse a chapter's Quick checks into structured records.
# Returns a list of list(stem, options, correct_letter, explanation).
parse_quick_checks <- function(lines) {
  text <- paste(lines, collapse = "\n")
  # Find "## Quick checks" section
  qc_idx <- grep("^##\\s+Quick checks", lines)
  if (!length(qc_idx)) return(list())
  # Slice from QC heading to next `^## ` heading
  next_h <- grep("^## ", lines)
  next_h <- next_h[next_h > qc_idx[1]]
  end <- if (length(next_h)) next_h[1] - 1 else length(lines)
  block <- lines[qc_idx[1]:end]
  block_text <- paste(block, collapse = "\n")
  # Split on each **QN.** marker; capture stem + options + answer
  qs <- str_match_all(block_text,
    "(?s)\\*\\*Q(\\d+)\\.\\*\\*\\s+(.+?)(?=\\n\\*\\*Q\\d+\\.\\*\\*|\\Z)")[[1]]
  out <- list()
  if (!nrow(qs)) return(out)
  for (i in seq_len(nrow(qs))) {
    raw <- qs[i, 3]
    # Stem = text up to the first option (a.) line
    stem <- sub("(?s)\\n[a-d]\\.\\s.*", "", raw, perl = TRUE)
    stem <- trimws(stem)
    # Options
    opt_match <- str_match_all(raw, "(?m)^([a-d])\\.\\s+(.+)$")[[1]]
    options <- if (nrow(opt_match)) setNames(opt_match[, 3], opt_match[, 2]) else character()
    # Answer callout
    ans <- str_match(raw,
      "(?s):::\\s*\\{\\.callout-tip[^}]*\\}\\s*\\n\\*\\*\\(([a-d])\\)\\*\\*\\s*(.*?)\\n:::")
    correct <- if (!is.na(ans[1, 2])) ans[1, 2] else ""
    explanation <- if (!is.na(ans[1, 3])) trimws(ans[1, 3]) else ""
    out[[length(out) + 1]] <- list(
      n = as.integer(qs[i, 2]),
      stem = stem, options = options,
      correct = correct, explanation = explanation
    )
  }
  out
}

# Render an MCQ block as the deck's `.mcq` HTML structure.
mcq_html <- function(q, chap, idx_in_chap) {
  if (!length(q$options)) return("")
  # Escape any double-quotes in stem/options
  esc <- function(x) gsub("\"", "&quot;", x)
  opts_html <- paste(sprintf("<li>%s</li>", esc(unname(q$options))), collapse = "\n  ")
  explanation <- esc(q$explanation)
  c(
    sprintf("::: {.mcq data-correct=\"%s\"}", q$correct),
    sprintf("<div class=\"mcq-stem\">Q%d. %s</div>", q$n, esc(q$stem)),
    "<ol class=\"mcq-options\">",
    paste0("  ", opts_html),
    "</ol>",
    "<div class=\"mcq-controls\">",
    "<button class=\"poll-btn show-poll\">Show class poll</button>",
    "<button class=\"show-answer\">Show answer</button>",
    "</div>",
    "<div class=\"poll-bar\"></div>",
    sprintf("<div class=\"mcq-reveal\"><strong>(%s)</strong> %s</div>",
            q$correct, explanation),
    ":::",
    ""
  )
}

# Build the full deck for one chapter.
build_deck <- function(chap_num, qmd_file, prev_qcs) {
  lines <- readLines(qmd_file, warn = FALSE)
  title <- chapter_title(lines)
  sections <- section_headings(lines)
  los <- learning_objectives(lines)
  qcs <- parse_quick_checks(lines)

  out <- c(
    "---",
    sprintf("title: \"Chapter %d &mdash; %s\"", chap_num, title),
    "subtitle: \"ModernDive instructor slide deck\"",
    "author: \"ModernDive team\"",
    "format:",
    "  revealjs:",
    "    theme: [default, moderndive-slides.scss]",
    "    slide-number: c/t",
    "    preview-links: auto",
    "    chalkboard: false",
    "    incremental: false",
    "    transition: fade",
    "    background-transition: fade",
    "    fig-align: center",
    "    code-line-numbers: false",
    "    include-in-header:",
    "      text: |",
    "        <link rel=\"icon\" href=\"../../images/logos/favicons/favicon.ico\">",
    "    include-after-body:",
    "      text: |",
    "        <script src=\"moderndive-slides.js\"></script>",
    "---",
    "",
    "## Welcome back, divers {.section-break}",
    "",
    sprintf("**Chapter %d — %s**", chap_num, title),
    "",
    "Slides are a *scaffold*: one idea per slide, frequent retrieval check-ins, predict-then-check prompts. Click through and pause where you like.",
    ""
  )

  # === Spaced-practice warm-up (Ch 2+): one MCQ from prior chapter ===
  if (length(prev_qcs)) {
    warmup <- prev_qcs[[1]]
    out <- c(out,
      "## From last time {.section-break}",
      "",
      sprintf("Last lesson we covered material from **Chapter %d**. Before today's content, let's bring it back:", chap_num - 1),
      "",
      "::: {.recap}",
      "Spaced retrieval boosts long-term retention more than re-reading. We'll do this every class.",
      ":::",
      "",
      "## Warm-up retrieval",
      "",
      mcq_html(warmup, chap_num - 1, 0),
      ""
    )
  }

  # === Learning objectives ===
  if (length(los)) {
    out <- c(out,
      "## What you'll be able to do",
      "",
      "By the end of this chapter, you will be able to:",
      "",
      paste0("- ", los),
      "",
      "::: {.predict}",
      "Before we begin: which of these objectives feels least familiar to you right now? Hold that in mind — we'll check back at the end.",
      ":::",
      ""
    )
  }

  # === Per-section content + one MCQ per section ===
  # Distribute QCs across sections round-robin (each section gets one MCQ if
  # we have enough; otherwise repeat the last one).
  for (i in seq_along(sections)) {
    sect <- sections[i]
    out <- c(out,
      sprintf("## %s {.section-break}", sect),
      "",
      sprintf("Section %d of %d", i, length(sections)),
      "",
      sprintf("## %s &mdash; key idea", sect),
      "",
      sprintf("**Instructor note:** anchor this section in one concrete example from the chapter (e.g., the `flights` data, a `ggplot` worked example, or a code chunk). One idea per slide; resist the urge to put the whole section on one screen."),
      "",
      sprintf("## %s &mdash; live code", sect),
      "",
      "::: {.try-this}",
      "Open RStudio (or paste into the book's webR block) and run the canonical example for this section. Ask one student to predict the output **before** running.",
      ":::",
      "",
      "```r",
      "# Replace with the section's canonical code chunk.",
      "library(moderndive)",
      "library(tidyverse)",
      "",
      "# e.g.,",
      "# flights |> ggplot(aes(x = dep_delay)) + geom_histogram()",
      "```",
      ""
    )
    # MCQ check-in (round-robin from chapter QCs)
    if (length(qcs)) {
      q <- qcs[[((i - 1) %% length(qcs)) + 1]]
      out <- c(out,
        sprintf("## Check-in: %s", sect),
        "",
        "::: {.predict}",
        "Take 30 seconds. Predict your answer **before** clicking. Then tap your choice.",
        ":::",
        "",
        mcq_html(q, chap_num, i),
        ""
      )
    }
  }

  # === Recap / retrieval ===
  out <- c(out,
    "## Wrap-up retrieval {.section-break}",
    "",
    "Without scrolling back:",
    "",
    "1. **One thing** that surprised you today.",
    "2. **One thing** you can already explain to a classmate.",
    "3. **One thing** you'd like more practice with before the next class.",
    "",
    "::: {.try-this}",
    "Write your answers in your notes app or on paper. Brief retrieval *immediately after* learning is the single highest-leverage study habit (Roediger & Karpicke, 2006).",
    ":::",
    ""
  )

  # === Cliffhanger ===
  if (chap_num < 11) {
    out <- c(out,
      "## Next time",
      "",
      sprintf("Chapter %d builds directly on what we covered today. Skim the *Needed packages* and *Learning objectives* sections before class — even 5 minutes pre-reading triples comprehension in the first 10 minutes.", chap_num + 1),
      ""
    )
  } else {
    out <- c(out,
      "## You did it!",
      "",
      "You've worked through every chapter of *ModernDive*. Keep the book bookmarked — the glossary, exercise sets, and webR runners stay alive for as long as you want to come back to them.",
      ""
    )
  }

  out
}

# Build all decks, tracking previous chapter's QCs for spaced warm-ups.
prev_qcs <- list()
landing_rows <- character()

for (qf in chap_files) {
  n <- as.integer(substr(qf, 1, 2))
  if (!n %in% 1:11) next
  deck <- build_deck(n, qf, prev_qcs)
  out_path <- file.path(slides_dir, sprintf("%02d-slides.qmd", n))
  writeLines(deck, out_path)
  cat(sprintf("Wrote %s (%d lines)\n", out_path, length(deck)))
  # Capture this chapter's QCs as next chapter's warm-up source
  this_qcs <- parse_quick_checks(readLines(qf, warn = FALSE))
  prev_qcs <- this_qcs
  title <- chapter_title(readLines(qf, warn = FALSE))
  landing_rows <- c(landing_rows,
    sprintf("- [Chapter %d &mdash; %s](%02d-slides.html)", n, title, n))
}

# === Landing page ===
landing <- c(
  "---",
  "title: \"ModernDive slide decks\"",
  "format:",
  "  html:",
  "    theme:",
  "      light: [cosmo, ../moderndive-instructor.scss]",
  "    css: ../../style.css",
  "    embed-resources: true",
  "---",
  "",
  "Per-chapter [revealjs](https://quarto.org/docs/presentations/revealjs/) decks, themed in the ModernDive hex-sticker palette. Each deck is a *scaffold*, not a script — replace placeholder content with your own examples and let the retrieval check-ins drive the cadence.",
  "",
  "## Decks",
  "",
  landing_rows,
  "",
  "## Learning-sciences features baked in",
  "",
  "- **Retrieval practice** — every section has an MCQ check-in (sourced from the book's existing Quick checks). Brief, low-stakes recall is the single most effective in-class technique ([Roediger & Karpicke, 2006](https://www.learningscientists.org/blog/2016/6/23-1)).",
  "- **Spaced practice** — Chapter $N \\geq 2$ decks open with one MCQ from Chapter $N - 1$. Five minutes of warm-up retrieval beats 15 minutes of re-reading.",
  "- **Predict-then-check** — `predict` callouts ask students to commit to an answer *before* the reveal. Encoding effort is what makes retrieval stick.",
  "- **Interleaving** — section dividers visually separate ideas; one idea per content slide reduces cognitive load.",
  "- **Accessible by default** — `prefers-reduced-motion` disables hover transforms; high-contrast hex-sticker palette meets WCAG AA on title slides.",
  "",
  "## How the in-slide poll works",
  "",
  "Tap an option to *select* it (highlighted but no judgment). The instructor clicks **Show class poll** to display the cumulative tap counts as bar widths, then **Show answer** to reveal the correct option and explanation.",
  "",
  "For real polling with student devices, swap in your tool of choice (Poll Everywhere, Slido, Mentimeter, Wooclap) — the slide structure already accommodates the pattern: stem, options, reveal-after-discussion."
)
writeLines(landing, file.path(slides_dir, "index.qmd"))
cat(sprintf("Wrote %s/index.qmd\n", slides_dir))
