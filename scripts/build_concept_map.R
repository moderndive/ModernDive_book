#!/usr/bin/env Rscript
# Concept dependency map.
#
# Builds a visualization of inter-chapter dependencies by walking every
# `@sec-*` reference in chapter prose and mapping it back to the chapter
# that owns the anchor. Outputs an HTML page with three views, in order:
#
#   1. Interactive force-directed network (vis-network). Nodes are
#      draggable; hovering a node highlights its neighbors. Edge weight
#      = number of cross-references; rendered as line thickness.
#   2. Adjacency-matrix heatmap. 11×11 grid; each cell encodes the number
#      of times the row chapter references the column chapter. Zero arc
#      overlap, every relationship visible at a glance.
#   3. Per-chapter dependency table (textual): "Depends on (incoming):
#      Ch 2, 3, 5"; "Cited by (outgoing): Ch 7, 8, 10".
#
# The previous design used a horizontal row of 11 nodes with raw (non-
# aggregated) arcs above/below for forward/backward edges. With 257
# cross-chapter references — including 201 backward — the arcs piled into
# unreadable spaghetti. vis-network + matrix is much clearer.
#
# Writes to `instructor-solutions/_site/concept-map.html` (regenerated on
# demand).
#
# Run:  Rscript scripts/build_concept_map.R

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Shared "← Back to instructor hub" sticky top-of-page nav.
source("scripts/_hub_nav.R")

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

# Aggregate edges by (from, to) pair with weight = reference count.
edge_pairs <- list()
for (e in edges) {
  k <- sprintf("%d->%d", e$from, e$to)
  edge_pairs[[k]] <- (edge_pairs[[k]] %||% 0L) + 1L
}

# JSON for vis-network: nodes + edges. Hand-built to avoid a jsonlite dep.
json_str <- function(x) paste0('"', gsub('"', '\\\\"', x), '"')

nodes_json <- paste0(
  vapply(seq_len(n_chapters), function(i) {
    # Don't set `group` — vis-network's default group palette would
    # override our explicit nodes.color (one of those defaults is yellow,
    # which has terrible contrast against the white label text).
    sprintf(
      '{"id":%d,"label":"Ch %d","title":%s,"value":%d}',
      i, i,
      json_str(sprintf("Ch %d — %s\\nIncoming: %d  •  Outgoing: %d",
                       i, chap_titles[as.character(i)],
                       summaries[[i]]$n_in, summaries[[i]]$n_out)),
      summaries[[i]]$n_in + summaries[[i]]$n_out + 1L
    )
  }, character(1)),
  collapse = ","
)

edges_json <- paste0(
  vapply(names(edge_pairs), function(k) {
    ft <- as.integer(strsplit(sub("->", " ", k), " ")[[1]])
    w <- edge_pairs[[k]]
    is_fwd <- ft[2] > ft[1]
    sprintf(
      '{"from":%d,"to":%d,"value":%d,"title":%s,"color":{"color":"%s","opacity":%s},"arrows":{"to":{"enabled":true,"scaleFactor":0.6}}}',
      ft[1], ft[2], w,
      json_str(sprintf("%d cross-refs: Ch %d → Ch %d", w, ft[1], ft[2])),
      if (is_fwd) "#1f4e79" else "#c0392b",
      sprintf("%.2f", min(1, 0.35 + w * 0.05))
    )
  }, character(1)),
  collapse = ","
)

graph_html <- paste(c(
  '<div id="concept-graph" role="img" aria-label="Interactive chapter-dependency network"></div>',
  '<p class="graph-legend"><span class="legend-fwd">━</span> forward (later chapter cites earlier) &nbsp; <span class="legend-bwd">━</span> backward (earlier chapter cites later, foreshadowing) &nbsp;&nbsp; <em>Drag nodes • Hover a chapter to highlight its neighbors • Edge thickness = reference count</em></p>',
  '<script src="https://unpkg.com/vis-network@9.1.9/standalone/umd/vis-network.min.js"></script>',
  '<script>',
  sprintf('  const nodes = new vis.DataSet([%s]);', nodes_json),
  sprintf('  const edges = new vis.DataSet([%s]);', edges_json),
  '  const network = new vis.Network(document.getElementById("concept-graph"), { nodes, edges }, {',
  '    nodes: { shape: "circle", font: { size: 18, color: "#fff", face: "system-ui" }, color: { background: "#1f4e79", border: "#0d2e4d", highlight: { background: "#5b9bd5", border: "#0d2e4d" } }, borderWidth: 2, scaling: { min: 14, max: 36, label: { enabled: false } } },',
  '    edges: { smooth: { type: "curvedCW", roundness: 0.18 }, scaling: { min: 0.8, max: 8 }, hoverWidth: 1.5, selectionWidth: 2 },',
  '    physics: { solver: "forceAtlas2Based", forceAtlas2Based: { gravitationalConstant: -120, springLength: 130, avoidOverlap: 0.6 }, stabilization: { iterations: 250 } },',
  '    interaction: { hover: true, tooltipDelay: 120 }',
  '  });',
  '  network.once("stabilizationIterationsDone", () => network.setOptions({ physics: false }));',
  '</script>'
), collapse = "\n")

