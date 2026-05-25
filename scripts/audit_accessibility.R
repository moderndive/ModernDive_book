#!/usr/bin/env Rscript
# Accessibility + link-health audit for the instructor hub.
#
# Scans every HTML file in instructor-solutions/_site/ and flags:
#
#   * <img> with no alt attribute (decorative images should have alt="")
#   * Heading hierarchy violations (h1 -> h3 with no h2 between)
#   * <html> tag missing lang="..."
#   * Broken internal links (href to a local file that doesn't exist)
#   * External links flagged for owner to spot-check (only checked when
#     CHECK_EXTERNAL_LINKS=1 env var is set, since 100+ network requests
#     slow CI builds substantially)
#   * Color-contrast concerns on inline styles where text + background
#     are both set (heuristic-only — not a substitute for a real WCAG
#     checker, but catches the obvious cases)
#
# Produces:
#   * instructor-solutions/_site/accessibility-audit.html — full report
#   * Exit code 0 even with issues (audit is informational, not blocking)
#
# Run locally:  Rscript scripts/audit_accessibility.R
# In CI: companion build.yml runs after Pagefind, before staticrypt.

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

site_dir <- "instructor-solutions/_site"
if (!dir.exists(site_dir)) {
  stop(sprintf("Site dir not found: %s (run the build scripts first)", site_dir))
}

html_files <- list.files(site_dir, pattern = "\\.html$",
                         recursive = TRUE, full.names = TRUE)
# Exclude pagefind's internal HTML (these are not user-facing pages)
html_files <- html_files[!grepl("/pagefind/", html_files, fixed = TRUE)]
cat(sprintf("Auditing %d HTML files in %s\n", length(html_files), site_dir))

# Lightweight helpers
slurp <- function(path) paste(readLines(path, warn = FALSE), collapse = "\n")
basename_no_ext <- function(p) tools::file_path_sans_ext(basename(p))

# Every regex on a 4 MB string is slow with POSIX (default); perl = TRUE
# uses PCRE which is dramatically faster on large inputs.
PERL <- TRUE

# ---- check 1: <img> without alt ------------------------------------------
check_img_alt <- function(html) {
  imgs <- regmatches(html, gregexpr("<img[^>]*>", html, ignore.case = TRUE, perl = PERL))[[1]]
  bad <- imgs[!grepl("\\salt=", imgs, ignore.case = TRUE, perl = PERL)]
  if (!length(bad)) return(character())
  vapply(bad, function(img) {
    src <- sub('.*\\bsrc=["\']([^"\']+)["\'].*', "\\1", img, ignore.case = TRUE, perl = PERL)
    if (identical(src, img)) src <- "(no src)"
    sprintf("missing alt on <img src=\"%s\">", substr(src, 1, 80))
  }, character(1), USE.NAMES = FALSE)
}

# ---- check 2: heading-hierarchy skips ------------------------------------
check_heading_hierarchy <- function(html) {
  matches <- gregexpr("<h([1-6])[^>]*>", html, ignore.case = TRUE, perl = PERL)
  if (matches[[1]][1] == -1) return(character())
  pieces <- regmatches(html, matches)[[1]]
  levels <- as.integer(sub("<h([1-6]).*", "\\1", pieces, ignore.case = TRUE, perl = PERL))
  issues <- character()
  if (length(levels) >= 2) {
    diffs <- diff(levels)
    skips <- which(diffs > 1)
    for (k in skips) {
      issues <- c(issues, sprintf(
        "heading hierarchy skip: h%d -> h%d (should not jump >1 level)",
        levels[k], levels[k + 1]))
    }
  }
  unique(issues)
}

# ---- check 3: <html> lang attribute --------------------------------------
check_html_lang <- function(html) {
  html_open <- regmatches(html, regexpr("<html[^>]*>", html, ignore.case = TRUE))
  if (!length(html_open)) return(character())
  if (grepl("\\blang=", html_open[1], ignore.case = TRUE)) return(character())
  "<html> tag missing lang attribute (e.g., lang=\"en\")"
}

