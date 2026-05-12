#!/usr/bin/env Rscript
# Facilitator-notes scaffold generator.
#
# For each chapter, emits a structured "what to say & where to pause" notes
# document at `instructor-solutions/facilitator-notes/NN_notes.qmd`, plus a
# landing page at `instructor-solutions/facilitator-notes/index.qmd`.
#
# The scaffold is *generated from the chapter content itself* so the notes
# stay in sync with the prose:
#
#   * Learning objectives  ← chapter's "In this chapter, you'll learn" callout
#   * Section breakdown    ← chapter's `## ` headings (modulo Quick checks /
#                            Exercises / Conclusion)
#   * Common stuck points  ← each Quick check's WRONG-answer explanations
#                            (which already encode common misconceptions —
#                            see "**(b)** Without a `geom_*()` layer..." etc.)
#   * Suggested timings    ← prose-word-count / 150 wpm + 2 min/section
#                            transition + 3 min per Quick check
#
# Plus *empty slots* the instructor fills in once before teaching:
#
#   * Cold open hook       (the "why this chapter matters" sentence)
#   * Cold-call moments    (which slides / sections to call on a specific student)
#   * Transition phrases   (the spoken bridge from this section to the next)
#   * Group work breaks    (2-min think-pair-share moments)
#   * Exit ticket prompt   (the 1-question recall they leave the room with)
#
# Output is gitignored; regenerate at any time:
#   Rscript scripts/build_facilitator_notes.R

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

notes_dir <- "instructor-solutions/facilitator-notes"
dir.create(notes_dir, showWarnings = FALSE, recursive = TRUE)

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

# Section headings + their position in the file (so we can slice prose for
# word counts per section).
section_table <- function(lines) {
  hits <- grep("^## [^#]", lines)
  if (!length(hits)) return(data.frame())
  titles <- sub("^##\\s+", "", lines[hits])
  titles <- sub("\\s*\\{[^}]*\\}\\s*$", "", titles)
  skip <- c("Needed packages", "Quick checks", "Exercises", "Conclusion",
            "Additional resources", "Script template")
  ends <- c(hits[-1] - 1, length(lines))
  df <- data.frame(line = hits, end = ends, title = trimws(titles),
                   stringsAsFactors = FALSE)
  df[!df$title %in% skip, ]
}

# Strip code chunks + markdown markup, count tokens.
section_word_count <- function(lines, start, end) {
  body <- lines[start:end]
  in_chunk <- FALSE
  prose <- character()
  for (l in body) {
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (!in_chunk) prose <- c(prose, l)
  }
  text <- paste(prose, collapse = " ")
  text <- gsub("`[^`]+`", " ", text)
  text <- gsub("\\*+", " ", text)
  text <- gsub("[][#>(){}|]+", " ", text)
  toks <- strsplit(text, "\\s+")[[1]]
  length(toks[nchar(toks) > 0])
}

learning_objectives <- function(lines) {
  # The book uses `::: {.callout-note title="In this chapter, you'll learn how to:"}`
  # — the heading is a callout *attribute*, not a `## In this chapter` line — so we
  # search for the title text directly, then walk forward to the closing `:::`.
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

# Quick checks: structured + extract WRONG-answer info for "stuck points".
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
    explanation <- if (!is.na(ans[1, 3])) trimws(ans[1, 3]) else ""
    out[[length(out) + 1]] <- list(
      n = as.integer(qs[i, 2]), stem = stem, options = options,
      correct = correct, explanation = explanation
    )
  }
  out
}

# Exercise difficulty mix per chapter, for sizing the homework outro.
exercise_mix <- function(chap_num) {
  yml <- sprintf("exercises/%02d.yml", chap_num)
  if (!file.exists(yml)) return(NULL)
  d <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(d) || !length(d$exercises)) return(NULL)
  diffs <- sapply(d$exercises, function(x) as.integer(x$difficulty %||% NA))
  list(
    total = length(diffs),
    by_diff = c(d1 = sum(diffs == 1, na.rm = TRUE),
                d2 = sum(diffs == 2, na.rm = TRUE),
                d3 = sum(diffs == 3, na.rm = TRUE))
  )
}

