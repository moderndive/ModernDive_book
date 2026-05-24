#!/usr/bin/env Rscript
# Homework-set planner.
#
# Reads every `exercises/NN.yml` and emits
# `instructor-solutions/homework-planner.html`: a static page with all
# exercises listed plus client-side JS filters so an instructor can pick
# chapters, difficulty mix, and groups, then export a shareable list.
#
# Run: Rscript scripts/build_homework_planner.R

suppressPackageStartupMessages({
  library(yaml)
  library(jsonlite)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)
source("scripts/_hub_nav.R")

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Collect every exercise as a single flat list of records.
all_records <- list()
for (chap in 1:11) {
  yml <- sprintf("exercises/%02d.yml", chap)
  if (!file.exists(yml)) next
  d <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(d) || !length(d$exercises)) next
  for (ex in d$exercises) {
    prompt <- ex$prompt %||% ""
    # Strip markdown formatting for cleaner display (italics, bold, backticks)
    plain <- gsub("\\*+([^*]+)\\*+", "\\1", prompt)
    plain <- gsub("`([^`]+)`", "\\1", plain)
    plain <- gsub("\\s+", " ", plain)
    all_records[[length(all_records) + 1]] <- list(
      chap = chap,
      ex   = as.integer(ex$ex_num),
      id   = sprintf("EX%d.%d", chap, as.integer(ex$ex_num)),
      diff = as.integer(ex$difficulty %||% NA),
      group = ex$group %||% "",
      section = ex$book_section %||% "",
      has_webr = !is.null(ex$webr) && nzchar(ex$webr),
      prompt_short = substr(plain, 1, 220),
      prompt_full = prompt
    )
  }
}

json <- toJSON(all_records, auto_unbox = TRUE, pretty = FALSE)

