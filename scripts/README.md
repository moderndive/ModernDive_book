# `scripts/` — book code, helpers, and tooling

This folder holds every R / shell / Perl script the book project uses, organized by *role*. Scripts fall into four buckets:

| Role | Files | Run when? |
|---|---|---|
| **Render-time helpers** | `exercise_helpers.R`, `image_functions.R`, `setup_exercise_packages.R`, `post-render-cleanup.sh` | Automatically, every Quarto render |
| **Manual build helpers** | `pdf_build_from_tex.R` | By hand, when building the print/PDF edition |
| **Diagnostic audits** | `alt_text_audit.R`, `cross_reference_scans.R`, `learning_objective_scans.R`, `pedagogy_scans.R`, `lint_exercise_yaml.R` | By hand, to find punch-list items |
| **Reports** | `exercise_coverage_map.R` | By hand, to generate an instructor-facing coverage HTML |
| **Migration tools** | `convert_bookdown.pl`, `fix-chapter-refs.pl`, `learning-checks/` | Historical; one-shot for bookdown→Quarto and V1→V2 |
| **Archive** | `archive/purl.R` | Never (kept for git history reference) |

All audit scripts are read-only — they print structured punch-lists to stdout and never modify book content.

Most scripts hard-code the repo path (`/Users/chesterismay/Desktop/repos/ModernDive_book`) at the top — edit the `book <-` line if running elsewhere. From the repo root:

```sh
Rscript scripts/<name>.R
```

---

## Render-time helpers (sourced by Quarto during render)

### `exercise_helpers.R`
Renders end-of-chapter exercises and solutions from `exercises/NN.yml`. Called from every chapter qmd's `## Exercises` block via `render_chapter_exercises(N)` and from `exercise-solutions/NN_ex.qmd` via `render_solutions(N)`. Also produces the "Section coverage at a glance" callout for each solutions chapter. Treats `exercises/NN.yml` as the canonical source — chapter prompts and solutions never diverge.

### `image_functions.R`
Helper functions called from every chapter's `setup-init` chunk: `version`, `dev_version`, `needed_CRAN_pkgs`, plus assorted small utilities. Quarto runs each chapter in its own R session, so this file is sourced at the top of every chapter qmd to set up shared state.

### `setup_exercise_packages.R`
Defines `EXERCISE_PACKAGES`, the list of dataset packages the end-of-chapter exercises rely on (`olympicAthletes`, `steves`, `exoplanets`, `volcanoes`, plus the CRAN packages). Each entry has a `from_github` flag — flip it to `FALSE` when a package lands on CRAN and the install pipeline switches without other changes.

### `post-render-cleanup.sh`
Post-render hook configured in `_quarto.yml` (`post-render: scripts/post-render-cleanup.sh`). Cleans up macOS Cocoa render artifacts that Quarto leaves in the working tree.

---

## Manual build helpers

### `pdf_build_from_tex.R`
Standalone script to build the print/PDF edition. Run by hand when preparing a CRC Press release; not called during normal HTML builds.

---

## Diagnostic audits (read-only)

Each prints a structured punch-list. Re-run any audit after addressing flags to verify they cleared.

### `pedagogy_scans.R` — concept introduction & forward references

Three scans in one pass:

1. **Cross-chapter dependency audit** — every `@sec-*` reference; flags forward dependencies (chapter N referencing material in M > N). Distinguishes mid-chapter forward refs (real flags) from those in Conclusion / Quick checks / Exercises / explicit foreshadowing prose (benign).
2. **First-use lexicon** — for each glossary term, finds its intro chapter (via `See @sec-X`), then scans earlier chapters' prose for uses of the term.
3. **Function-introduction map** — tracks `prose-intro` vs `code-intro` chapters per function; flags prose mentions before code-chunk introductions.

False positives to expect: error-message examples (e.g., `ggplot(...) :` in Ch 1), foreshadowed terms with non-standard phrasing, near-miss preceding text like "the upcoming @sec-X".

### `learning_objective_scans.R` — Quick checks, learning checks, difficulty progression

Three scans:

1. **LC distribution** — maps every inline `::: {.learncheck}` block to its containing section/subsection. Flags substantial sections (>80 lines) with zero LC blocks.
2. **Quick-check alignment** — keyword-overlap match between each `## Quick checks` Q-stem and chapter section titles. Flags substantial subsections with no keyword match. Output is *fuzzy*: read the Q-stem before acting.
3. **Difficulty progression** — for each exercise YAML `group`, prints the difficulty sequence (e.g., `233322`) in YAML order. Flags groups containing `★★★` (`3`) but no `★★` (`2`).

Reading: "Critical thinking and synthesis" groups will always flag — that's by design.

### `alt_text_audit.R` — figure alt-text accessibility audit