build_notes <- function(chap_num, qmd_file) {
  lines <- readLines(qmd_file, warn = FALSE)
  title <- chapter_title(lines)
  sects <- section_table(lines)
  los <- learning_objectives(lines)
  qcs <- parse_quick_checks(lines)
  mix <- exercise_mix(chap_num)

  # Per-section reading-time estimate (150 wpm).
  if (nrow(sects)) {
    wc <- mapply(section_word_count, list(lines), sects$line, sects$end)
    sects$words <- wc
    sects$minutes <- pmax(2, ceiling(wc / 150) + 2)  # +2 min transition overhead
  } else {
    sects$words <- integer()
    sects$minutes <- integer()
  }

  total_mins <- (if (nrow(sects)) sum(sects$minutes) else 0) +
                length(qcs) * 3   # 3 min per QC if used live
  hours <- floor(total_mins / 60)
  mins <- total_mins %% 60

  out <- c(
    "---",
    sprintf("title: \"Chapter %d &mdash; Facilitator notes\"", chap_num),
    sprintf("subtitle: \"%s\"", title),
    "format:",
    "  html:",
    "    theme:",
    "      light: [cosmo, ../moderndive-instructor.scss]",
    "    css: ../../style.css",
    "    toc: true",
    "    toc-location: left",
    "    toc-depth: 2",
    "    embed-resources: true",
    "    fig-align: center",
    "---",
    "",
    "::: {.callout-note title=\"How to use this page\"}",
    "This is a *scaffold*, not a script. The auto-generated parts (objectives, section breakdown, stuck points from Quick checks) come from the chapter qmd, so they stay in sync if the chapter changes. The **blank slots** &mdash; cold open, cold-call moments, transition phrases, exit ticket &mdash; are where you record what works for *your* room. Fill them in once before the lesson; they're yours forever after.",
    ":::",
    "",
    "## At a glance",
    "",
    sprintf("- **Suggested live class time:** %dh %dm (full coverage of all sections)", hours, mins),
    sprintf("- **Sections:** %d", nrow(sects)),
    sprintf("- **Quick checks available:** %d", length(qcs)),
    if (!is.null(mix)) {
      sprintf("- **End-of-chapter exercises:** %d total (%d ★ / %d ★★ / %d ★★★)",
              mix$total, mix$by_diff["d1"], mix$by_diff["d2"], mix$by_diff["d3"])
    } else "",
    "",
    "## Cold open (fill in once)",
    "",
    "_The 1-sentence reason this chapter matters that students will remember at the end._",
    "",
    "> _e.g., \"Today's the day you stop describing your data and start asking it questions you don't know the answer to.\"_",
    "",
    "**Your cold open:**",
    "",
    "```",
    "",
    "```",
    "",
    "## Learning objectives",
    "",
    "Students should leave able to:",
    ""
  )
  if (length(los)) out <- c(out, paste0("- ", los), "")
  else out <- c(out, "_(No learning objectives callout found in this chapter.)_", "")

  # Section breakdown table
  out <- c(out,
    "## Section-by-section breakdown",
    "",
    "| # | Section | Est. words | Live time |",
    "|---|---|---:|---:|"
  )
  if (nrow(sects)) {
    for (i in seq_len(nrow(sects))) {
      out <- c(out, sprintf("| %d | %s | %d | %d min |",
                            i, sects$title[i], sects$words[i], sects$minutes[i]))
    }
  } else {
    out <- c(out, "| &mdash; | _(no sections detected)_ | &mdash; | &mdash; |")
  }
  out <- c(out, "",
    "_Times = words ÷ 150 wpm + 2 min/section transition overhead. Add ~3 min per Quick check you run live._",
    "")

  # Cold-call moments
  out <- c(out,
    "## Cold-call moments (fill in)",
    "",
    "_Three specific spots where you'll call on a student by name. Spread across the lesson; pick the moments where a wrong answer is **useful** (the misconception teaches everyone)._",
    "",
    "1. Section ___ &mdash; Question: ______________",
    "2. Section ___ &mdash; Question: ______________",
    "3. Section ___ &mdash; Question: ______________",
    "",
    "## Transition phrases (fill in)",
    "",
    "_The spoken bridge from one section to the next. Even one sentence is enough &mdash; the change makes the boundary feel deliberate._",
    ""
  )
  if (nrow(sects) > 1) {
    for (i in seq_len(nrow(sects) - 1)) {
      out <- c(out, sprintf("- **%s → %s:** ______________",
                            sects$title[i], sects$title[i + 1]))
    }
  }
  out <- c(out, "")

  # Stuck points from QCs
  out <- c(out,
    "## Common stuck points",
    "",
    "_Drawn from the chapter's own Quick check distractors. Each Q lists the misconception each WRONG option encodes &mdash; if a student picks (a) when the answer is (c), here's what they're probably thinking._",
    ""
  )
  for (q in qcs) {
    if (!length(q$options)) next
    out <- c(out, sprintf("### Q%d. %s", q$n, q$stem), "")
    out <- c(out, sprintf("**Correct: (%s)** &mdash; %s", q$correct, q$explanation), "")
    out <- c(out, "**Likely traps:**", "")
    for (letter in names(q$options)) {
      if (identical(letter, q$correct)) next
      # The book's QC answer callout explains why the *correct* answer is right
      # and often (in 1 line) why the wrongs are wrong. We don't have per-option
      # rationale in YAML, so the instructor adds it inline here.
      out <- c(out, sprintf("- **(%s) %s** &mdash; _(why this is tempting: ________________)_",
                            letter, q$options[letter]))
    }
    out <- c(out, "")
  }

  # Group work + exit ticket
  out <- c(out,
    "## Group-work breaks (fill in)",
    "",
    "_Pick 1-2 spots for a 2-3 min think-pair-share. Best spots are immediately after a new concept's first worked example, while it's still fragile._",
    "",
    "- After section ___: prompt = ______________",
    "- After section ___: prompt = ______________",
    "",
    "## Exit ticket (fill in)",
    "",
    "_One recall question students answer on the way out. Single sentence. Avoid yes/no &mdash; aim for the one idea you most want them to walk out remembering._",
    "",
    "**Your exit ticket:**",
    "",
    "```",
    "",
    "```",
    "",
    "## After-class self-check",
    "",
    "_Take 60 seconds after the lesson to fill these in &mdash; future-you will thank present-you._",
    "",
    "- What landed: ______________",
    "- What didn't: ______________",
    "- Change for next time: ______________"
  )
  out
}

