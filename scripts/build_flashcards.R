#!/usr/bin/env Rscript
# Flashcard deck generator for the glossary.
#
# Parses 96-glossary.qmd's `## Term name {#sec-gloss-slug .unnumbered}` blocks
# and emits importable decks for student-side review:
#
#   * flashcards.tsv  — Anki-importable (tab-separated: Front, Back, Tags)
#                       Anki users: File > Import > .tsv, set field separator
#                       to TAB, allow HTML in fields, map to Basic note type.
#   * flashcards.csv  — Quizlet-importable (comma-separated: Front, Back)
#                       Quizlet users: Create > +Set > Import > paste CSV;
#                       configure comma between term/definition.
#   * flashcards.html — landing page on the instructor hub with download links,
#                       a preview, and per-tool import instructions.
#
# Tags are inferred from cross-references in each definition body:
#   * "@sec-grammarofgraphics" → ch02 (Quarto cross-ref → chapter via lookup)
#   * If no chapter cross-ref is found, tag as `ch00-reference`.
#
# Run:  Rscript scripts/build_flashcards.R

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Chapter-section ID → chapter number lookup. Glossary entries link out
# via `@sec-...`; we map those to chapter tags so flashcards filter by
# chapter in Anki / Quizlet.
chapter_qmds <- list.files(".", pattern = "^[0-9]{2}-.*\\.qmd$", full.names = FALSE)
secid_to_chap <- list()
for (qmd in chapter_qmds) {
  ch <- as.integer(substr(qmd, 1, 2))
  if (is.na(ch) || ch < 1 || ch > 11) next
  lines <- readLines(qmd, warn = FALSE)
  # Match {#sec-foo} or {#sec-foo .unnumbered} forms
  matches <- regmatches(lines, regexec("\\{#(sec-[A-Za-z0-9_-]+)", lines))
  for (m in matches) {
    if (length(m) >= 2 && nzchar(m[2])) {
      secid_to_chap[[m[2]]] <- ch
    }
  }
}
cat(sprintf("Indexed %d chapter section IDs from %d chapter qmds\n",
            length(secid_to_chap), length(chapter_qmds)))

# Parse the glossary file.
glossary_file <- "96-glossary.qmd"
if (!file.exists(glossary_file)) {
  stop(sprintf("Glossary file not found: %s", glossary_file))
}
gloss_lines <- readLines(glossary_file, warn = FALSE)

# Find every term heading: ## Term name {#sec-gloss-slug .unnumbered}
heading_idx <- grep("^##\\s+.+\\{#sec-gloss-", gloss_lines)
cat(sprintf("Found %d glossary entries\n", length(heading_idx)))

# Extract front / back / tags for each entry.
cards <- list()
for (i in seq_along(heading_idx)) {
  h <- heading_idx[i]
  end <- if (i < length(heading_idx)) heading_idx[i + 1] - 1L else length(gloss_lines)
  header <- gloss_lines[h]
  # Pull the term name (text between "## " and " {")
  term <- sub("^##\\s+", "", header)
  term <- sub("\\s*\\{#sec-gloss-.*$", "", term)
  term <- trimws(term)
  if (!nzchar(term)) next

  body_lines <- gloss_lines[(h + 1):end]
  # Drop horizontal rules + empty leading/trailing lines
  body_lines <- body_lines[!grepl("^---\\s*$", body_lines)]
  while (length(body_lines) && !nzchar(trimws(body_lines[1])))
    body_lines <- body_lines[-1]
  while (length(body_lines) && !nzchar(trimws(body_lines[length(body_lines)])))
    body_lines <- body_lines[-length(body_lines)]
  body <- paste(body_lines, collapse = " ")
  body <- gsub("\\s+", " ", body)

  # Find chapter cross-refs in the body (@sec-foo) and derive tags
  xrefs <- regmatches(body, gregexpr("@(sec-[A-Za-z0-9_-]+)", body))[[1]]
  xrefs <- sub("^@", "", xrefs)
  chap_nums <- unique(unlist(lapply(xrefs, function(x) secid_to_chap[[x]])))
  chap_nums <- chap_nums[!is.na(chap_nums)]
  tags <- if (length(chap_nums)) {
    paste0("ModernDive::Ch", sprintf("%02d", sort(chap_nums)))
  } else {
    "ModernDive::Reference"
  }

  # Clean body for flashcard back: strip cross-refs, keep markdown lightly,
  # convert backticks to plain (Anki HTML import handles inline HTML, but
  # plain reads better in Quizlet too).
  back <- body
  back <- gsub("\\s*\\(See\\s+@sec-[A-Za-z0-9_-]+\\)\\.?", "", back)
  back <- gsub("\\s*See\\s+@sec-[A-Za-z0-9_-]+\\.", "", back)
  back <- gsub("@sec-[A-Za-z0-9_-]+", "", back)
  back <- gsub("`([^`]+)`", "\\1", back)  # strip backticks
  back <- gsub("\\s+", " ", back)
  back <- trimws(back)

  cards[[length(cards) + 1]] <- list(
    front = term, back = back, tags = paste(tags, collapse = " ")
  )
}
cat(sprintf("Parsed %d cards\n", length(cards)))

