#!/usr/bin/env Rscript
# Concept dependency map.
#
# Builds a visualization of inter-chapter dependencies by walking every
# `@sec-*` reference in chapter prose and mapping it back to the chapter
# that owns the anchor. Outputs an HTML page with:
#
#   1. A textual dependency table (per chapter: "Depends on (incoming):
#      Ch 2, 3, 5"; "Cited by (outgoing): Ch 7, 8, 10").
#   2. A simple SVG dependency-graph rendering with chapters laid out in
#      reading order and arrows showing cross-references.
#
# Writes to `instructor-solutions/concept-map.html` (gitignored — a
# snapshot regenerated on demand).
#
# Run:  Rscript scripts/build_concept_map.R

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

chap_titles <- c(
  "1" = "Getting started",
  "2" = "Visualization",
  "3" = "Wrangling",
  "4" = "Tidy data",
  "5" = "Regression",
  "6" = "Multiple regression",
  "7" = "Sampling",
  "8" = "Confidence intervals",
  "9" = "Hypothesis testing",
  "10" = "Inference for regression",
  "11" = "Tell your story with data"
)

chap_files <- list.files(".", pattern = "^[0-9]+-.*\\.qmd$")
chap_files <- sort(chap_files)

# Build anchor → chapter number map
anchor_to_chap <- list()
for (f in chap_files) {
  m <- str_match(f, "^([0-9]+)")
  if (is.na(m[1, 2])) next
  chap <- as.integer(m[1, 2])
  if (chap > 11) next
  for (l in readLines(f, warn = FALSE)) {
    matches <- str_extract_all(l, "\\{#(sec-[A-Za-z0-9_-]+)")[[1]]
    for (mt in matches) {
      anchor <- sub("^\\{#", "", mt)
      anchor_to_chap[[anchor]] <- chap
    }
  }
}

# Walk chapter prose, collect (from_chap, to_chap, anchor) edges.
edges <- list()
for (f in chap_files) {
  m <- str_match(f, "^([0-9]+)")
  if (is.na(m[1, 2])) next
  chap <- as.integer(m[1, 2])
  if (chap > 11) next
  in_chunk <- FALSE
  for (l in readLines(f, warn = FALSE)) {
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; next }
    if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; next }
    if (in_chunk) next
    refs <- str_extract_all(l, "@(sec-[A-Za-z0-9_-]+)")[[1]]
    for (r in refs) {
      anchor <- sub("[.]+$", "", sub("^@", "", r))
      tgt <- anchor_to_chap[[anchor]]
      if (is.null(tgt) || tgt == chap) next
      edges[[length(edges) + 1]] <- list(from = chap, to = tgt, anchor = anchor)
    }
  }
}

# Aggregate: per-chapter in-edges and out-edges
n_chapters <- 11
in_count  <- matrix(0L, nrow = n_chapters, ncol = n_chapters)
out_count <- matrix(0L, nrow = n_chapters, ncol = n_chapters)
for (e in edges) {
  out_count[e$from, e$to] <- out_count[e$from, e$to] + 1L
  in_count[e$to, e$from] <- in_count[e$to, e$from] + 1L
}

# Forward edges (Ch N → Ch M, M > N) vs backward (M < N)
forward_edges <- Filter(function(e) e$to > e$from, edges)
backward_edges <- Filter(function(e) e$to < e$from, edges)

# Build per-chapter summary
summaries <- lapply(1:n_chapters, function(ch) {
  out_dest <- which(out_count[ch, ] > 0)
  in_src   <- which(in_count[ch, ] > 0)
  list(
    chap = ch,
    title = chap_titles[as.character(ch)],
    depends_on = in_src,
    cited_by = out_dest,
    n_out = sum(out_count[ch, ]),
    n_in  = sum(in_count[ch, ])
  )
})

# Build SVG: chapters laid out as a row of circles, arrows showing edges.
# Forward edges (left→right, normal flow) are blue; backward edges are red
# (forward references — i.e., the chapter cites a later chapter, which is
# only OK in well-foreshadowed contexts).
svg_w <- 980
svg_h <- 460
margin_x <- 60
node_y <- 220
node_r <- 26
xs <- margin_x + (seq_len(n_chapters) - 1) * (svg_w - 2 * margin_x) / (n_chapters - 1)

# Arc path between two nodes, with curvature proportional to distance.
arc_path <- function(x1, x2, above = TRUE) {
  dx <- abs(x2 - x1)
  ctrl_y <- node_y + if (above) -dx * 0.5 else dx * 0.5
  sprintf("M %.1f %.1f Q %.1f %.1f %.1f %.1f",
          x1, node_y, (x1 + x2) / 2, ctrl_y, x2, node_y)
}

svg_lines <- c(
  sprintf('<svg viewBox="0 0 %d %d" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="ModernDive chapter-dependency graph">', svg_w, svg_h),
  '<style>',
  '  .node circle { fill: #5b9bd5; stroke: #1f4e79; stroke-width: 1.5; }',
  '  .node text { fill: white; font-weight: bold; text-anchor: middle; dominant-baseline: central; font-family: -apple-system, system-ui, sans-serif; font-size: 14px; }',
  '  .label { fill: #333; text-anchor: middle; font-family: -apple-system, system-ui, sans-serif; font-size: 11px; }',
  '  .edge { fill: none; stroke-width: 1.2; opacity: 0.55; }',
  '  .edge.fwd { stroke: #1f4e79; }',
  '  .edge.bwd { stroke: #c0392b; }',
  '  marker.fwd-arrow path { fill: #1f4e79; }',
  '  marker.bwd-arrow path { fill: #c0392b; }',
  '  text.legend { font-family: -apple-system, system-ui, sans-serif; font-size: 12px; fill: #333; }',
  '</style>',
  '<defs>',
  '  <marker id="fwd-arrow" class="fwd-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z"/></marker>',
  '  <marker id="bwd-arrow" class="bwd-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M 0 0 L 10 5 L 0 10 z"/></marker>',
  '</defs>'
)

