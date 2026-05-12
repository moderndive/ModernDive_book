# Diagnostic scripts

Read-only pedagogy / accessibility scans for the ModernDive `v2-quarto-html` branch. Each script is self-contained R (no command-line arguments), prints a structured report to stdout, and **makes no edits** to the book — outputs are punch-lists you act on with separate edits.

Run any script from the repo root:

```sh
Rscript scripts/<name>.R
```

All scripts hard-code the repo path (`/Users/chesterismay/Desktop/repos/ModernDive_book`) at the top — edit the `book <-` line if running elsewhere.

---

## `pedagogy_scans.R` — concept introduction & forward references

Three scans run in one pass:

1. **Cross-chapter dependency audit** — finds every `@sec-*` reference and flags forward dependencies (chapter N referencing material in chapter M > N). Distinguishes mid-chapter forward refs (real flags) from those in Conclusion / Quick checks / Exercises / explicit foreshadowing prose (benign).
2. **First-use lexicon** — for each term in `96-glossary.qmd`, finds the chapter where the glossary's `See @sec-X` link points, then scans earlier chapters' prose for uses of the term. Flags any earlier-chapter prose use as a *potentially* forward-introduced term.
3. **Function-introduction map** — for each function call in code chunks and backticked prose references, tracks `prose-intro` vs `code-intro` chapters; flags functions whose prose-intro precedes code-intro and any prose use of a function before its first code-chunk appearance.

**Example output** (each section already has its own header in the report):

```text
========== SCAN 3: CROSS-CHAPTER DEPENDENCIES ==========
Total forward @sec-* references: 53
  - 52 in Conclusion/Exercises/foreshadowing prose (benign)
  - 1 in MID-CHAPTER prose without foreshadowing language (FLAGGED)

========== SCAN 1: FIRST-USE LEXICON ==========
Total first-use lexicon flags: 5
  Pipe operator (`|>`)           intro=Ch 3  hits=1
  Tidyverse                      intro=Ch 4  hits=4

========== SCAN 2: FUNCTION-INTRODUCTION MAP ==========
Functions where prose-intro precedes code-intro:
  View                      prose-intro=Ch 1  code-intro=Ch 3
  ...
```

**False positives to expect**:

