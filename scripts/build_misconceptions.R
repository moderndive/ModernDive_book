#!/usr/bin/env Rscript
# Misconceptions cheat-sheet.
#
# Auto-extracted from each chapter's Quick check questions. A Quick check is
# multiple-choice; the WRONG-answer options encode the misconceptions the
# chapter author expected students to have. This script flattens those wrong
# options into a single per-chapter "if a student answers (b) instead of the
# correct (c), they're probably thinking…" reference an instructor can scan
# before a lecture.
#
# Overlaps with facilitator-notes.html's stuck-points section but with a
# different optimisation: facilitator notes are per-chapter teaching
# scaffolds; this is a cross-chapter searchable reference. Useful for
# quickly answering "which chapters cover misconception X?".
#
# Run:  Rscript scripts/build_misconceptions.R

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

chap_titles <- c(
  "1" = "Getting started",          "2"  = "Visualization",
  "3" = "Wrangling",                "4"  = "Tidy data",
  "5" = "Regression",               "6"  = "Multiple regression",
  "7" = "Sampling",                 "8"  = "Confidence intervals",
  "9" = "Hypothesis testing",       "10" = "Inference for regression",
  "11" = "Tell your story with data"
)

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Identical Quick-check parser to build_facilitator_notes.R (kept inline to
# avoid a cross-file source() dependency in CI).
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

# Per-chapter Quick checks
chapters <- sprintf("%02d", 1:11)
all_qcs <- list()
for (ch in chapters) {
  qmd <- list.files(".", pattern = paste0("^", ch, "-.*\\.qmd$"))
  if (!length(qmd)) next
  lines <- readLines(qmd[1], warn = FALSE)
  qcs <- parse_quick_checks(lines)
  if (length(qcs)) {
    all_qcs[[ch]] <- list(chap = as.integer(ch),
                          title = chap_titles[[as.character(as.integer(ch))]],
                          qcs = qcs)
  }
}

# --- Render HTML -----------------------------------------------------------
escape_html <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;",  s, fixed = TRUE)
  s <- gsub(">", "&gt;",  s, fixed = TRUE)
  s
}
# Lightweight markdown -> HTML for inline code + emphasis (sufficient for
# Quick-check stems, which use very simple markdown).
md_inline <- function(s) {
  s <- escape_html(s)
  s <- gsub("`([^`]+)`", "<code>\\1</code>", s)
  s <- gsub("\\*\\*([^*]+)\\*\\*", "<strong>\\1</strong>", s)
  s <- gsub("\\*([^*]+)\\*", "<em>\\1</em>", s)
  s <- gsub("\\$([^$]+)\\$", "\\\\(\\1\\\\)", s)  # math: $x$ -> \(x\)
  s
}

chap_blocks <- character()
total_qcs <- 0
total_distractors <- 0
for (entry in all_qcs) {
  qc_html <- character()
  for (q in entry$qcs) {
    total_qcs <- total_qcs + 1
    # Filter to wrong options (distractors = misconceptions).
    wrong_letters <- setdiff(names(q$options), q$correct)
    total_distractors <- total_distractors + length(wrong_letters)
    if (!length(wrong_letters)) next
    wrong_rows <- vapply(wrong_letters, function(lt) {
      sprintf('<tr><td class="opt-letter">(%s)</td><td class="opt-text">%s</td></tr>',
              lt, md_inline(q$options[[lt]]))
    }, character(1))
    correct_html <- if (nzchar(q$correct)) {
      sprintf('<div class="correct-answer"><span class="ans-tag">Correct: (%s)</span> %s%s</div>',
              q$correct,
              md_inline(q$options[[q$correct]] %||% ""),
              if (nzchar(q$explanation)) paste0(' <span class="why">— ', md_inline(q$explanation), '</span>') else "")
    } else ""
    qc_html <- c(qc_html, paste0(
      '<div class="qc">',
      sprintf('<div class="qc-stem"><strong>Q%d.</strong> %s</div>', q$n, md_inline(q$stem)),
      correct_html,
      '<div class="distractor-label">Distractors (what students who pick these are probably thinking):</div>',
      '<table class="distractor-table"><tbody>',
      paste(wrong_rows, collapse = "\n"),
      '</tbody></table>',
      '</div>'
    ))
  }
  chap_blocks <- c(chap_blocks, paste0(
    sprintf('<h2 id="ch%d">Chapter %d: %s <span class="qc-count">(%d Quick checks)</span></h2>',
            entry$chap, entry$chap, escape_html(entry$title), length(entry$qcs)),
    paste(qc_html, collapse = "\n")
  ))
}

# Build a topic-search index: chapter, Q#, stem, all option texts
search_data <- list()
for (entry in all_qcs) {
  for (q in entry$qcs) {
    all_opts <- paste(q$options, collapse = " ")
    search_data[[length(search_data) + 1]] <- sprintf(
      '{"ch":%d,"q":%d,"text":"%s"}',
      entry$chap, q$n,
      tolower(gsub('"', '\\\\"', paste(q$stem, all_opts, q$explanation)))
    )
  }
}