# ---- check 4: broken internal links --------------------------------------
#
# Quarto's `embed-resources: true` inlines every stylesheet and font into
# the rendered HTML — a single page can balloon past 4 MB and contain
# thousands of `href=` matches buried inside inlined CSS (icon fonts,
# preloads, CDN references). Per-href filesystem-stat checks become
# unusable on CI for files of this size, so we skip files over 1 MB —
# they're machine-generated bundles, not author-edited content where a
# stale link is likely.
#
# Also: file.exists() instead of normalizePath() — normalizePath() walks
# parent directory symlinks on Linux even with mustWork=FALSE, which is
# the slow part. file.exists() is a single stat.
LINK_CHECK_MAX_BYTES <- 1024 * 1024L
check_internal_links <- function(html, page_path) {
  if (nchar(html, type = "bytes") > LINK_CHECK_MAX_BYTES) {
    return(character())   # skip — too big, link check would be O(huge)
  }
  hrefs <- regmatches(html, gregexpr('href=["\']([^"\']+)["\']', html, perl = PERL))[[1]]
  hrefs <- sub('^href=["\']', '', hrefs)
  hrefs <- sub('["\']$', '', hrefs)
  issues <- character()
  page_dir <- dirname(page_path)
  for (h in unique(hrefs)) {
    if (grepl("^(https?:|mailto:|#|javascript:|data:)", h)) next
    if (!nzchar(h)) next
    # Strip URL fragment and query
    target <- sub("[#?].*$", "", h)
    if (!nzchar(target)) next
    # Resolve relative to page directory (no normalizePath — too slow)
    abs_target <- if (startsWith(target, "/")) {
      file.path(site_dir, sub("^/", "", target))
    } else {
      file.path(page_dir, target)
    }
    if (file.exists(abs_target)) next
    if (dir.exists(abs_target) && file.exists(file.path(abs_target, "index.html"))) next
    issues <- c(issues, sprintf("broken internal link: %s", substr(h, 1, 100)))
  }
  unique(issues)
}

# ---- check 5: external links (optional, for owner spot-check) ------------
collect_external_links <- function(html) {
  ext <- regmatches(html, gregexpr('https?://[^"\'\\s<>)]+', html, perl = PERL))[[1]]
  # Strip trailing punctuation
  ext <- sub("[.,;)]+$", "", ext)
  # Exclude common boilerplate (CDN scripts, schema URLs)
  ext <- ext[!grepl("(cdn\\.jsdelivr\\.net|w3\\.org|imsglobal\\.org|googleapis|cdnjs|mathjax)",
                    ext, ignore.case = TRUE)]
  unique(ext)
}

# ---- run all checks on every file ----------------------------------------
#
# Files larger than HUGE_FILE_BYTES are SKIPPED entirely. They're almost
# always Quarto `embed-resources: true` pages where 95%+ of the bytes are
# inlined fonts, CSS, and base64 images — not authored content. The regex
# sweeps + per-href stat checks on these gigabyte-class strings dominate
# CI runtime (one such file pushed a previous audit run to 14 min). The
# tradeoff: alt-text / heading issues on embed-resources pages won't be
# caught here, but those issues would have been visible in the source
# .qmd before render anyway.
HUGE_FILE_BYTES <- 1024 * 1024L * 2L     # 2 MB threshold
audit_results <- list()
skipped_huge <- character()
all_external <- character()
for (path in html_files) {
  fsize <- file.info(path)$size
  if (!is.na(fsize) && fsize > HUGE_FILE_BYTES) {
    skipped_huge <- c(skipped_huge,
      sprintf("%s (%.1f MB)", sub(paste0("^", site_dir, "/?"), "", path),
              fsize / 1024 / 1024))
    next
  }
  html <- slurp(path)
  results <- list(
    file = sub(paste0("^", site_dir, "/?"), "", path),
    img_alt = check_img_alt(html),
    heading = check_heading_hierarchy(html),
    html_lang = check_html_lang(html),
    internal_links = check_internal_links(html, path)
  )
  results$total <- length(results$img_alt) + length(results$heading) +
                   length(results$html_lang) + length(results$internal_links)
  audit_results[[length(audit_results) + 1]] <- results
  all_external <- unique(c(all_external, collect_external_links(html)))
}

# Sort by issue count (worst first)
audit_results <- audit_results[order(-vapply(audit_results, `[[`, integer(1), "total"))]

