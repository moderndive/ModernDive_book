# Exercise rendering helpers.
#
# Single-source authoring for end-of-chapter exercises. Per chapter, all prompts,
# solutions, and section/subsection assignments live in `exercises/NN.yml`. Two
# rendering functions emit markdown for the chapter qmd and the solutions qmd
# respectively, plus a third that auto-builds the section-coverage callout.
#
# Conventions:
# - Chunk labels in `solution` should follow `NN-ex-N`, `NN-ex-N-b`, etc.
# - `webr` field is *optional* — omit for reasoning-only exercises.
# - `book_section` and `book_subsection` drive the coverage tables; their
#   *order of first appearance* is preserved.

suppressPackageStartupMessages({
  library(yaml)
})

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

ex_helpers_stars <- function(n) strrep("★", as.integer(n))

# Extensions use diamonds instead of stars to signal "bonus / exploratory"
# vs. "graded assessment".
ex_helpers_difficulty_marker <- function(n, group) {
  symbol <- if (identical(group, "Extensions")) "◆" else "★"
  strrep(symbol, as.integer(n))
}

ex_helpers_id <- function(chapter, ex_num) sprintf("EX%d.%d", chapter, ex_num)

# Collapse a vector of `EXc.n` ids into a comma-separated string where any
# run of three or more consecutive ex_nums is rendered as `EXc.start–EXc.end`
# (en dash). Two-element runs stay listed as `EXc.a, EXc.b` since `a–b` would
# save no characters. Single ids are left alone.
ex_helpers_collapse_runs <- function(ids, chapter) {
  if (length(ids) == 0) return("")
  nums <- as.integer(sub("^EX[0-9]+\\.", "", ids))
  parts <- character()
  start <- nums[1]; prev <- nums[1]
  flush <- function(s, e) {
    if (e - s >= 2) sprintf("EX%d.%d–EX%d.%d", chapter, s, chapter, e)
    else if (e == s) sprintf("EX%d.%d", chapter, s)
    else sprintf("EX%d.%d, EX%d.%d", chapter, s, chapter, e)
  }
  for (i in seq_along(nums)[-1]) {
    if (nums[i] == prev + 1) {
      prev <- nums[i]
    } else {
      parts <- c(parts, flush(start, prev))
      start <- nums[i]; prev <- nums[i]
    }
  }
  parts <- c(parts, flush(start, prev))
  paste(parts, collapse = ", ")
}

ex_helpers_load <- function(chapter) {
  # Search the same yml at several relative depths so this helper works when
  # called from book root (`exercises/...`), instructor-solutions/
  # (`../exercises/...`), or instructor-solutions/solutions/
  # (`../../exercises/...`) — the last case applies after the v2.8.13
  # restructure moved the worked-solutions page a level deeper.
  find_yml <- function(rel) {
    candidates <- c(rel, file.path("..", rel), file.path("..", "..", rel))
    Find(file.exists, candidates)
  }
  pub_path <- find_yml(sprintf("exercises/%02d.yml", chapter))
  data <- yaml::read_yaml(pub_path)

  # Solutions live in a separate gitignored file `exercises/NN-solutions.yml`
  # that ships only to instructors. If absent (e.g., a student clone), we
  # fill in placeholders so the helper still renders gracefully.
  priv_path <- find_yml(sprintf("exercises/%02d-solutions.yml", chapter))
  if (is.null(priv_path)) priv_path <- sprintf("exercises/%02d-solutions.yml", chapter)
  if (file.exists(priv_path)) {
    priv <- yaml::read_yaml(priv_path)
    sol_by_ex <- setNames(priv$exercises,
                          vapply(priv$exercises, function(e) as.character(e$ex_num),
                                 character(1)))
    for (i in seq_along(data$exercises)) {
      ex_num <- as.character(data$exercises[[i]]$ex_num)
      if (!is.null(sol_by_ex[[ex_num]])) {
        data$exercises[[i]]$solution_ref <- sol_by_ex[[ex_num]]$solution_ref
        data$exercises[[i]]$solution     <- sol_by_ex[[ex_num]]$solution
      }
    }
  } else {
    for (i in seq_along(data$exercises)) {
      data$exercises[[i]]$solution_ref <- "instructor edition"
      data$exercises[[i]]$solution <- "*Solution available in the instructor edition only.*"
    }
  }

  data
}