html <- c(
  '<!DOCTYPE html>',
  '<html lang="en"><head><meta charset="utf-8">',
  '<title>ModernDive &mdash; Homework planner</title>',
  '<style>',
  '  body { font-family: -apple-system, system-ui, sans-serif; max-width: 1300px; margin: 1.5em auto; padding: 0 1em; color: #222; line-height: 1.45; }',
  '  h1 { font-size: 1.6em; margin-bottom: 0.1em; color: #1F3A6B; }',
  '  h2 { font-size: 1.25em; margin-top: 2em; border-bottom: 2px solid #1A6FBE; padding-bottom: 0.3em; color: #1F3A6B; }',
  '  p.lead { color: #555; }',
  '  .controls { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1em; background: #f7f9fc; padding: 1em 1.2em; border-radius: 8px; border-left: 4px solid #5b9bd5; margin: 1em 0; }',
  '  .controls label { display: block; font-weight: 600; font-size: 0.92em; color: #1f4e79; margin-bottom: 0.4em; }',
  '  .controls .chk { display: inline-block; margin: 0.1em 0.6em 0.1em 0; font-weight: normal; font-size: 0.9em; color: #333; cursor: pointer; }',
  '  .controls input[type="number"], .controls input[type="text"] { width: 100%; padding: 0.35em; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }',
  '  #summary { background: #fff8e1; padding: 0.7em 1em; border-radius: 6px; border-left: 4px solid #f0a500; margin: 1em 0; }',
  '  #summary strong { color: #1f4e79; }',
  '  table.results { width: 100%; border-collapse: collapse; margin-top: 1em; }',
  '  table.results th { background: #f4f4f4; padding: 0.5em 0.7em; text-align: left; position: sticky; top: 0; }',
  '  table.results td { padding: 0.5em 0.7em; border-top: 1px solid #eee; vertical-align: top; }',
  '  td.id { font-family: ui-monospace, "Cascadia Mono", monospace; color: #04395e; font-weight: 600; white-space: nowrap; }',
  '  td.diff { white-space: nowrap; color: #c0392b; font-size: 0.9em; }',
  '  td.diff.diff-1 { color: #2e7d32; }',
  '  td.diff.diff-2 { color: #f0a500; }',
  '  td.group { font-size: 0.86em; color: #666; }',
  '  td.actions input { margin: 0 0.3em 0 0; }',
  '  button { background: #1f4e79; color: white; border: none; padding: 0.55em 1.2em; border-radius: 4px; font-size: 0.95em; cursor: pointer; margin-right: 0.5em; }',
  '  button:hover { background: #295e92; }',
  '  button.secondary { background: #888; }',
  '  button.secondary:hover { background: #555; }',
  '  #export { margin: 1em 0; }',
  '  #export-output { background: #f4f4f4; padding: 0.8em; border-radius: 4px; white-space: pre-wrap; font-family: ui-monospace, monospace; font-size: 0.88em; display: none; }',
  '  .empty { color: #888; text-align: center; padding: 2em; }',
  '</style></head><body>',
  hub_nav_html(),
  '<h1>ModernDive &mdash; Homework planner</h1>',
  sprintf('<p class="lead">Build a homework set: filter by chapter, difficulty, group, or keyword. Check exercises to include, then click <em>Export</em> for a copy-pasteable list. %d exercises total across 11 chapters.</p>',
          length(all_records)),
  '<div class="controls">',
  '<div><label>Chapters</label><div id="chap-checks"></div></div>',
  '<div><label>Difficulty (★/★★/★★★)</label>',
  '<label class="chk"><input type="checkbox" class="diff-check" value="1" checked> ★ (warm-up)</label><br>',
  '<label class="chk"><input type="checkbox" class="diff-check" value="2" checked> ★★ (standard)</label><br>',
  '<label class="chk"><input type="checkbox" class="diff-check" value="3" checked> ★★★ (critical thinking)</label>',
  '</div>',
  '<div><label>Group</label><select id="group-filter"><option value="">(any)</option></select></div>',
  '<div><label>Keyword (in prompt)</label><input type="text" id="keyword" placeholder="e.g., scatterplot, log10, bootstrap"></div>',
  '<div><label>Webr-enabled only?</label><label class="chk"><input type="checkbox" id="webr-only"> Yes &mdash; require a runnable webr-r block</label></div>',
  '</div>',
  '<div id="summary">Loading...</div>',
  '<div id="export">',
  '<button onclick="exportSelection()">Export selected</button>',
  '<button class="secondary" onclick="selectAll()">Select all visible</button>',
  '<button class="secondary" onclick="clearAll()">Clear selection</button>',
  '</div>',
  '<pre id="export-output"></pre>',
  '<table class="results" id="results"><thead><tr><th></th><th>ID</th><th>Diff</th><th>Group / Section</th><th>Prompt (first 220 chars)</th></tr></thead><tbody></tbody></table>',
  '<script>',
  sprintf('const EXERCISES = %s;', json),
  'const state = { chaps: new Set([1,2,3,4,5,6,7,8,9,10,11]), diffs: new Set([1,2,3]), group: "", keyword: "", webrOnly: false, selected: new Set() };',
  '',
  '// Populate chapter checkboxes',
  'const chapDiv = document.getElementById("chap-checks");',
  'for (let c = 1; c <= 11; c++) {',
  '  const lbl = document.createElement("label");',
  '  lbl.className = "chk";',
  '  lbl.innerHTML = `<input type="checkbox" class="chap-check" value="${c}" checked> Ch ${c}`;',
  '  chapDiv.appendChild(lbl);',
  '}',
  '',
  '// Populate group filter',
  'const groups = [...new Set(EXERCISES.map(e => e.group).filter(g => g))].sort();',
  'const groupSel = document.getElementById("group-filter");',
  'groups.forEach(g => {',
  '  const opt = document.createElement("option");',
  '  opt.value = g; opt.textContent = g;',
  '  groupSel.appendChild(opt);',
  '});',
  '',
  'function filteredExercises() {',
  '  const kw = state.keyword.toLowerCase();',
  '  return EXERCISES.filter(e =>',
  '    state.chaps.has(e.chap) &&',
  '    state.diffs.has(e.diff) &&',
  '    (state.group === "" || e.group === state.group) &&',
  '    (kw === "" || (e.prompt_full || "").toLowerCase().includes(kw)) &&',
  '    (!state.webrOnly || e.has_webr)',
  '  );',
  '}',
  '',
  'function render() {',
  '  const exs = filteredExercises();',
  '  const tbody = document.querySelector("#results tbody");',
  '  tbody.innerHTML = "";',
  '  if (!exs.length) {',
  '    tbody.innerHTML = `<tr><td colspan="5" class="empty">No exercises match these filters.</td></tr>`;',
  '  } else {',
  '    exs.forEach(e => {',
  '      const tr = document.createElement("tr");',
  '      const stars = "★".repeat(e.diff);',
  '      const checked = state.selected.has(e.id) ? "checked" : "";',
  '      tr.innerHTML = `<td><input type="checkbox" data-id="${e.id}" ${checked}></td>',
  '        <td class="id">${e.id}${e.has_webr ? " ⚡" : ""}</td>',
  '        <td class="diff diff-${e.diff}">${stars}</td>',
  '        <td class="group">${e.group}<br><small>${e.section}</small></td>',
  '        <td>${e.prompt_short}</td>`;',
  '      tbody.appendChild(tr);',
  '    });',
  '  }',
  '  // Update summary',
  '  const cnt = exs.length;',
  '  const d1 = exs.filter(e => e.diff === 1).length;',
  '  const d2 = exs.filter(e => e.diff === 2).length;',
  '  const d3 = exs.filter(e => e.diff === 3).length;',
  '  document.getElementById("summary").innerHTML =',
  '    `<strong>${cnt}</strong> exercises match (${d1} ★ / ${d2} ★★ / ${d3} ★★★). <strong>${state.selected.size}</strong> currently selected.`;',
  '}',
  '',
  '// Event wiring',
  'document.querySelectorAll(".chap-check").forEach(cb => {',
  '  cb.addEventListener("change", () => {',
  '    state.chaps = new Set([...document.querySelectorAll(".chap-check:checked")].map(x => parseInt(x.value)));',
  '    render();',
  '  });',
  '});',
  'document.querySelectorAll(".diff-check").forEach(cb => {',
  '  cb.addEventListener("change", () => {',
  '    state.diffs = new Set([...document.querySelectorAll(".diff-check:checked")].map(x => parseInt(x.value)));',
  '    render();',
  '  });',
  '});',
  'document.getElementById("group-filter").addEventListener("change", e => { state.group = e.target.value; render(); });',
  'document.getElementById("keyword").addEventListener("input", e => { state.keyword = e.target.value; render(); });',
  'document.getElementById("webr-only").addEventListener("change", e => { state.webrOnly = e.target.checked; render(); });',
  '',
  'document.querySelector("#results tbody").addEventListener("change", e => {',
  '  if (e.target.matches("input[type=checkbox]")) {',
  '    const id = e.target.dataset.id;',
  '    if (e.target.checked) state.selected.add(id); else state.selected.delete(id);',
  '    render();',
  '  }',
  '});',
  '',
  'function selectAll() {',
  '  filteredExercises().forEach(e => state.selected.add(e.id));',
  '  render();',
  '}',
  'function clearAll() { state.selected.clear(); render(); }',
  'function exportSelection() {',
  '  const out = document.getElementById("export-output");',
  '  if (state.selected.size === 0) { out.style.display = "block"; out.textContent = "(no exercises selected)"; return; }',
  '  const sel = EXERCISES.filter(e => state.selected.has(e.id));',
  '  sel.sort((a, b) => a.chap - b.chap || a.ex - b.ex);',
  '  out.style.display = "block";',
  '  out.textContent = "Homework set (" + sel.length + " exercises):\\n\\n" +',
  '    sel.map(e => `${e.id} (${"★".repeat(e.diff)}) — ${e.section || e.group}\\n  ${e.prompt_short}`).join("\\n\\n");',
  '}',
  '',
  'render();',
  '</script>',
  '</body></html>'
)

# Route output into instructor-solutions/_site/ so it sits alongside the
# rendered Quarto pages (syllabus, slides, facilitator notes, worked
# solutions) and the cross-page links between them work.
dir.create("instructor-solutions/_site", showWarnings = FALSE, recursive = TRUE)
out_path <- "instructor-solutions/_site/homework-planner.html"
writeLines(html, out_path)
cat(sprintf("Wrote %s (%d exercises)\n", out_path, length(all_records)))