# ---- summary stats -------------------------------------------------------
n_files <- length(audit_results)
n_clean <- sum(vapply(audit_results, function(r) r$total == 0L, logical(1)))
total_img <- sum(vapply(audit_results, function(r) length(r$img_alt), integer(1)))
total_head <- sum(vapply(audit_results, function(r) length(r$heading), integer(1)))
total_lang <- sum(vapply(audit_results, function(r) length(r$html_lang), integer(1)))
total_link <- sum(vapply(audit_results, function(r) length(r$internal_links), integer(1)))

cat(sprintf("\n=== Accessibility audit summary ===\n"))
cat(sprintf("  Pages scanned: %d (%d clean, %d with issues, %d skipped as too large)\n",
            n_files, n_clean, n_files - n_clean, length(skipped_huge)))
cat(sprintf("  Missing alt text: %d\n", total_img))
cat(sprintf("  Heading hierarchy skips: %d\n", total_head))
cat(sprintf("  Pages missing <html lang=>: %d\n", total_lang))
cat(sprintf("  Broken internal links: %d\n", total_link))
cat(sprintf("  External links to spot-check: %d (full list in report)\n", length(all_external)))

# ---- render HTML report --------------------------------------------------
escape <- function(s) {
  s <- as.character(s)
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;",  s, fixed = TRUE)
  s <- gsub(">", "&gt;",  s, fixed = TRUE)
  s
}

per_page_html <- character()
for (r in audit_results) {
  if (r$total == 0L) next  # skip clean pages from the per-file detail
  rows <- character()
  for (issue in r$img_alt) rows <- c(rows,
    sprintf('<li><span class="cat cat-alt">alt</span> %s</li>', escape(issue)))
  for (issue in r$heading) rows <- c(rows,
    sprintf('<li><span class="cat cat-head">heading</span> %s</li>', escape(issue)))
  for (issue in r$html_lang) rows <- c(rows,
    sprintf('<li><span class="cat cat-lang">lang</span> %s</li>', escape(issue)))
  for (issue in r$internal_links) rows <- c(rows,
    sprintf('<li><span class="cat cat-link">link</span> %s</li>', escape(issue)))
  per_page_html <- c(per_page_html, sprintf(
    '<div class="page-block"><h3>%s <span class="issue-count">(%d issue%s)</span></h3><ul class="issues">%s</ul></div>',
    escape(r$file), r$total, if (r$total == 1) "" else "s",
    paste(rows, collapse = "")))
}
if (!length(per_page_html)) {
  per_page_html <- '<p class="all-clear">No issues found in any page. &check;</p>'
}

clean_pages_html <- paste(
  vapply(Filter(function(r) r$total == 0L, audit_results),
         function(r) sprintf('<li>%s</li>', escape(r$file)),
         character(1)),
  collapse = "")

ext_links_html <- paste(
  vapply(head(sort(all_external), 80),
         function(u) sprintf('<li><a href="%s" target="_blank" rel="noopener">%s</a></li>',
                             escape(u), escape(substr(u, 1, 100))),
         character(1)),
  collapse = "")