# A reusable note emitted once at the top of the "Extensions" group.
ex_helpers_extensions_callout <- function() c(
  '::: {.callout-note appearance="simple" title="About these Extensions"}',
  'The exercises below **deliberately introduce functions and concepts beyond what this chapter teaches** — log transformations, `predict()`, new packages, foreshadowing later chapters. They are *optional*, aimed at readers who want to push further. The main Exercises and Quick checks above stick strictly to what this chapter covers.',
  ':::',
  ''
)

# A page-top control that expands/collapses every per-exercise question callout
# at once. Each exercise's question renders collapsed (`collapse="true"`); this
# button flips them all so an instructor can read the whole question set — a
# "question paper" view — without clicking each one. Pure DOM class-toggling
# (no Bootstrap JS dependency), scoped to the collapsible `#ex-<ch>-<n>`
# callouts by id prefix so the non-collapsible "About these Extensions" note is
# left alone. Emitted via a raw-HTML block so pandoc passes the <script> through.
ex_helpers_expand_all_toolbar <- function() c(
  '```{=html}',
  '<div class="solutions-toolbar" style="margin:0.75rem 0 1.25rem;">',
  '  <button id="toggle-all-questions" class="btn btn-sm btn-outline-secondary" type="button" aria-pressed="false">Show all questions</button>',
  '</div>',
  '<script>',
  '(function () {',
  '  function ready(fn){ if (document.readyState !== "loading") fn(); else document.addEventListener("DOMContentLoaded", fn); }',
  '  ready(function () {',
  '    var btn = document.getElementById("toggle-all-questions");',
  '    if (!btn) return;',
  '    function panels(){ return Array.prototype.slice.call(document.querySelectorAll(\'div.callout[id^="ex-"]\')); }',
  '    function setOpen(callout, open){',
  '      var header = callout.querySelector(\'.callout-header[data-bs-toggle="collapse"]\');',
  '      var body = callout.querySelector(".callout-collapse.collapse");',
  '      if (!header || !body) return;',
  '      header.classList.toggle("collapsed", !open);',
  '      header.setAttribute("aria-expanded", open ? "true" : "false");',
  '      body.classList.toggle("show", open);',
  '    }',
  '    var open = false;',
  '    btn.addEventListener("click", function () {',
  '      open = !open;',
  '      panels().forEach(function (c){ setOpen(c, open); });',
  '      btn.textContent = open ? "Hide all questions" : "Show all questions";',
  '      btn.setAttribute("aria-pressed", open ? "true" : "false");',
  '    });',
  '  });',
  '})();',
  '</script>',
  '```',
  ''
)

# Markdown for the chapter qmd's `## Exercises` body — group headers, prompts,
# and {webr-r} blocks. Author writes the rest of the section (intro, difficulty
# legend, setup chunk) directly in the qmd.
render_chapter_exercises <- function(chapter) {
  data <- ex_helpers_load(chapter)
  out <- character()
  # Chapter-level note rendered ahead of all exercises (e.g. a data-source
  # attribution that must appear before the dataset's first use).
  data_note <- data$chapter_meta$data_note
  if (!is.null(data_note) && nzchar(data_note)) {
    out <- c(out, trimws(data_note), "")
  }
  current_group <- NULL
  for (ex in data$exercises) {
    cat(sprintf("    ▸ EX%d.%d\n", chapter, ex$ex_num), file = stderr())
    flush(stderr())

    if (!is.null(ex$group) && nzchar(ex$group) &&
        (is.null(current_group) || !identical(ex$group, current_group))) {
      out <- c(out, "", sprintf("### %s {.unnumbered}", ex$group), "")
      if (identical(ex$group, "Extensions")) {
        out <- c(out, ex_helpers_extensions_callout())
      }
      current_group <- ex$group
    }
    id <- ex_helpers_id(chapter, ex$ex_num)
    star_str <- ex_helpers_difficulty_marker(ex$difficulty, ex$group)
    out <- c(out, sprintf("**%s (%s)** %s", id, star_str, trimws(ex$prompt)))
    if (!is.null(ex$webr) && nzchar(ex$webr)) {
      out <- c(out, "", "```{webr-r}", trimws(ex$webr, which = "right"), "```")
    }
    out <- c(out, "")
  }
  paste(out, collapse = "\n")
}