# Adjacency matrix view: 11×11 HTML table. Cell intensity = reference count.
# Row = source chapter; column = target chapter. Color by direction:
# blue for forward (j > i), red for backward (j < i).
edge_count <- matrix(0L, nrow = n_chapters, ncol = n_chapters)
for (k in names(edge_pairs)) {
  ft <- as.integer(strsplit(sub("->", " ", k), " ")[[1]])
  edge_count[ft[1], ft[2]] <- edge_pairs[[k]]
}
max_count <- max(edge_count)

matrix_rows <- c('<tr><th class="corner">From \\ To</th>',
                 paste0('<th class="cm-col">Ch', seq_len(n_chapters), '</th>',
                        collapse = ""),
                 '</tr>')
for (i in seq_len(n_chapters)) {
  cells <- vapply(seq_len(n_chapters), function(j) {
    if (i == j) return('<td class="diag"></td>')
    n <- edge_count[i, j]
    if (n == 0) return('<td class="zero"></td>')
    intensity <- 0.18 + 0.82 * (n / max_count)  # 0.18..1.0
    bg <- if (j > i) {
      sprintf("rgba(31, 78, 121, %.2f)", intensity)
    } else {
      sprintf("rgba(192, 57, 43, %.2f)", intensity)
    }
    sprintf('<td class="filled" style="background:%s" title="Ch %d → Ch %d: %d refs">%d</td>',
            bg, i, j, n, n)
  }, character(1))
  matrix_rows <- c(matrix_rows,
                   sprintf('<tr><th class="cm-row">Ch%d</th>%s</tr>',
                           i, paste(cells, collapse = "")))
}
matrix_html <- paste(c(
  '<div class="matrix-wrap">',
  '<table class="cm-matrix">',
  paste(matrix_rows, collapse = "\n"),
  '</table>',
  '<p class="matrix-legend">Cell shows the count of <code>@sec-*</code> cross-references from the row chapter to the column chapter. Blue (above the diagonal) is the normal direction; red (below) is a backward reference where an earlier chapter foreshadows a later one.</p>',
  '</div>'
), collapse = "\n")

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
  '  h1 { font-size: 1.6em; margin-bottom: 0.2em; color: #1F3A6B; }',
  '  h2 { font-size: 1.25em; margin-top: 2em; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; color: #1F3A6B; }',
  '  p.lede { color: #555; }',
  '  /* Network graph */',
  '  #concept-graph { width: 100%; height: 560px; background: #fafafa; border-radius: 6px; border: 1px solid #e5e5e5; }',
  '  p.graph-legend { font-size: 0.92em; color: #555; margin-top: 0.5em; }',
  '  .legend-fwd { color: #1f4e79; font-weight: bold; letter-spacing: -2px; }',
  '  .legend-bwd { color: #c0392b; font-weight: bold; letter-spacing: -2px; }',
  '  /* Adjacency matrix */',
  '  .matrix-wrap { overflow-x: auto; margin: 1em 0; }',
  '  table.cm-matrix { border-collapse: collapse; margin: 0; font-size: 0.92em; }',
  '  table.cm-matrix th, table.cm-matrix td { border: 1px solid #ddd; padding: 0.45em 0.5em; text-align: center; min-width: 2.4em; }',
  '  table.cm-matrix th.corner { background: #f4f4f4; font-weight: 600; }',
  '  table.cm-matrix th.cm-col, table.cm-matrix th.cm-row { background: #f4f4f4; font-weight: 600; }',
  '  table.cm-matrix th.cm-row { text-align: right; padding-right: 0.6em; }',
  '  table.cm-matrix td.zero { background: #fff; color: #aaa; }',
  '  table.cm-matrix td.diag { background: repeating-linear-gradient(45deg, #f0f0f0, #f0f0f0 4px, #fafafa 4px, #fafafa 8px); }',
  '  table.cm-matrix td.filled { color: #fff; font-weight: 600; text-shadow: 0 0 2px rgba(0,0,0,0.35); }',
  '  p.matrix-legend { font-size: 0.92em; color: #555; }',
  '  /* Per-chapter summary table */',
  '  table.summary { border-collapse: collapse; width: 100%; margin: 1em 0; }',
  '  table.summary th { background: #f4f4f4; padding: 0.5em 0.8em; text-align: left; }',
  '  table.summary td { padding: 0.5em 0.8em; border-top: 1px solid #eee; vertical-align: top; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>ModernDive &mdash; Concept dependency map</h1>',
  sprintf('<p class="lede">Generated %s. Inter-chapter dependencies derived by walking every <code>@sec-*</code> reference in chapter prose and mapping it back to the chapter that owns the anchor. Three views below: an interactive network graph (drag, hover), an adjacency-matrix heatmap, and a per-chapter dependency table.</p>',
          format(Sys.Date(), "%Y-%m-%d")),
  '<h2>Interactive network</h2>',
  graph_html,
  '<h2>Adjacency matrix</h2>',
  matrix_html,
  '<h2>Per-chapter dependency summary</h2>',
  '<table class="summary">',
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