# Build all per-chapter notes
landing_rows <- character()
for (qf in chap_files) {
  n <- as.integer(substr(qf, 1, 2))
  if (!n %in% 1:11) next
  notes <- build_notes(n, qf)
  out_path <- file.path(notes_dir, sprintf("%02d_notes.qmd", n))
  writeLines(notes, out_path)
  cat(sprintf("Wrote %s (%d lines)\n", out_path, length(notes)))
  title <- chapter_title(readLines(qf, warn = FALSE))
  landing_rows <- c(landing_rows,
    sprintf("- [Chapter %d &mdash; %s](%02d_notes.qmd)", n, title, n))
}

# Landing page
landing <- c(
  "---",
  "title: \"ModernDive facilitator notes\"",
  "subtitle: \"Per-chapter teaching scaffold\"",
  "format:",
  "  html:",
  "    theme:",
  "      light: [cosmo, ../moderndive-instructor.scss]",
  "    css: ../../style.css",
  "    embed-resources: true",
  "---",
  "",
  "Per-chapter facilitator scaffolds. Each page combines auto-generated content (objectives, section breakdown, stuck-points from Quick check distractors) with **blank slots** for you to fill in once: cold open, cold-call moments, transition phrases, group-work breaks, exit ticket.",
  "",
  "## Chapters",
  "",
  landing_rows,
  "",
  "## Why this pairs with the slide decks",
  "",
  "The slide decks ([../slides/](../slides/)) carry the *visible* lesson &mdash; what students see on screen. The facilitator notes carry the *invisible* lesson &mdash; what you say between slides, where you pause, who you call on, what you listen for. Together they're the full teaching plan.",
  "",
  "## Design choices",
  "",
  "- **Per-section minutes** come from the chapter's own word count (150 wpm reading rate) + 2 min/section for transitions. Not a stopwatch &mdash; a budget.",
  "- **Stuck-point list** is parsed from each Quick check's lettered options. The correct option's explanation comes from the book; the *why-this-is-tempting* rationale for each wrong option is blank because that's where your room-specific experience goes.",
  "- **Fill-in slots stay together at the top** (cold open, learning objectives) so a printed page reads as a single planning sheet, not a checklist scattered across 10 pages.",
  "- **After-class self-check** lives at the bottom &mdash; you'll annotate the same page in your next teaching cycle, building a corpus of \"this worked / this didn't\" over time."
)
writeLines(landing, file.path(notes_dir, "index.qmd"))
cat(sprintf("Wrote %s/index.qmd\n", notes_dir))