# Markdown for the solutions qmd body — group headers, callout-note blocks
# wrapping each prompt, then the solution narrative + chunks.
#
# Solutions often contain `{r ...}` chunks. Because the qmd embeds this via
# `cat(render_solutions(N))` with `results="asis"`, knitr has already finished
# its evaluation pass by the time `cat` runs — so any chunks inside the cat-ed
# text would render as raw text, not be executed. We therefore call
# `knitr::knit_child()` to run knitr on the assembled text *before* returning,
# yielding markdown with chunk outputs already substituted in.
#
# Implementation detail: we knit_child() *per exercise* rather than once for
# the whole chapter. This is slightly slower than a single knit_child call
# but gives visible per-exercise progress in the Quarto build log (via a
# stderr message printed before each exercise renders), so when a render
# hangs we know exactly which exercise to investigate.
render_solutions <- function(chapter) {
  data <- ex_helpers_load(chapter)
  .ch_t0 <- Sys.time()
  cat(sprintf("\n========== Chapter %d solutions: rendering %d exercises ==========\n",
              chapter, length(data$exercises)), file = stderr())
  flush(stderr())
  out <- character()
  # Chapter-level note (e.g. data-source attribution) ahead of all solutions,
  # mirroring render_chapter_exercises().
  data_note <- data$chapter_meta$data_note
  if (!is.null(data_note) && nzchar(data_note)) {
    out <- c(out, trimws(data_note), "")
  }
  # Page-top control to reveal every collapsed question at once (all chapters).
  out <- c(out, ex_helpers_expand_all_toolbar())
  current_group <- NULL
  # Every group heading appears in the sidebar TOC. (A previous 5-entry cap
  # pinned "Extensions"/"Critical thinking…" and hid the rest; but with the
  # book's per-section groups every chapter now has ~9–11 groups, so the cap hid
  # the majority of sections from navigation. All groups are listed instead.)
  groups_seen <- character()
  for (ex in data$exercises) {
    g <- ex$group %||% NA_character_
    if (!is.na(g) && nzchar(g) && !(g %in% groups_seen)) {
      groups_seen <- c(groups_seen, g)
    }
  }
  visible_groups <- groups_seen
  # When the same group label re-appears non-contiguously in the YAML, only
  # the first emission gets a TOC entry; later re-emissions are forced
  # `.unlisted` so the TOC doesn't show "Observed/fitted values..." twice.
  emitted_visible <- character()

  for (ex in data$exercises) {
    .ex_t0 <- Sys.time()
    cat(sprintf("    ▸ EX%d.%d\n", chapter, ex$ex_num), file = stderr())
    flush(stderr())

    if (!is.null(ex$group) && nzchar(ex$group) &&
        (is.null(current_group) || !identical(ex$group, current_group))) {
      is_first_visible <- ex$group %in% visible_groups &&
                          !(ex$group %in% emitted_visible)
      heading_attrs <- if (is_first_visible) "" else " {.unlisted}"
      if (is_first_visible) emitted_visible <- c(emitted_visible, ex$group)
      out <- c(out, "", sprintf("### %s%s", ex$group, heading_attrs), "")
      if (identical(ex$group, "Extensions")) {
        out <- c(out, ex_helpers_extensions_callout())
      }
      current_group <- ex$group
    }
    id <- ex_helpers_id(chapter, ex$ex_num)
    star_str <- ex_helpers_difficulty_marker(ex$difficulty, ex$group)
    body <- trimws(ex$solution, which = "right")
    ex_text <- paste(c(
      sprintf('::: {.callout-note collapse="true" title="%s — show question" #ex-%d-%d}', id, chapter, ex$ex_num),
      sprintf("**%s (%s)** %s", id, star_str, trimws(ex$prompt)),
      ":::",
      "",
      sprintf("**Solution** %s*(reference: %s)*.",
              if (!is.null(ex$hash) && nzchar(ex$hash))
                sprintf("`#%s` ", ex$hash) else "",
              ex$solution_ref),
      "",
      body,
      "",
      "***",
      ""
    ), collapse = "\n")
    out <- c(out, knitr::knit_child(text = ex_text, quiet = TRUE))
    cat(sprintf("    ↳ EX%d.%d %.2fs\n", chapter, ex$ex_num,
                as.numeric(Sys.time() - .ex_t0, units = "secs")), file = stderr())
    flush(stderr())
  }
  cat(sprintf("========== Chapter %d done in %.1fs ==========\n", chapter,
              as.numeric(Sys.time() - .ch_t0, units = "secs")), file = stderr())
  flush(stderr())
  paste(out, collapse = "\n")
}