html <- paste(c(
  '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Misconceptions cheat-sheet</title>',
  '<script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1100px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.6em; margin-bottom: 0.2em; color: #1F3A6B; }',
  '  h2 { font-size: 1.2em; margin-top: 2.2em; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; color: #1F3A6B; }',
  '  .qc-count { font-size: 0.85em; color: #555; font-weight: normal; }',
  '  .qc { background: #FAFBFD; border-left: 4px solid #4D93D3; padding: 0.9em 1.1em; margin: 0.9em 0; border-radius: 4px; }',
  '  .qc-stem { margin-bottom: 0.6em; }',
  '  .correct-answer { background: #E8F3E5; border-left: 3px solid #76BC43; padding: 0.4em 0.8em; margin: 0.5em 0; border-radius: 3px; font-size: 0.94em; }',
  '  .ans-tag { color: #4A7A2C; font-weight: 600; font-size: 0.86em; }',
  '  .why { color: #4A4A4A; font-style: italic; }',
  '  .distractor-label { color: #888; font-size: 0.85em; font-style: italic; margin: 0.6em 0 0.3em 0; }',
  '  table.distractor-table { border-collapse: collapse; width: 100%; font-size: 0.93em; }',
  '  table.distractor-table td { padding: 0.4em 0.6em; vertical-align: top; }',
  '  .opt-letter { color: #C0392B; font-weight: 600; width: 2.5em; }',
  '  .opt-text { background: #FFF6F4; border-left: 2px solid #E8B4AB; padding-left: 0.8em; }',
  '  code { background: #F0F4F8; padding: 0.05em 0.3em; border-radius: 3px; font-size: 0.92em; color: #1F3A6B; }',
  '  nav.chapter-jump { margin: 1em 0; font-size: 0.92em; }',
  '  nav.chapter-jump a { display: inline-block; margin-right: 0.6em; color: #1A6FBE; text-decoration: none; padding: 0.2em 0.5em; border-radius: 3px; }',
  '  nav.chapter-jump a:hover { background: #F0F4F8; }',
  '  #search-box { width: 100%; max-width: 28em; padding: 0.55em 0.8em; border: 1px solid #C5D5E5; border-radius: 4px; font-size: 1em; margin: 0.5em 0 1.5em 0; }',
  '  .qc.hidden { display: none; }',
  '  h2.hidden { display: none; }',
  '</style></head><body>',
  '<h1>Misconceptions cheat-sheet</h1>',
  sprintf('<p>Generated %s. Each chapter\'s Quick-check <em>wrong-answer options</em> distilled into a one-place reference. The wrong answers were written deliberately to encode tempting-but-incorrect reasoning &mdash; this page presents them so you can pre-empt the confusion in lecture or office hours.</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  sprintf('<p><strong>Coverage:</strong> %d Quick checks across %d chapters, %d distractor explanations.</p>',
          total_qcs, length(all_qcs), total_distractors),
  '<input type="text" id="search-box" placeholder="Filter by keyword (e.g., p-value, residual, bootstrap)…" />',
  '<nav class="chapter-jump">Jump to: ',
  paste(sprintf('<a href="#ch%d">Ch %d</a>', 1:11, 1:11), collapse = ""),
  '</nav>',
  paste(chap_blocks, collapse = "\n"),
  '<script>',
  '  const box = document.getElementById("search-box");',
  '  box.addEventListener("input", () => {',
  '    const q = box.value.trim().toLowerCase();',
  '    let anyShown = false;',
  '    document.querySelectorAll("h2").forEach(h => h.classList.remove("hidden"));',
  '    document.querySelectorAll(".qc").forEach(qc => {',
  '      const txt = qc.textContent.toLowerCase();',
  '      const match = !q || txt.includes(q);',
  '      qc.classList.toggle("hidden", !match);',
  '      if (match) anyShown = true;',
  '    });',
  '    document.querySelectorAll("h2").forEach(h => {',
  '      let p = h.nextElementSibling, hasVis = false;',
  '      while (p && p.tagName !== "H2") {',
  '        if (p.classList && p.classList.contains("qc") && !p.classList.contains("hidden")) { hasVis = true; break; }',
  '        p = p.nextElementSibling;',
  '      }',
  '      h.classList.toggle("hidden", !hasVis);',
  '    });',
  '  });',
  '</script>',
  '</body></html>'
), collapse = "\n")

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out <- "instructor-solutions/_site/misconceptions.html"
writeLines(html, out)
cat(sprintf("Wrote %s (%d chapters, %d Quick checks, %d distractor explanations)\n",
            out, length(all_qcs), total_qcs, total_distractors))