Three figure patterns checked: R chunks with `fig.alt=`, markdown `![alt](path)` images, and `include_graphics()` calls inside chunks. Flags:

- `MISSING` — chunk renders a figure but no `fig.alt=`
- `EMPTY` — alt attribute present but empty (e.g., `![](path)`)
- `SHORT` — alt text < 25 characters
- `CAPTION` — alt text identical to `fig.cap=`

Filters out non-rendering chunks (`eval=FALSE`, `fig.show='hide'`, `{webr-r}`, HTML-comment-wrapped markdown images).

### `lint_exercise_yaml.R` — exercise YAML linter

Validates every `exercises/NN.yml` (and `NN-solutions.yml` if present locally) catches authoring bugs *before* render:

1. **Required fields** — `ex_num`, `difficulty`, `prompt` on every entry; `group` and `book_section` recommended (warning).
2. **Difficulty** must be 1, 2, or 3 (error).
3. **Unique `ex_num`** within a chapter (error).
4. **Code-needing prompt without `webr` field** — heuristic on prompt verbs like "fit", "plot", "compute"; flags as warning so reasoning-only prompts don't false-positive.
5. **Solution `ex_num` ⊆ prompt `ex_num`** — no orphan solutions (warning).
6. **`book_section` value matches an actual chapter section title** — typo-catching (warning).

Exits non-zero on errors; warnings print without failing. Wired into the `Audits` CI workflow so PRs that introduce malformed YAML fail before render.

### `exercise_coverage_map.R` — instructor-facing coverage report

Reads every `exercises/NN.yml` and emits `instructor-solutions/coverage-map.html`: per-chapter tables showing each section/subsection, the count of exercises targeting it, the exercise-ID list (collapsed to en-dash ranges), and a difficulty histogram. Sections with ≤ 1 exercise are highlighted in red.

The output is gitignored — regenerate on demand:

```sh
Rscript scripts/exercise_coverage_map.R
open instructor-solutions/coverage-map.html
```

### `cross_reference_scans.R` — dead anchors, forward refs, glossary coverage

Three scans:

1. **Dead anchors** — every `@sec-*`/`@fig-*`/`@tbl-*` reference must resolve to an anchor (explicit `{#name}` *or* implicit chunk-label auto-anchor like `fig-X`/`tbl-X`). Strips HTML-comment-wrapped references and en-dash range notation.
2. **Stale forward refs** — lists every prose sentence with forward-pointing language ("we'll see…", "in upcoming @sec-X", "in Chapter N") *and* a reference whose target chapter sits later. Output is for human spot-check (script can't verify whether the target still contains the promised material).
3. **Glossary coverage** — flags `**bolded**` vocabulary in chapter prose without a glossary match. Matching is generous: case-insensitive, singular/plural, substring against entry titles, *and* against italicized cross-reference terms inside entry bodies. Heavy filters strip structural bolding, R inline code, math, sentence-emphasis bolding, author names, and the `00-foreword.qmd` / `00-preface.qmd` files.

---

## Migration tools (one-shot)

### `convert_bookdown.pl`
Perl script that did the bookdown→Quarto syntax conversion: `\@ref(fig:x)` → `@fig-x`, `:::{learncheck}` → `::: {.learncheck}` (with space), prepended `setup-init` chunks, etc. Kept for reference; not expected to be re-run.

### `fix-chapter-refs.pl`
Companion to `convert_bookdown.pl` — patched chapter-to-chapter references during the same migration.

### `learning-checks/`
Tools for comparing V1 vs V2 learning-check content (`count_lcs.R`, `smart-compare.R`, `strip_lcs_from_chapters.R`) plus the diff CSV (`all_v1_v2_lc_diffs.csv`) and per-chapter source dirs (`lc/`, `v1/`). Used during the V1→V2 rewrite; preserved here for traceability.

---

## Archive

### `archive/purl.R`
Bookdown-era helper that auto-generated `.R` script files of book code into `docs/scripts/` from each chapter at render time. Not called by the current Quarto build (`index.qmd` no longer sources it). Kept under `archive/` for git-history reference; safe to delete if you're confident nothing depends on its output.

---

## Adding a new scan

Each diagnostic is self-contained. To add one, copy an existing audit (e.g., `alt_text_audit.R`):

1. Top stanza sets `book <-` and `setwd()` so paths are predictable.
2. Read chapter files into a list keyed by chapter number (or filename).
3. Apply a classifier (`classify_lines()` in the other scripts) to mark prose vs code vs fence lines — most scans care about prose only.
4. Walk lines, collect flags into `list()`, then bucket and print a structured report at the end.
5. Output goes to stdout; downstream `| grep` / `sed` can slice the report by chapter or category.

**Keep audits read-only.** None of these scripts edit the book — that separation makes the diff after a fix easy to verify (run the script before and after, compare flag counts).