# Output directory
out_dir <- "instructor-solutions/_site"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# --- TSV (Anki-importable) -------------------------------------------------
tsv_lines <- c(
  "#separator:tab",
  "#html:true",
  "#tags column:3",
  paste(c("Front", "Back", "Tags"), collapse = "\t")
)
for (c in cards) {
  # Anki TSV: replace literal tabs in fields; preserve quotes; allow HTML
  front <- gsub("\t", " ", c$front)
  back  <- gsub("\t", " ", c$back)
  tags  <- gsub("\t", " ", c$tags)
  tsv_lines <- c(tsv_lines, paste(front, back, tags, sep = "\t"))
}
tsv_out <- file.path(out_dir, "flashcards.tsv")
writeLines(tsv_lines, tsv_out)
cat(sprintf("Wrote %s (%d cards, Anki TSV)\n", tsv_out, length(cards)))

# --- CSV (Quizlet-importable) ----------------------------------------------
csv_escape <- function(s) {
  if (grepl('[",\n]', s)) {
    s <- gsub('"', '""', s, fixed = TRUE)
    s <- paste0('"', s, '"')
  }
  s
}
csv_lines <- c('"Front","Back","Tags"')
for (c in cards) {
  csv_lines <- c(csv_lines, paste(
    csv_escape(c$front), csv_escape(c$back), csv_escape(c$tags),
    sep = ","))
}
csv_out <- file.path(out_dir, "flashcards.csv")
writeLines(csv_lines, csv_out)
cat(sprintf("Wrote %s (%d cards, CSV)\n", csv_out, length(cards)))

# --- Landing HTML ----------------------------------------------------------
escape_html <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;",  s, fixed = TRUE)
  s <- gsub(">", "&gt;",  s, fixed = TRUE)
  s
}
# Preview: first 8 cards
preview_rows <- character()
for (c in head(cards, 8)) {
  preview_rows <- c(preview_rows, sprintf(
    '<tr><td><strong>%s</strong></td><td>%s</td><td><code>%s</code></td></tr>',
    escape_html(c$front),
    escape_html(substr(c$back, 1, 200)),
    escape_html(c$tags)
  ))
}

# Per-chapter counts (parse tag string)
chap_counts <- table(unlist(lapply(cards, function(c) {
  tags <- strsplit(c$tags, " ")[[1]]
  tags
})))
chap_table_rows <- character()
for (tag in names(sort(chap_counts, decreasing = FALSE))) {
  chap_table_rows <- c(chap_table_rows,
    sprintf('<tr><td><code>%s</code></td><td style="text-align:right">%d</td></tr>',
            escape_html(tag), chap_counts[[tag]]))
}