- Functions named in error-message examples (e.g., `ggplot(...) :` in Ch 1's Errors section) — flagged but pedagogically fine.
- Properly foreshadowed terms (e.g., "preview of `tidy_summary()` from @sec-…") — the regex doesn't always catch every foreshadowing phrasing.
- A reference like `@sec-X` immediately preceded by "the upcoming" — current regex misses this exact phrasing.

When sweeping after edits, run again and confirm the targeted flags cleared.

---

## `learning_objective_scans.R` — Quick checks, learning checks, difficulty progression

Three scans:

1. **LC distribution** — for each chapter, locates every inline `::: {.learncheck}` block and maps it to its containing section / subsection. Flags substantial sections (> 80 lines, excluding `Needed packages`, `Conclusion`, `Exercises`, `Quick checks`, `Summary and final remarks`, `Concluding remarks`) with **zero** LC blocks.
2. **Quick-check alignment** — parses the `## Quick checks` block, extracts each `**Qn.** stem...`, and uses keyword overlap against section / subsection titles to *guess* which subsection each QC targets. Flags substantial subsections with no keyword match.
3. **Difficulty progression** — for each exercise YAML `group`, prints the difficulty sequence (e.g., `233322`) in YAML order. Flags any group containing `★★★` (`3`) but no `★★` (`2`) as a missing-rung candidate.

**Example output** (excerpted):

```text
========== SCAN 5: LC DISTRIBUTION ==========

--- Chapter 9 (09-hypothesis-testing.qmd) — 4 LC blocks total ---
  ...
  FLAG — substantial sections (>80 lines) with NO LC blocks:
    - Tying confidence intervals to hypothesis testing (lines 89-491, length 403)
    ...

========== SCAN 6: DIFFICULTY PROGRESSION ==========

--- Chapter 10 ---
  Theory-based inference for simple regression       2232
  Simulation-based inference for simple regression   23223
  ...
  Critical thinking and synthesis                    33333333333  <<< missing ★★ rung
```

**Reading the output**:

- The QC keyword matcher is *fuzzy*. A "no keyword match" flag does NOT mean the section isn't covered — it means the QC stem doesn't share content words with the section title. Always read the QC stem before acting (e.g., a QC about "slope coefficient" actually covers `5.1 One numerical explanatory variable`, but won't match by keywords).
- Difficulty `<<< missing ★★ rung` is true by definition for "Critical thinking and synthesis" groups — that's by design (the whole group is `★★★`). Real flags are non-critical-thinking groups with multiple `3`s and no `2`.

---

## `cross_reference_scans.R` — dead anchors, forward refs, glossary coverage

Three scans for navigation health:

1. **Dead anchors** — every `@sec-*` / `@fig-*` / `@tbl-*` reference must resolve to an anchor that exists somewhere in the book. Anchors are collected from both explicit `{#name}` declarations *and* implicit chunk-label auto-anchors (`fig-X`, `tbl-X`). Filters: HTML-comment-wrapped references (multi-line `<!-- ... -->` spans) are stripped before scanning. En-dash range notation (`@sec-X--@sec-Y`) is handled by stripping trailing hyphens from captured anchors.
2. **Stale forward refs** — lists every prose sentence containing forward-pointing language ("we'll see…", "in the upcoming @sec-X", "in Chapter N", "Starting with…", "is the subject of") *and* a reference whose target chapter sits later in the book. Output is intended for spot-check verification: the script can't tell whether the target chapter still contains the promised material, only that the sentence is making a forward-promise.
3. **Glossary coverage** — flags `**bolded**` vocabulary in chapter prose that doesn't match a glossary entry. Matching is generous: case-insensitive, singular/plural, substring against entry titles, *and* against italicized cross-reference terms inside entry bodies (e.g., the *Estimator* entry italicizes "unbiased" and "biased", so those are auto-aliased to the same entry). Heavy filters strip out structural bolding (`**Q1.**`, `**(b)**`, `**Solution**`, `**Note:**`, etc.), inline R code expressions, math expressions, sentence-emphasis bolding, author names, and the `00-foreword.qmd` / `00-preface.qmd` files (which have lots of non-vocabulary list-item bolding).

**Example output**:

```text
========== SCAN 7: DEAD ANCHORS ==========
Total cross-references scanned: 836
Dead references found: 2

  [07-sampling.qmd]
    L150   @fig-sampling-exercise-3b-1 -- not found
    L1642  @sec-mult-reg -- not found

========== SCAN 8: STALE FORWARD-REFERENCE PROSE ==========
Forward-pointing prose sentences found: 38
  ...

========== SCAN 9: GLOSSARY COVERAGE ==========
Most-bolded non-glossary terms (top 30):
  estimator                                          : 5
  sample mean                                        : 4
  two-sided                                          : 2
  ...
```

**Reading the output**:

- Scan 8 is *not* a flag list — it's an inventory for human review. Most "forward refs" are properly foreshadowed (Conclusion sections, preface table-of-contents, explicit "in upcoming @sec-X" wording). What you're checking is whether the *target chapter still contains the promised material* (e.g., if Ch 7 prose says "we'll see in @sec-X", confirm @sec-X still teaches the topic the prose alludes to).
- Scan 9's top-N table is the actionable view; the per-file detail below is for finding the exact location once you decide a term deserves a glossary entry. A flag does *not* mean the term needs a glossary entry — many are emphasis, variable-name labels, or method-step headers. Use judgment.

---

## `alt_text_audit.R` — figure alt-text accessibility audit

Scans every `.qmd` in the repo (excluding `96-glossary`, `99-references`, `index`) for figure-producing code chunks and markdown image syntax, then flags missing or low-quality alt text.

**Three figure patterns checked**:

1. R chunk with figure-producing body (`ggplot`/`geom_*`/`include_graphics`/`grid.arrange`/`patchwork`/`visualize`/etc.) — alt text expected via `fig.alt = "..."` in chunk header
2. Markdown image syntax `![alt](path)` — alt expected between the brackets
3. `include_graphics()` inside an R chunk — alt text inherited from enclosing chunk's `fig.alt=`

**Filters applied** (to avoid false positives):

- `eval=FALSE` chunks (code-display only, no figure rendered)
- `include=FALSE` chunks (suppressed entirely)
- `fig.show='hide'` chunks (figure generated but hidden — usually a setup pair where the visible sibling has alt)
- `{webr-r}` chunks (interactive widgets, not static figures)

**Four flag categories**:

- `MISSING` — chunk renders a figure but has no `fig.alt=` option
- `EMPTY` — alt-text attribute is present but empty (e.g., `![](path)`)
- `SHORT` — alt text < 25 characters (typically not descriptive)
- `CAPTION` — alt text identical to `fig.cap=` (alt should describe the *visual*, not duplicate the caption)

**Example output** (excerpted):

```text
Scanned 18 chapter qmd files.
  Figure-producing code chunks: 207
  Markdown images (`![...](...)`): 10
  Total flags: 72

=== MISSING (62) ===
  [02-visualization.qmd]  (17 flags)
    L358   fig-jitter-example-plot-1
      ```{r fig-jitter-example-plot-1, fig.cap="...", echo=FALSE, ...}
    ...

=== EMPTY (10) ===
  [01-getting-started.qmd]  (4 flags)
    L60    images/shutterstock/shutterstock_111774881.jpg
    ...
```

**Reading the output**: by-file flag totals at the section headers (`[02-visualization.qmd] (17 flags)`) are the easiest scoreboard. Re-run after adding alt to confirm flag counts drop.

---

## Adding a new scan

Each script is self-contained — copy one (e.g. `alt_text_audit.R`) and adapt:

1. Top stanza sets `book <-` and `setwd()` so paths are predictable.
2. Read chapter files into a list keyed by chapter number.
3. Apply a classifier (`classify_lines()` in the other scripts) to mark prose vs code vs fence lines — most scans care about prose only.
4. Walk lines, collect flags into `list()`, then bucket and print a structured report at the end.
5. Output goes to stdout so a downstream `| grep` / `sed` can slice the report by chapter or category.

**Keep scans read-only.** None of these scripts edits the book — that separation makes the diff after a fix easy to verify (run the script before and after, compare flag counts).