# The section-coverage callout (two tables + the chapter's coverage note).
#
# Section ordering: by first appearance in the YAML (preserves chapter content
# order). `chapter_meta$empty_sections` may list sections to show with count 0
# (e.g., "2.2 Five named graphs" — covered nowhere but called out for honesty).
#
# Subsection ordering: subsections are grouped under their parent section (in
# the section order above), then sorted alphabetically within the section.
# This matches book-numeric order for labels like "2.8.1" / "2.8.2" / "2.8.3".
render_coverage_callout <- function(chapter) {
  data <- ex_helpers_load(chapter)
  exercises <- data$exercises
  meta <- data$chapter_meta %||% list()

  sections <- vapply(exercises, function(e) e$book_section, character(1))
  subsections <- vapply(exercises, function(e) e$book_subsection, character(1))
  ids <- vapply(exercises, function(e) ex_helpers_id(chapter, e$ex_num), character(1))

  # Section table: first-appearance order, plus optional empty-sections list
  # inserted at the position the author specifies (or appended at the end).
  section_order_observed <- unique(sections)
  empty_sections <- meta$empty_sections %||% character()
  insert_after <- meta$empty_sections_after %||% list()

  section_order <- section_order_observed
  for (i in seq_along(empty_sections)) {
    es <- empty_sections[[i]]
    after <- insert_after[[i]] %||% NULL
    if (!is.null(after) && after %in% section_order) {
      pos <- match(after, section_order)
      section_order <- append(section_order, es, after = pos)
    } else {
      section_order <- c(section_order, es)
    }
  }

  section_counts <- vapply(section_order,
                           function(s) sum(sections == s), integer(1))

  # Subsection-to-section mapping from observed exercises.
  sub_to_section <- setNames(sections, subsections)
  sub_to_section <- sub_to_section[!duplicated(names(sub_to_section))]

  # Order subsections by parent section's position, then alphabetically within.
  unique_subs <- unique(subsections)
  parent_idx <- match(sub_to_section[unique_subs], section_order_observed)
  subsection_order <- unique_subs[order(parent_idx, unique_subs)]

  subsection_ids <- vapply(subsection_order,
                           function(s) ex_helpers_collapse_runs(ids[subsections == s], chapter),
                           character(1))

  out <- c(
    '::: {.callout-tip title="Section coverage at a glance" collapse="false" appearance="simple"}',
    '',
    '**Exercises per section** — count of prompts that touch each book section.',
    '',
    '| Book section | # of exercises |',
    '|---|---:|'
  )
  out <- c(out, sprintf("| %s | %d |", section_order, section_counts))
  out <- c(out, '',
    '**Exercises by subsection** — which prompts target each finer-grained subsection.',
    '',
    '| Subsection | Exercises |',
    '|---|---|')
  out <- c(out, sprintf("| %s | %s |", subsection_order, subsection_ids))

  if (!is.null(meta$coverage_note) && nzchar(meta$coverage_note)) {
    out <- c(out, '', trimws(meta$coverage_note))
  }

  out <- c(out, '', ':::')
  paste(out, collapse = "\n")
}