html <- paste(c(
  '<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Flashcards</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 920px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { color: #1F3A6B; border-bottom: 3px solid #1A6FBE; padding-bottom: 0.3em; }',
  '  h2 { color: #1F3A6B; border-bottom: 1px solid #C5D5E5; padding-bottom: 0.25em; margin-top: 2em; }',
  '  table { border-collapse: collapse; width: 100%; margin: 1em 0; }',
  '  th, td { border-bottom: 1px solid #DDE5EE; padding: 0.5em 0.7em; text-align: left; vertical-align: top; }',
  '  th { background: #EEF6FF; color: #1F3A6B; }',
  '  .dl-card { background: #F8FBFF; border: 1px solid #C5D5E5; border-left: 4px solid #4D93D3; padding: 1em 1.2em; border-radius: 6px; margin: 0.9em 0; }',
  '  .dl-card h3 { margin: 0 0 0.3em 0; color: #1F3A6B; font-size: 1.1em; }',
  '  .dl-card a.dl { display: inline-block; background: #1A6FBE; color: white; padding: 0.4em 1em; border-radius: 4px; text-decoration: none; margin: 0.4em 0; font-weight: 600; }',
  '  .dl-card a.dl:hover { background: #1F3A6B; }',
  '  .dl-card ol { font-size: 0.94em; margin: 0.4em 0 0.4em 1.5em; padding: 0; }',
  '  .dl-card li { margin: 0.2em 0; }',
  '  code { background: #F0F4F8; padding: 0.05em 0.3em; border-radius: 3px; font-size: 0.92em; color: #1F3A6B; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>Flashcard deck</h1>',
  sprintf('<p>%d cards generated from the book glossary. Tagged by chapter so students can filter to "just Ch 8" or "everything before the midterm". Two formats — pick the tool your students already use.</p>',
          length(cards)),
  '<h2>Downloads</h2>',
  '<div class="dl-card">',
  '<h3>Anki (recommended for spaced repetition)</h3>',
  sprintf('<a class="dl" href="flashcards.tsv">Download flashcards.tsv</a>'),
  '<ol>',
  '<li>Install <a href="https://apps.ankiweb.net/">Anki</a> (free, desktop + mobile)</li>',
  '<li>Open Anki &rarr; <em>File &rarr; Import</em> &rarr; pick <code>flashcards.tsv</code></li>',
  '<li>Field separator: <strong>Tab</strong> &middot; Allow HTML in fields: <strong>Yes</strong></li>',
  '<li>Note type: <strong>Basic</strong> &middot; Map Field 1 to <em>Front</em>, Field 2 to <em>Back</em>, Field 3 to <em>Tags</em></li>',
  '<li>Click Import. Cards land in a new deck; filter by tag (e.g., <code>ModernDive::Ch08</code>) for chapter-specific review.</li>',
  '</ol>',
  '</div>',
  '<div class="dl-card">',
  '<h3>Quizlet</h3>',
  sprintf('<a class="dl" href="flashcards.csv">Download flashcards.csv</a>'),
  '<ol>',
  '<li>In Quizlet: <em>Create &rarr; + Set &rarr; Import from Word, Excel, Google Docs, etc.</em></li>',
  '<li>Open <code>flashcards.csv</code> in a text editor; copy ALL contents (skip the header row); paste into Quizlet</li>',
  '<li>Between term and definition: <strong>Comma</strong> &middot; Between cards: <strong>New line</strong></li>',
  '<li>Click Import. (Quizlet ignores the third column — chapter tags don\'t survive Quizlet import; the Anki deck is richer.)</li>',
  '</ol>',
  '</div>',
  '<h2>Card distribution by chapter</h2>',
  '<table><thead><tr><th>Tag</th><th style="text-align:right">Cards</th></tr></thead><tbody>',
  paste(chap_table_rows, collapse = "\n"),
  '</tbody></table>',
  '<h2>Preview (first 8 cards)</h2>',
  '<table><thead><tr><th>Front</th><th>Back (truncated)</th><th>Tags</th></tr></thead><tbody>',
  paste(preview_rows, collapse = "\n"),
  '</tbody></table>',
  '<h2>How to assign these</h2>',
  '<ul>',
  '<li><strong>Pre-course</strong>: ask students to pre-load the deck week 1; encourages active review habits early.</li>',
  '<li><strong>Pre-quiz / pre-exam</strong>: link the chapter-filtered Anki deck (e.g., <code>tag:ModernDive::Ch08</code>) as a study aid.</li>',
  '<li><strong>Cumulative review</strong>: pair with the <a href="cumulative-review.html">cumulative review study guides</a> for the milestone checkpoints.</li>',
  '<li><strong>For students who prefer paper</strong>: print pages with 6-up flashcard layout from any browser (the Anki desktop app also has a print-to-PDF option).</li>',
  '</ul>',
  '<p style="color:#666; font-size:0.88em; margin-top:2em;">Regenerated on each book build from <code>96-glossary.qmd</code> &mdash; new terms in the glossary automatically appear in the next deck.</p>',
  '</body></html>'
), collapse = "\n")

html_out <- file.path(out_dir, "flashcards.html")
writeLines(html, html_out)
cat(sprintf("Wrote %s (landing page with download links)\n", html_out))