# Backward edges first (drawn below), then forward (above), then nodes on top.
for (e in backward_edges) {
  svg_lines <- c(svg_lines,
    sprintf('<path class="edge bwd" d="%s" marker-end="url(#bwd-arrow)" />',
            arc_path(xs[e$from], xs[e$to], above = FALSE)))
}
# Aggregate forward edges by (from, to) so we draw one arc per pair instead
# of N — visual noise reduction
fwd_pairs <- list()
for (e in forward_edges) {
  k <- sprintf("%d->%d", e$from, e$to)
  fwd_pairs[[k]] <- (fwd_pairs[[k]] %||% 0) + 1
}
for (key in names(fwd_pairs)) {
  fromto <- as.integer(strsplit(sub("->", " ", key), " ")[[1]])
  svg_lines <- c(svg_lines,
    sprintf('<path class="edge fwd" d="%s" marker-end="url(#fwd-arrow)" />',
            arc_path(xs[fromto[1]], xs[fromto[2]], above = TRUE)))
}

# Nodes
for (i in seq_len(n_chapters)) {
  svg_lines <- c(svg_lines,
    sprintf('<g class="node"><circle cx="%.1f" cy="%.1f" r="%d"/><text x="%.1f" y="%.1f">%d</text></g>',
            xs[i], node_y, node_r, xs[i], node_y, i))
  svg_lines <- c(svg_lines,
    sprintf('<text class="label" x="%.1f" y="%.1f">%s</text>',
            xs[i], node_y + node_r + 18, chap_titles[as.character(i)]))
}

# Legend
svg_lines <- c(svg_lines,
  sprintf('<line x1="%d" y1="%d" x2="%d" y2="%d" class="edge fwd" marker-end="url(#fwd-arrow)" />', svg_w - 280, svg_h - 50, svg_w - 230, svg_h - 50),
  sprintf('<text class="legend" x="%d" y="%d" dominant-baseline="central">backward citation (e.g., Ch 10 → Ch 5)</text>', svg_w - 220, svg_h - 50),
  sprintf('<line x1="%d" y1="%d" x2="%d" y2="%d" class="edge bwd" marker-end="url(#bwd-arrow)" />', svg_w - 280, svg_h - 25, svg_w - 230, svg_h - 25),
  sprintf('<text class="legend" x="%d" y="%d" dominant-baseline="central">forward reference (e.g., Ch 5 → Ch 10)</text>', svg_w - 220, svg_h - 25),
  '</svg>'
)

svg <- paste(svg_lines, collapse = "\n")

# Build textual summary table
rows <- character()
for (s in summaries) {
  dep_text <- if (length(s$depends_on)) paste("Ch", paste(s$depends_on, collapse = ", "))
              else "—"
  cite_text <- if (length(s$cited_by)) paste("Ch", paste(s$cited_by, collapse = ", "))
               else "—"
  rows <- c(rows, sprintf(
    "<tr><td><strong>Chapter %d</strong> %s</td><td>%s (%d total refs)</td><td>%s (%d total refs)</td></tr>",
    s$chap, s$title, dep_text, s$n_in, cite_text, s$n_out))
}

html <- paste(c(
  '<!DOCTYPE html>',
  '<html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Concept dependency map</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1100px; margin: 2em auto; padding: 0 1em; color: #222; line-height: 1.5; }',
  '  h1 { font-size: 1.6em; margin-bottom: 0.2em; }',
  '  h2 { font-size: 1.25em; margin-top: 2em; border-bottom: 1px solid #ccc; padding-bottom: 0.2em; }',
  '  table { border-collapse: collapse; width: 100%; margin: 1em 0; }',
  '  th { background: #f4f4f4; padding: 0.5em 0.8em; text-align: left; }',
  '  td { padding: 0.5em 0.8em; border-top: 1px solid #eee; vertical-align: top; }',
  '  .svg-wrap { background: #fafafa; padding: 1em; border-radius: 6px; margin: 1.5em 0; }',
  '</style></head><body>',
  '<h1>ModernDive &mdash; Concept dependency map</h1>',
  sprintf('<p>Generated %s. Each chapter is a node; arrows show <code>@sec-*</code> cross-references between chapters. Forward arcs (blue, above the line) represent the normal "this chapter builds on an earlier one" direction; backward arcs (red, below) represent forward references where an earlier chapter mentions a later one (well-foreshadowed in this book; see the cross-reference scan results).</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<div class="svg-wrap">',
  svg,
  '</div>',
  '<h2>Per-chapter dependency summary</h2>',
  '<table>',
  '<tr><th>Chapter</th><th>Depends on (incoming refs)</th><th>Cited by (outgoing refs)</th></tr>',
  paste(rows, collapse = "\n"),
  '</table>',
  '</body></html>'
), collapse = "\n")

dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out_path <- "instructor-solutions/_site/concept-map.html"
writeLines(html, out_path)
cat(sprintf("Wrote %s (%d chapters, %d cross-chapter edges)\n",
            out_path, n_chapters, length(edges)))