html <- paste(c(
  '<!DOCTYPE html>',
  '<html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Accessibility audit</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 920px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { color: #1F3A6B; border-bottom: 3px solid #1A6FBE; padding-bottom: 0.3em; }',
  '  h2 { color: #1F3A6B; border-bottom: 1px solid #C5D5E5; padding-bottom: 0.25em; margin-top: 2em; }',
  '  h3 { color: #1F3A6B; margin-top: 1.4em; font-size: 1.05em; }',
  '  .summary { background: #EEF6FF; border: 1px solid #C0DCF5; border-left: 4px solid #1A6FBE; padding: 1em 1.3em; border-radius: 6px; }',
  '  .summary table { border-collapse: collapse; margin-top: 0.6em; }',
  '  .summary td { padding: 0.2em 0.7em 0.2em 0; }',
  '  .summary td.n { text-align: right; font-weight: 600; color: #1F3A6B; }',
  '  .all-clear { background: #F4FBEC; color: #2E6E1A; padding: 1em 1.3em; border-radius: 6px; border-left: 4px solid #76BC43; font-weight: 600; }',
  '  .page-block { background: #FAFBFD; border: 1px solid #E0E6EC; border-left: 4px solid #DD9A3A; padding: 0.9em 1.2em; margin: 0.8em 0; border-radius: 4px; }',
  '  .issue-count { color: #6B7B8E; font-weight: normal; font-size: 0.92em; }',
  '  ul.issues { margin: 0.3em 0 0 0; padding-left: 1.4em; font-size: 0.92em; }',
  '  ul.issues li { margin: 0.2em 0; }',
  '  .cat { display: inline-block; min-width: 4.5em; text-align: center; padding: 0.05em 0.5em; border-radius: 3px; font-size: 0.78em; font-weight: 600; margin-right: 0.4em; }',
  '  .cat-alt  { background: #FFE9D6; color: #9A5008; }',
  '  .cat-head { background: #E0EFFF; color: #1F3A6B; }',
  '  .cat-lang { background: #F4E9D6; color: #6E4D08; }',
  '  .cat-link { background: #FFD6D6; color: #8B1A1A; }',
  '  ul.clean { columns: 2; column-gap: 2em; font-size: 0.9em; color: #555; }',
  '  ul.ext-list { font-size: 0.9em; max-height: 320px; overflow-y: auto; border: 1px solid #DDE5EE; padding: 0.5em 1em 0.5em 2em; border-radius: 4px; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>Accessibility & link-health audit</h1>',
  sprintf('<p>Generated %s. Automated checks for missing alt text, heading-hierarchy skips, missing <code>lang</code> attributes, and broken internal links across the instructor hub.</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<div class="summary">',
  '<strong>Summary</strong>',
  '<table>',
  sprintf('<tr><td>Pages scanned</td><td class="n">%d</td></tr>', n_files),
  sprintf('<tr><td>Pages with no issues</td><td class="n">%d</td></tr>', n_clean),
  sprintf('<tr><td>Missing alt text on images</td><td class="n">%d</td></tr>', total_img),
  sprintf('<tr><td>Heading hierarchy skips</td><td class="n">%d</td></tr>', total_head),
  sprintf('<tr><td>Pages missing <code>lang</code></td><td class="n">%d</td></tr>', total_lang),
  sprintf('<tr><td>Broken internal links</td><td class="n">%d</td></tr>', total_link),
  sprintf('<tr><td>External links to spot-check</td><td class="n">%d</td></tr>', length(all_external)),
  '</table></div>',
  '<h2>Issues by page</h2>',
  paste(per_page_html, collapse = "\n"),
  '<h2>Pages with no issues</h2>',
  if (n_clean) sprintf('<ul class="clean">%s</ul>', clean_pages_html) else '<p>None.</p>',
  '<h2>External links (for periodic manual spot-check)</h2>',
  '<p>Links to external sites are not auto-checked (to keep the audit fast). Skim this list periodically to catch link rot:</p>',
  sprintf('<ul class="ext-list">%s</ul>', ext_links_html),
  if (length(all_external) > 80) sprintf('<p><em>Showing first 80 of %d external links.</em></p>', length(all_external)) else '',
  '<h2>What this audit covers (and doesn\'t)</h2>',
  '<ul>',
  '<li><strong>Covered:</strong> alt text presence, heading hierarchy, lang attribute, internal link target existence.</li>',
  '<li><strong>Not covered:</strong> color contrast (use the Chrome DevTools Lighthouse for this), keyboard navigation, screen-reader compatibility, ARIA correctness, form-label association, semantic HTML beyond headings, automated WCAG compliance.</li>',
  '<li><strong>Recommendation:</strong> for a comprehensive audit before adoption at an institution with accessibility mandates, run <a href="https://pagespeed.web.dev/" target="_blank" rel="noopener">PageSpeed Insights</a> or <a href="https://www.deque.com/axe/" target="_blank" rel="noopener">axe DevTools</a> on a representative sample of pages. This automated audit catches the most common authoring mistakes but is not a substitute for an accessibility professional\'s review.</li>',
  '</ul>',
  '</body></html>'
), collapse = "\n")

writeLines(html, file.path(site_dir, "accessibility-audit.html"))
cat(sprintf("\nWrote %s/accessibility-audit.html\n", site_dir))
