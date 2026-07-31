# ModernDive 2.8.21 — Instructor materials moved to a private repo

The `instructor-solutions/` hub (worked solutions, facilitator notes, slide decks, syllabus, rubrics, exam bank, …) and the `scripts/build_*.R` report generators have been **removed from this public repo**. They now live in the private companion repo [`moderndive-instructor-resources`](https://github.com/moderndive/moderndive-instructor-resources) (renamed from `moderndive_exercise_solutions`), alongside the exercise solutions — keeping answer keys, exams, rubrics, and teaching notes out of the public source tree.

* The public book is unaffected: `instructor-solutions/` was always a separate Quarto project, never part of the book's render list.
* The companion repo's CI clones this book, restores the instructor content into the tree, then renders + encrypts + publishes the hub as before.
* Shared pieces stay here: chapter qmds, the exercise *prompts* (`exercises/NN.yml`), and `scripts/exercise_helpers.R`.
* `.gitignore` now excludes `/instructor-solutions/` and `/scripts/build_*.R`, so `sync_to_book.sh` can restore them locally for rendering without risk of re-committing them publicly.

(The removed files remain in this repo's earlier git history — they were deleted going forward, not purged.)

# ModernDive 2.8.20 — Faster webR setup: .csv.gz → .rds mirrors

The "Evaluating hidden code cell" delay students saw before any interactive cell was usable was dominated by `read.csv(gzfile(...))` parsing 315 090 rows of olympic_athletes in wasm R. Switching the shadow library's CSV mirrors to R's native binary format (`.rds`) gives:

* **~50 % first-visit setup speedup** — locally measured ch 11 setup (the heaviest, loads all four GitHub-only packages + the three moderndive top-ups) dropped from ~10–15 s to **6.2 s** in real webR. `readRDS()` skips CSV parsing entirely and is roughly 2× faster than `read.csv(gzfile())` on the big file (benchmarked locally: 0.47 s vs 0.86 s; speedup is amplified in wasm).
* **~37 % bandwidth reduction on the big file** — `olympic_athletes.rds` with `compress = "xz"` is 3.2 MB vs the previous 5.8 MB `.csv.gz`. The other 9 mirrors stay on default gzip (xz overhead isn't worth it under 1 MB; sizes within 10 % of the previous `.csv.gz`).

Concrete changes:

* `scripts/webr-shadow-library.R` — file extensions `.csv.gz` → `.rds` throughout `pkg_data` and `pkg_extras$moderndive`; `load_from_mirror` swaps `read.csv(gzfile(tmp))` for `readRDS(tmp)`.
* Ten new `.rds` files in `data/`. The previous `.csv.gz` files are no longer referenced but left in place (orphan but harmless).
* No curriculum or student-code impact: loaded data frames are identical.

Verified end-to-end with the Layer C headless-webR CI job (`scripts/test_webr_headless/`) — all 53 webR cells across chapters 1-11 + Appendix B pass.

**Not pursued (yet):** persistent webR filesystem cache via IDBFS for cross-visit caching. Quarto-webr doesn't expose a stable hook to mount the IndexedDB filesystem before cells run, and the bigger pain (first-visit latency) is already addressed by this change. Documented as a deferred enhancement.

***

# ModernDive 2.8.19 — Three-layer CI test pyramid catches webR breakage

The 2.8.16–2.8.18 webR work fixed bugs by hand, but nothing in the audit pipeline watched the webR surface — every regression slipped through until a student tried to run a cell. Three new jobs in `.github/workflows/audits.yml` now guard webR:

* **Layer A — static scan** (`scripts/audit_webr_symbols.R`). Walks every `{webr-r}` cell in chapter qmds + Appendix B and every `webr:` field in `exercises/*.yml`; flags bare data symbols that aren't loaded by the chapter's setup (via `library()` — with shadow mapping for the four GitHub-only packages — or top-level `X <- …` assignments) and aren't in webR's preloaded-package datasets or built-ins. Fast (<30 s), fails CI on any flag.
* **Layer B — server-side eval** (`scripts/test_webr_cells.R`). Installs the 9 webR-preloaded CRAN packages + the 4 GitHub-only ones + every other package exercise cells `library()` (broom, MASS, conflicted, janitor, pwr, readxl, stringr), then runs every `{webr-r}` cell in plain R. Matches Quarto/webR ordering (`#| context: setup` first, then file order). Catches logic errors, wrong column names, undefined intermediates — bugs static analysis can't see. **Caught the ch5 `UN_data_ch5` rebind-with-wrong-columns bug on first local run** — the line ~160 webR cell was `filter`-only (leaving columns named `life_expectancy_2022`), which silently clobbered the setup's `select(life_exp = …, fert_rate = …)` rename and broke every downstream cell. Fixed in this commit.
* **Layer C — headless webR-in-Node** (`scripts/test_webr_headless/test_webr.mjs`). Node script using `@r-wasm/webr` (pinned to 0.2.0) that initialises a real headless webR (browser-side R compiled to wasm), installs the preload list, and evaluates every cell with `globalenv()` cleared between chapters. **Surfaced a real webR runtime bug** (see below) that would have stayed latent until someone clicked Run.

Supporting changes:

* **Shadow `library()` is now environment-aware** (`scripts/webr-shadow-library.R`). The earlier version always loaded GitHub-only datasets from the CSV mirror, even in regular R where the package was installed. `requireNamespace()` check now means: real package installed → delegate to `base::library()` (local R + Layer B CI); not installed → CSV-mirror path (webR + Layer C). Same student behaviour in both environments.
* **Shadow now uses `download.file() + read.csv(gzfile(tmp))` instead of `readr::read_csv()`.** Layer C surfaced that webR's `readr::read_csv()` hangs indefinitely on `.csv.gz` URLs (even tiny 50 KB ones) — gzip decoding from a remote stream isn't wired up in webR. It also hangs on plain `.csv` URLs (ch4's `dem_score <- read_csv(...)` was the trigger). The base-R `download.file()` + `read.csv()` chain works in both webR and regular R; verified locally with `ch1 setup` (downloads + decodes the 5.8 MB olympic_athletes plus the two small olympicAthletes datasets) in 2.9 s.
* **Shadow now also tops up missing moderndive datasets after `library(moderndive)`** succeeds via `base::library`. webR's binary moderndive (from `repo.r-wasm.org`) lags CRAN and silently lacks newer datasets that the book uses — `envoy_flights` (ch 2 viz examples), `early_january_2023_weather` (ch 2 line-graph), and `un_member_states_2024` (ch 5 / ch 6 UN regression chapters). After loading the package, the shadow checks each name and downloads the v2 `.csv.gz` mirror only when the local install doesn't already have it. Three new tiny CSV mirrors land on `v2`:
    - `data/envoy_flights.csv.gz` — 357 × 19, 7 KB
    - `data/early_january_2023_weather.csv.gz` — 360 × 15, 4 KB
    - `data/un_member_states_2024.csv.gz` — 193 × 39, 20 KB
* **ch4 setup**: `dem_score <- read_csv(URL, show_col_types = FALSE)` → `read.csv(URL)`. webR's readr hangs on every URL form, gz or plain. Base `read.csv()` works identically in regular R.

The 2.8.16–2.8.18 work shipped a working pipeline by browser test alone; Layer C would have caught the readr-gz hang, the readr-plain-URL hang, and the three moderndive-lag bugs in CI on first push instead of mid-class.

***

# ModernDive 2.8.18 — webR exercise robustness: pre-define chapter-derived objects

A thorough audit after 2.8.17 turned up nine objects that exercise `{webr-r}` cells reference but that were never available in the webR namespace — each a pre-existing footgun. A student opening any later exercise in isolation would hit an "object not found" error because the definition lived in an earlier inline `{webr-r}` cell (or, for `bball`, was only *described* in an exercise prompt and never defined anywhere).

Pre-defined in each affected chapter's `#| context: setup` cell:

* **Ch 4 (`04-tidy.qmd`)** — needed three additions. `bob_long` (the long-form pivot of `bob_ross`'s 67 indicator columns, referenced by EX 4.11). `dem_score` (read from the `data/dem_score.csv` mirror — *not* in any preloaded package despite the EX 4.27 prompt's "from `moderndive`" hint). Plus `library(olympicAthletes)` (via the shadow) since ch 4 had no GitHub-only package loads but multiple exercises (EX 4.35/39/40/41) reference `olympic_athletes`.
* **Ch 5 (`05-regression.qmd`)** — `bball` (`olympic_athletes |> filter(sport == "Basketball", !is.na(height), !is.na(weight))`), referenced across many later exercises. EX 5.1 still asks the student to construct it — their code just overwrites the pre-defined object. Plus `UN_data_ch5` (the four-variable UN member states subset shown in @sec-model1EDA), which downstream `{webr-r}` cells reference directly.
* **Ch 6 (`06-multiple-regression.qmd`)** — `planets_lite` (four non-missing exoplanet variables, EX 6.3) and `planets_temp` (three non-missing variables, EX 6.15), both built by student exercises but referenced from EX 6.4/5/16/21/37/39/44–46/53. Plus `UN_data_ch6` (the factor-typed-income subset).
* **Ch 10 (`10-inference-for-regression.qmd`)** — `bball` again. Roughly 11 ch 10 exercises (EX 10.20, 22, 37, 45–51, 54–55) reference it but `bball` was never defined anywhere in the chapter — a pre-existing curriculum bug independent of the webR migration.

The "build X yourself" exercises (EX 5.1, 6.3, 6.15) continue to work as written; the student's code just overwrites the pre-defined object. Net effect: every exercise webR cell is now runnable in isolation, regardless of which order a student opens them.

Audit infrastructure: `tmp/webr_audit.py` and `webr_qmd_cells.py` flag bare data-symbol references in `webr:` fields and inline `{webr-r}` cells that aren't loaded by the chapter setup or webR's preloaded packages. The audit reports clean across all 11 chapters and Appendix B (14 cells).

***

# ModernDive 2.8.17 — Shadow library() so library(<github-only-pkg>) "just works" in webR

* **Shadow `library()` for the four GitHub-only companion packages.** 2.8.16 fixed broken chapter setups by routing GitHub-only datasets through inline `readr::read_csv()` calls — which worked, but it made the setup code diverge from the local-RStudio idiom, and any exercise `webr:` starter that already wrote `library(olympicAthletes)` (six of them: ex 1.6, 2.1, 3.1, 6.1, 7.1, 10.49) still errored. New `scripts/webr-shadow-library.R` defines a shadow `library()` that — for `olympicAthletes` / `steves` / `exoplanetdata` / `volcanoes` only — reads each package's `.csv.gz` mirror into `globalenv()`. Every other package name delegates to `base::library()` unchanged, so `library(dplyr)` / `library(infer)` etc. behave normally. Idempotent (repeat calls skip datasets already present).
* **Each chapter `#| context: setup` cell now uses `source(...) + library(...)`**:
    ```r
    source("https://raw.githubusercontent.com/moderndive/ModernDive_book/v2/scripts/webr-shadow-library.R")
    library(dplyr)
    library(ggplot2)
    library(olympicAthletes)   # loads olympic_athletes + editions + medal_table via shadow
    ```
    Net −29 lines across the 10 chapters + Appendix B, and the code finally matches what students would type in local RStudio.
* **`olympic_editions.csv.gz` (62×15, 3 KB) and `olympic_medal_table.csv.gz` (1929×11, 16 KB)** added so `library(olympicAthletes)` in webR transparently provides all three datasets — fixing latent breaks in ch 1 ex 13/15 (which call `glimpse(medal_table)` / `tidy_summary(medal_table)`) and ch 3 ex 24 (`inner_join(editions, ...)`).
* **Appendix B's two `read_csv()`-based webR cells** migrated to the same `source(...) + library(steves)` pattern, eliminating the last inline mirror URL in the book.
* **Companion commit on `v2`** publishes `scripts/webr-shadow-library.R` plus the two new `.csv.gz` files so all of the above URLs resolve.

***

# ModernDive 2.8.16 — webR no longer broken by GitHub-only datasets

* **Restored interactive exercises across 10 chapters.** webR (browser-side R) can only install packages from `repo.r-wasm.org`, so each chapter's `#| context: setup` cell `library(olympicAthletes)` / `library(steves)` / `library(exoplanetdata)` / `library(volcanoes)` call failed silently and tore down the per-page webR namespace — every downstream end-of-chapter `{webr-r}` exercise cell in chapters 1-3, 5-11 was broken. Setup cells now read each needed dataset from a gzipped CSV mirror on `raw.githubusercontent.com/moderndive/ModernDive_book/v2/data/<file>.csv.gz` via `readr::read_csv()`. Datasets exported with `readr::write_csv()` (auto-gzips on `.gz` extension):
    - `data/olympic_athletes.csv.gz` — 315 090 rows × 16 cols, 5.8 MB (full `olympicAthletes::olympic_athletes`)
    - `data/steves_episodes.csv.gz` — 159 × 38, 50 KB (full `steves::episodes`)
    - `data/exoplanetdata_planets.csv.gz` — 6 278 × 28, 377 KB (full `exoplanetdata::planets`)
    - `data/volcanoes_eruptions.csv.gz` — 11 089 × 14, 163 KB (full `volcanoes::eruptions`)
    - `data/volcanoes_volcanoes.csv.gz` — 1 215 × 19, 442 KB (full `volcanoes::volcanoes`)
* **`readr` added to `webr.packages`** in `_quarto.yml` so it's preloaded into every chapter's webR session alongside ggplot2/dplyr/etc. — needed to decode the gzipped mirrors transparently.
* **Companion commit on `v2`** publishes the same five `.csv.gz` files to that branch so the raw URLs resolve. (The bookdown v1 build on `v2` is unaffected — these are new files only.)
* **Appendix B steves reads consolidated.** The two `read.csv("…/v2-quarto-html/data/steves_episodes.csv")` calls added during the 2.8.14 Appendix B work now point at the gzipped mirror on `v2` via `readr::read_csv()`, matching every other webR mirror read. The plain `data/steves_episodes.csv` (6-col subset) committed during that earlier work is removed — superseded by the full 38-col `.csv.gz`.

***

# ModernDive 2.8.15 — Per-chapter social-share previews + v2 hardcover share image

* **Per-chapter OG/Twitter descriptions.** Each of the 11 main chapters (`01-…` through `11-…`) now declares a topic-specific `description:` in YAML frontmatter so social-share previews (Open Graph + Twitter Card) surface a chapter-specific blurb instead of the book-level default. In a Quarto **book** project, `book.description` from `_quarto.yml` propagates to `og:description` and `twitter:description` on every chapter and overrides the page-level `description:`; the override only reaches `<meta name="description">`. Each chapter's frontmatter therefore declares the string once with a YAML anchor (`description: &desc "…"`) and references it (`*desc`) inside explicit `open-graph:` and `twitter-card:` blocks, so the same per-chapter blurb lands in all three meta tags.
* **Share image switched to the v2 hardcover.** `_quarto.yml` now points `open-graph.image` and `twitter-card.image` at `images/logos/v2_cover.jpg` (the second-edition hardcover, already used as the visible cover on the landing page) instead of the hex logo. Twitter `card-style` downgraded from `summary_large_image` to `summary` so the portrait cover renders inside a square thumbnail to the left of the title rather than being center-cropped to a landscape band — the standard pattern for book share cards.
* **Removed duplicate hand-rolled OG block in `_includes/analytics.html`.** Predated Quarto's native open-graph + twitter-card support and was emitting a second copy of `og:title` / `og:description` / `og:image` / `og:url` / `twitter:card` in the page head with stale info (title hardcoded to "ModernDive V2", `twitter:card` forced to `summary_large_image` regardless of the project setting, fixed `og:url=https://moderndive.com/v2/` on every page). Quarto's auto-emission with the per-chapter overrides above is now the single source of truth.

***

# ModernDive 2.8.14 — webR exercise integrity, Appendix B interactivity + regression examples, glossary popovers

* **Stubbed 117 answer-revealing webR exercise starters** across `exercises/02–11.yml`. Many `webr:` starter blocks shipped the *complete worked answer* to prompts that ask students to construct the code, defeating the exercise. Replaced with `# your code here` (normal groups) / `# your exploration here` (Extensions), preserving only genuine scaffold (a `set.seed()` for reproducibility, performance/constraint comments such as the loess `O(n^2)` note); solution-narrating comments were dropped. Run/interpret-the-output and given-snippet prompts were left intact.
* **Appendix B CORS fix.** `https://moderndive.com/data/*.csv` returns HTTP 200 but no `Access-Control-Allow-Origin` header, so webR (a browser Web Worker) was blocked from loading data in the *Try it interactively* cells. Repointed the two `ageAtMar` webR cells to the CORS-enabled `raw.githubusercontent.com/moderndive/ModernDive_book/v2/data/` mirror (byte-identical file). Plain `{r}` build chunks are unaffected (server-side, no CORS) and keep the canonical URL.
* **Interactive webR throughout Appendix B.** Added collapsible *Try it interactively* `{webr-r}` callouts (hypothesis test + confidence interval, `reps` reduced to 1000 for in-browser speed) to all four remaining case studies — One proportion, Two proportions, Two means (independent), Two means (paired) — matching the existing One-mean pattern. Appendix B now has 14 runnable webR cells.
* **New Appendix B section: *Correlation and simple linear regression*.** Uses `steves::episodes` (`imdb_rating ~ overall_episode`) — a dataset not used in any regression chapter. Permutation test for the correlation, bootstrap CI for the slope, theory-based `get_regression_table()` counterpart, and two webR cells. Because `steves` is GitHub-only (not installable in webR), the needed subset is exported to `data/steves_episodes.csv` and the webR cells read it from the raw mirror.
* **New Appendix B section: *Multiple regression with `infer::fit()`*.** Uses `saratoga_houses` (`price ~ living_area + bathrooms + bedrooms`, `moderndive` package — webR-preloaded). Observed `fit()` coefficients, response-permutation null, per-coefficient bootstrap CIs, and the theory-based table — with the distinction between the *joint* response-permutation null and the *partial* coefficient test made explicit. Two webR cells.
* **Glossary hover popovers.** Auto-linked glossary terms (first mention per chapter) now show the definition in a Bootstrap popover on hover/keyboard-focus while still linking to the full entry. `_extensions/glossary-autolink/glossary-autolink.lua` extracts and cleans each definition (drops `See @sec-…` cross-refs and code/italic markup) and attaches `data-bs-*` attributes; `_includes/glossary-popover.html` (wired via `include-after-body`) instantiates the popovers; `style.css` adds a dotted-underline affordance and popover sizing. Inline math in a definition (e.g. the null hypothesis \(H_0\)) is rewritten from `$…$` to MathJax's default `\(…\)` delimiters and re-typeset with `MathJax.typesetPromise()` on `shown.bs.popover`, so equations render in the bubble instead of showing raw TeX.

***

# ModernDive 2.8.11 — Instructor tooling pass: lesson plans, homework planner, slide decks

* **`scripts/build_lesson_plans.R`** → `instructor-solutions/lesson-plans.html`. Per-chapter teaching plan: learning objectives, section outline, Quick check / Learning check counts, exercise difficulty mix, and a class-time budget (150 wpm reading rate + 3 min/QC + 2 min/LC + 3 min/section overhead).
* **`scripts/build_homework_planner.R`** → `instructor-solutions/homework-planner.html`. Single self-contained page with all 486 exercises in a sortable table; client-side JS filters by chapter, difficulty, group, keyword, webr-only. Check boxes to assemble a set; click *Export* for a copy-pasteable list.
* **`scripts/build_slide_decks.R`** → `instructor-solutions/slides/NN-slides.qmd` × 11. Interactive revealjs decks themed in the ModernDive hex-sticker palette (navy `#1F3A6B`, blue `#1A6FBE`, green `#76BC43`). Each deck includes title + learning objectives + spaced-practice warm-up (Ch ≥ 2) + section dividers + per-section MCQ check-ins (parsed directly from each chapter's Quick checks: stem, options, correct letter, explanation) + wrap-up retrieval slide. Shared theme in `slides/moderndive-slides.scss` and tap-to-select / show-poll / show-answer interactions in `slides/moderndive-slides.js`. Learning-sciences design choices: frequent retrieval practice, predict-then-check prompts, single-idea slides, `prefers-reduced-motion` aware.
* **`scripts/audit_exercise_lexicon.R`** — dataset-cadence check tightened so dataset names only count as a forward-ref when they appear as **code symbols** (backticked, `library()`/`data()` call, or followed by `,`, `$`, `[`, `(`, `%>%`, `|>`). String literals inside webr labels (e.g., `labs(y = "medal events")`) no longer false-flag.
* **`scripts/build_facilitator_notes.R`** → `instructor-solutions/facilitator-notes/NN_notes.qmd` × 11. Per-chapter teaching scaffold: auto-generated learning objectives, section-by-section breakdown with minute estimates, and stuck-points parsed from each Quick check's lettered options — paired with blank fill-in slots for cold open, cold-call moments, transition phrases between sections, group-work break prompts, exit ticket, and an after-class self-check. Published alongside the slides + worked solutions through the companion repo's gh-pages encrypted pipeline.
* **`scripts/build_syllabus.R`** → `instructor-solutions/syllabus.qmd`. Sample syllabus: 15-week US-semester layout + compressed 10-week quarter alternative + assessment plan (4 problem sets + midterm + final project) + per-unit learning outcomes auto-extracted from each chapter's "In this chapter, you'll learn how to:" callout. Renders to `_site/syllabus.html` as part of the project.
* **`instructor-solutions/moderndive-instructor.scss`** — shared hex-sticker-palette SCSS for the worked solutions, syllabus, slides landing, and facilitator notes pages. Mirrors `slides/moderndive-slides.scss` so the whole instructor site reads as one visual product (navy headings with green underlines, blue links, cream `.callout-tip` blocks, ruled-paper fill-in code-block styling for the facilitator-notes blanks).
* **`scripts/build_slide_decks.R` + `scripts/build_facilitator_notes.R`** — learning-objective parser rewritten. The book uses `::: {.callout-note title="In this chapter, you'll learn how to:"}` (heading text lives in the callout's *attribute*, not in a `## In this chapter` line), and the old regex assumed the latter. Switched to grep-the-title-line + walk-to-closing-`:::` (same approach as `build_lesson_plans.R`), so LOs now appear correctly on every chapter's deck and notes page.
* **`instructor-solutions/_quarto.yml`** — render list now includes the slide decks, facilitator notes, AND syllabus. Companion repo `moderndive-instructor-resources` updated to render the full project (instead of just `index.qmd`) and to encrypt the whole `_site/` tree with `staticrypt -r`, so the new artifacts ship to gh-pages under the same `INSTRUCTOR_PASSWORD` gate.
* **`instructor-solutions/index.qmd`** — new callout block linking to all seven companion instructor artifacts so the worked-solutions page is the single navigation hub.
* **`.github/workflows/audits.yml`** — set `RENV_CONFIG_AUTOLOADER_ENABLED=FALSE` so audit jobs skip the `.Rprofile` autoload. Without this, renv intercepts `install.packages()` and tries to resolve every GitHub-hosted lockfile entry against the unauthenticated GitHub API, which intermittently rate-limits and fails the Exercise YAML lint job.

***

# ModernDive 2.8.4 — Accessibility pass: contrast, keyboard, ARIA

* **WCAG contrast audit** of custom callouts (`.learncheck`, `.announcement`, `.review`) in light *and* dark mode: all foreground/background pairs now verified at AAA. No CSS color changes needed.
* **Focus indicators**: prominent `:focus-visible` outline (blue in light mode, lighter blue in dark mode) — keyboard users can see which element has focus.
* **`prefers-reduced-motion` support**: users with reduced-motion OS preferences get all animations/transitions dialed down to 0.01ms.
* **Skip-to-main-content link** scaffold in CSS (`.skip-link` class), visible only on keyboard focus.
* **ARIA landmarks on custom callouts**: new `_extensions/aria-callouts/` Lua filter adds `role="region"` and a descriptive `aria-label` to `.learncheck`, `.announcement`, and `.review` divs so screen-reader users can navigate between them as landmarks. (Quarto's built-in callouts already have these.)

***

# ModernDive 2.8.3 — Glossary auto-link + social-share metadata

* **Glossary auto-link Lua filter** (`_extensions/glossary-autolink/`). On the *first* occurrence of each glossary term in each chapter, the prose now contains a hyperlink to the matching glossary entry. Multi-word terms ("sampling distribution", "Central Limit Theorem") and single-word terms ("scatterplot", "outlier") both supported. Excluded contexts: code, math, existing links, headings, the glossary chapter itself. Readers benefit from the glossary without needing to know it exists.
* **Per-page OpenGraph + Twitter-card metadata** via `book:` config (`site-url`, `open-graph`, `twitter-card`). Social-share previews now include the book hex logo + chapter title; per-chapter overrides still possible via YAML frontmatter.

***

# ModernDive 2.8.2 — Exercise YAML linter + coverage heatmap

* **`scripts/lint_exercise_yaml.R`** — validates every `exercises/NN.yml`: required fields (`ex_num`, `difficulty`, `prompt`), difficulty in 1..3, unique `ex_num` within chapter, code-needing prompts without `webr` (warning), orphan solutions (warning), `book_section` values matching real chapter section titles (warning). Wired into the *Audits* CI workflow so malformed YAML fails the PR before render.
* **`scripts/exercise_coverage_map.R`** — generates `instructor-solutions/coverage-map.html` with per-chapter tables of section/subsection coverage, exercise-ID lists collapsed to en-dash ranges, and difficulty histograms. Sections with ≤ 1 exercise are flagged in red. Output is gitignored; regenerate on demand.

***

# ModernDive 2.8.1 — Hover citations, MathJax a11y, CI audit gates

* **Hover citations** already enabled in `_quarto.yml` (`citations-hover: true`) — bibliography refs preview on hover.
* **MathJax screen-reader accessibility**: new `_includes/mathjax-assistive.html` loads the `a11y/assistive-mml` MathJax extension and enables `assistiveMml: true` so screen readers speak equations semantically rather than glyph-by-glyph.
* **Tighter `_freeze` cache key** in `quarto-publish.yml` — hashes the root-level book qmds + helper scripts + `exercises/*.yml` instead of `**/*qmd`, so instructor-solutions edits don't invalidate the main book's freeze cache.
* **New `.github/workflows/audits.yml`** with three PR-gate jobs:
    - Dead anchors (runs `cross_reference_scans.R`; fails on unresolved `@sec-*` / `@fig-*` / `@tbl-*`)
    - Figure alt-text (runs `alt_text_audit.R`; fails if any figure ships without alt text)
    - External link check (`lychee`; reports dead URLs as a downloadable artifact, doesn't block the PR)

Locks in the 2.7.0 cross-ref/alt-text wins so future PRs can't regress.

***

# ModernDive 2.8.0 — Repository restructure

Folder-and-file reorganization to give the repo a single home for every R / shell / Perl helper, decouple App C from legacy knitr caching, and consolidate the instructor-solutions sources next to their builder. No content changes — public reader-facing book is identical to 2.7.0.

## `scripts/` is now the single home for all helper code

Previously, helper code lived in three overlapping folders:

* `R/` — render-time helpers, plus a couple of one-shot dev tools mixed in.
* `scripts/` — diagnostic audit scripts (added in 2.7.0).
* `_tools/` — bookdown→Quarto migration Perl scripts.

These all merged into `scripts/`, with a single source-of-truth `scripts/README.md` documenting each file by *role* (render-time, manual build, diagnostic audit, migration tool, archive). The table at the top of the README classifies every file. Internal organization:

* **Top level** — render-time helpers (`exercise_helpers.R`, `image_functions.R`, `setup_exercise_packages.R`, `post-render-cleanup.sh`), manual build helper (`pdf_build_from_tex.R`), 4 diagnostic audits, 2 migration Perl scripts, V1→V2 `learning-checks/` subdir.
* **`scripts/archive/`** — orphaned bookdown-era helpers kept for git-history reference (currently just `purl.R`, which `index.qmd` no longer sources).

All `R/`-path references updated to `scripts/`: 18 chapter qmds, 11 exercise-solution qmds, `_quarto.yml`, internal references inside the migration scripts themselves.

Removed: duplicate `pdf_build_from_tex.R` (root copy stale; `R/` version kept the same content but with current Quarto-era paths).

## App C no longer uses legacy `cache=TRUE`

`93-appendixC.qmd` was the only chapter still using R Markdown's `cache=TRUE` chunk option, producing `93-appendixC_cache/` (8.5 MB of tracked binary cache that churned on every chunk-option change) and `93-appendixC_files/`. Both directories deleted from tracking; the chunk option removed; the chapter now uses Quarto's `_freeze` like every other chapter. Net savings: ~9 MB and zero cache-file churn in future commits.

## Static HTML pages moved out of repo root

The three static HTML files referenced as resources in `_quarto.yml` (`regression-plane.html`, `regression-plane-ISLR2.html` — both ~4.5 MB interactive 3D plots — and `labs.html` — a 206-byte redirect) moved to `extras/`. The `_quarto.yml` `resources:` list now points to `extras/<file>`. Two follow-on updates:

* The Ch 6 prose link to `https://moderndive.com/v2/regression-plane-ISLR2.html` updated to `.../v2/extras/regression-plane-ISLR2.html`.
* `_redirects` (Netlify) gained three permanent redirects to preserve any existing inbound links to the pre-move URLs.

## Instructor solutions consolidated

`exercise-solutions/*.qmd` (11 per-chapter solution stubs) moved into `instructor-solutions/chapters/`. The `instructor-solutions/index.qmd` include paths updated from `../exercise-solutions/NN_ex.qmd` to `chapters/NN_ex.qmd`. The `exercise-solutions/` directory is gone.

In the process, 20 MB of stale build artifacts (10 `*_ex.html` standalone renders plus 225 entries under `*_ex_files/` for bootstrap CSS/JS/woff fonts) removed from tracking. The canonical instructor-solutions render is `instructor-solutions/_site/index.html`; the per-chapter HTMLs were leftover from when each chapter rendered standalone before the wrapper project existed.

`.gitignore` now defensively ignores `exercise-solutions/` so a stray hand-render can't re-track those artifacts.

**Heads-up for the companion `moderndive-instructor-resources` repo**: its `build.yml` Cache step hashes `book/R/exercise_helpers.R` for the cache key — that path no longer exists. The single-line patch is:

```diff
-          key: instructor-solutions-freeze-${{ hashFiles('book/exercises/**/*.yml', 'exercises/**/*.yml', 'book/R/exercise_helpers.R') }}
+          key: instructor-solutions-freeze-${{ hashFiles('book/exercises/**/*.yml', 'exercises/**/*.yml', 'book/scripts/exercise_helpers.R') }}
```

(Not a build failure — the existing key just produces a cache miss every run, forcing a fresh render. Updating restores cache hits.)

***

# ModernDive 2.7.0 — Diagnostic scripts and audit-driven content refinements

A diagnostic-tooling release that puts the book's pedagogy and accessibility under explicit, repeatable scrutiny. Three read-only audit scripts now live in `scripts/`; their findings drove targeted refinements to the exercise system, Quick check coverage, distractor wording, and figure alt-text. The bookdown source remains canonical on the `v2` branch; the Quarto build is published to `v2-publish` from `v2-quarto-html`.

## Diagnostic scripts (new `scripts/` folder)

Three self-contained R scripts that audit the book and print structured punch-lists, plus a `README.md` documenting use, output format, and known false-positive patterns. Each script is read-only — outputs are reviewed and applied separately.

* `scripts/pedagogy_scans.R` — three scans in one pass: forward `@sec-*` cross-references (with Conclusion/foreshadowing prose filtered out), first-use lexicon for glossary terms, and a function-introduction map (prose-intro vs code-intro per function).
* `scripts/learning_objective_scans.R` — LC distribution per chapter/section, fuzzy QC-to-subsection alignment, and per-group exercise difficulty progression (flags groups with `★★★` exercises but no `★★` rung).
* `scripts/alt_text_audit.R` — figure alt-text accessibility audit covering R chunks (`fig.alt=`), markdown `![alt](path)` images, and `include_graphics()` calls. Filters non-rendering chunks (`eval=FALSE`, `fig.show='hide'`, `{webr-r}`, HTML-comment-wrapped markdown images) to suppress false positives.

## End-of-chapter exercise system — coverage and difficulty

* **~12 new end-of-chapter exercises** added to fill depth/length-proportional gaps surfaced by the section-coverage audit, all as Extensions tagged to the section they target so the coverage tables update correctly:
    + Ch 6 § 6.2 *Two numerical predictors* (EX 6.55–56): partial vs marginal slopes, residuals-vs-fitted diagnostic on the two-numerical model.
    + Ch 7 § 7.2 *Sampling framework* (EX 7.45): six-term vocabulary paragraph.
    + Ch 7 § 7.5.1 *Two-sample sampling distributions* (EX 7.46–47): SE-of-a-difference numeric check, center of the two-sample sampling distribution.
    + Ch 8 § 8.3 *Additional remarks about the bootstrap* (EX 8.44): how many bootstrap replicates is "enough."
    + Ch 9 § 9.3 *Understanding hypothesis tests* (EX 9.45–46): six-term vocabulary paragraph, "three things a $p$-value is *not*."
    + Ch 10 § 10.6 *Simulation-based inference for multiple linear regression* (EX 10.56–58): `infer::fit()` bootstrap CI for each partial slope, permutation $p$-value for each partial slope, when simulation-based beats theory-based.
    + Ch 11 § 11.1 *Seattle case study* (EX 11.20–21): scaffolded warm-ups on log-transforming `price` and predicting a single house price by hand from the fitted equation.
* **Ch 10 difficulty rebalanced** — 12 exercises rerated from ★★★ to ★★ (EX 10.8, 10.10, 10.11, 10.13, 10.15, 10.17, 10.19, 10.21, 10.22, 10.24, 10.37, 10.38) so every substantive non-Extension group now has a ★★ rung; the chapter's `Critical thinking and synthesis` group stays all ★★★ by design.
* **Section-coverage notes refreshed** in `exercises/07.yml` and `exercises/11.yml` to reference the new exercises and reflect the chapter's actual coverage shape.
* **Solutions** for the new exercises added to the (instructor-only) `exercises/06-solutions.yml`, `08-solutions.yml`, `10-solutions.yml` files. `instructor-solutions/_site/index.html` re-rendered cleanly with no cross-reference warnings.

## Quick checks — section coverage gaps

Surfaced by the QC-alignment audit:

* **Ch 8** picks up **Q11**: the *Mythbusters* yawning case study (§ 8.4) — previously uncovered by any QC. Intro line updated from "Ten questions" → "Eleven questions."
* **Ch 9** picks up **Q11–Q12**: the music-popularity activity (§ 9.2) and the IMDb case study (§ 9.6) — both anchored on the chapter's worked examples. Intro line updated from "Ten" → "Twelve."
* **Ch 10** picks up **Q11–Q12**: partial-slope interpretation in the coffee model (§ 10.5) and the `infer::fit()` bootstrap CI for partial slopes (§ 10.6) — the previously-thin multiple-regression material now has direct QC checks. Intro line updated from "Ten" → "Twelve."

## Quick check / LC distractor cleanup (first-use lexicon scan)

Quick check stems and distractors must use only concepts the chapter has already introduced (per the long-standing in-repo rule). The lexicon scan caught five spots that violated this:

* **Ch 2 Q9** (faceting): distractor (d) "*Creates a confidence interval per origin*" → rewritten to "*Sorts the data by `origin` level*" — `confidence interval` is a Ch 8 concept.
* **Ch 5 LC** (intercept term $b_0$): option C "*The standard error of the regression*" → rewritten to "*The slope of the regression line*" — `standard error` is a Ch 7 concept.
* **Ch 7 Q1** (sampling distribution): distractor (d) "*The probability that the null hypothesis is true*" → rewritten to "*How the population parameter varies across many possible populations*" — `null hypothesis` is a Ch 9 concept.
* **Ch 1 Q3** (package re-loading): stem and option (d) referenced `filter()` from `dplyr` (a Ch 3 verb) → rewritten to use `glimpse()` (introduced in Ch 1).
* **Ch 1 Q8** (`View()` is read-only): answer key referenced "dplyr verbs (`mutate()`, `filter()`, etc.)" → rewritten to point forward via `@sec-wrangling` without naming the verbs.

## Figure alt-text — accessibility completion

The alt-text audit found 72 figures still lacking `fig.alt=` or with empty markdown image alt brackets after the initial migration pass. All resolved in this release:

* **65 new `fig.alt=` descriptions** added across foreword, preface, Ch 1, 2, 5, 11, App A, App B, and App C. Each describes the visual content of the figure (axes, shape, key features) rather than duplicating the human-readable caption — alt text and `fig.cap=` now consistently have different jobs across the book.
* **3 markdown image alts** filled in for the `data_ninja1.png`, `forcats` package hex logo, and `Rninja.png` images in App C.
* **Internal builder chunks** (Ch 2 `visualization-create-boxplot-components`, Ch 10/11 `*-viz-*-alt` chunks) that `ggsave()` to disk without printing now carry `fig.show='hide'` so the alt-text audit doesn't flag them, and so accessibility tooling correctly understands no figure is rendered there.

## Bug fixes

* Stale doc reference: Ch 7's "you'll learn how to" callout pointed to `rep_sample_n()`, but the chapter actually teaches the newer `rep_slice_sample()`. Updated to match.

***

# ModernDive 2.6.0 — Exercise system refinements + pedagogical audits

Refactor and tighten the end-of-chapter exercise rollout, then sweep through it for forward-reference and difficulty-progression issues.

## Single-source-of-truth for end-of-chapter exercises

* Per-chapter exercise content (prompts, webr code, difficulty, group, section/subsection assignments) now lives exclusively in `exercises/NN.yml`. Each chapter's `## Exercises` section in its `.qmd` calls `render_chapter_exercises(N)`; the matching `exercise-solutions/NN_ex.qmd` calls `render_solutions(N)`. No more drift between prompts in the chapter qmd and prompts in the solutions qmd — they read from the same YAML.
* Coverage callout per chapter (a "Section coverage at a glance" table mapping book sections to exercise numbers) is now auto-generated by `render_coverage_callout(N)`. Consecutive exercise IDs collapse to en-dash ranges (e.g., `EX5.3–EX5.7`) for readability.
* Instructor-solutions HTML TOC fixed — `toc-depth: 3` lets exercise group headers appear in the sidebar, and the per-chapter shortcode now lifts each chapter heading to the right level so the TOC isn't flat.

## Pedagogical audits — Quick checks and exercise placement

* Distractor scrubbing across Quick checks (Ch 4 first pass, then Ch 6, 8, 9, 10, 11) — rewrote multiple distractors that introduced forward-reference terminology and tightened wording on several stems.
* Forward-ref exercise moves: a handful of exercises that secretly required Ch 8+ material were promoted into each chapter's *Extensions* group (where the "deliberately introduces concepts beyond" framing is appropriate) rather than sitting in the main exercise list.
* R²/forward-ref cleanup in Chs 5 and 6: exercises mentioning R² migrated to *Extensions* (R² is properly introduced as a model-fit summary in Ch 10).
* EX 6.11 added to fill a parallel-slopes interpretation gap; small wording fixes across Ch 1, 3, 5, 6.

***

# ModernDive 2.5.0 — Accessibility & migration polish

The accessibility complement to the Quarto port, plus the wave of migration-era bug fixes that surfaced as the build settled.

## Accessibility — initial alt-text pass

* All 150 figure chunks that existed at the time of the Quarto migration received dedicated `fig.alt` attributes describing each figure's visual content for screen-reader users — distinct from (and richer than) the human-readable `fig.cap=`. (The remaining ~70 figures get their alt text in 2.7.0's accessibility completion pass.)

## Migration bug fixes

* Added names to all chunks with the help of GitHub Copilot.
* Updated Posit cheatsheet links and screenshots to latest versions from <https://rstudio.github.io/cheatsheets/>.
* Added Learning Check solutions to the Appendix online (now also collapsibly inline in some chapters).
* Updated LC10.7.
* Deleted the `echo=FALSE` that was hiding the Chapter 11 Needed Packages.
* Fixed a typo flagged by @Bmmju regarding 142 countries in Subsection 5.2.1 that was hard-coded — corrected to 188.
* Fixed another hard-coded typo flagged by @segre-ecophysiology-lab on the number of airlines in the Chapter 3 Learning Checks (fixed to 14 instead of 16).
* Fixed the typo of "95%" instead of "90%" in the interpretation of Subsection 9.4.2 flagged by @omian.
* Added `GGally` to the "Versions of R packages used" in the Preface (missing prior to publication of the Second Edition).
* Replaced bookdown references in the Preface's "About this book" section with Quarto.
* Fixed code formatting in Tables 2.4 and 3.x (the chapter-end summary tables): markdown backticks in CSV-loaded cells were rendering as literal characters instead of inline code; cells now pre-process backticks into `<code>` tags so verbs like `geom_point()` and `filter()` render correctly (and the new `code-link` setting hyperlinks them to package docs).
* Fixed cheatsheet pipe rows (`|>`) in Chapters 3, 10, 11 that were rendering as literal `\|>` due to markdown table-cell escaping inside backticks.
* Normalized fenced-div opens to `::: {.learncheck}` (with a space) across all chapters and appendices. The no-space form `:::{.learncheck}` is valid Pandoc but trips Quarto's lua filter, which would render the opening fence as literal text and emit a "problem with a fenced div" warning.
* Inserted a missing blank line between a math display (`$$ … $$`) and the immediately following `::: {.learncheck}` fence in Chapter 7; without the separator, Pandoc treated the fence as part of the preceding block and the closing `:::` would render as literal text under the Quick checks section.

***

# ModernDive 2.4.0 — End-of-chapter exercise system

* **Roughly 320 new end-of-chapter exercises** placed between *Quick checks* and *Conclusion* in every numbered chapter — ~30–35 per chapter for the substantive chapters (2–10), and smaller capstone sets for chapters 1 and 11. Each exercise carries a difficulty marker (★ warm-up, ★★ standard, ★★★ critical thinking).
* **Five new exercise datasets**, scaffolded gradually so packages and concepts accumulate naturally:
    + `olympic_athletes` / `medal_table` / `editions` from the [`olympicAthletes`](https://github.com/moderndive/olympicAthletes) package — introduced in chapter 1, used throughout chapters 2, 3, 5, 8, 9, 10, 11.
    + `episodes` from the [`steves`](https://github.com/ismayc/steves) package — Rick Steves' Europe (2000–2025); introduced in chapter 3.
    + `bob_ross` from `fivethirtyeight` (already CRAN) — used as the chapter 4 *Tidy Data* pilot dataset and revisited in chapters 8 and 9.
    + `planets` and `stars` from the [`exoplanetdata`](https://github.com/moderndive/exoplanetdata) package — introduced in chapter 6 and reused in 7, 10, 11.
    + `volcanoes` / `eruptions` / `events` from the [`volcanoes`](https://github.com/moderndive/volcanoes) package — introduced in chapter 7 and reused in 8, 9, 11.
* **Inline WebR sandboxes** beneath each code-needing exercise — same `{webr-r}` mechanism as the chapter examples — with reasoning-only prompts left as plain text so the *Run Code* button only appears where it makes sense.
* **Solutions are instructor-only** and *not* deployed alongside the public book. Per-chapter solution content lives in `exercise-solutions/NN_ex.qmd` (mirroring the `lc-answers/` pattern) and is assembled into a self-contained HTML by a separate Quarto project at `instructor-solutions/`. Each chapter's solutions section opens with a **section coverage** table mapping book sections to exercise numbers, and each entry shows a foldable *show question* callout above an always-visible **Solution** with a plain-text section reference.
* **CRAN/GitHub install toggle** in `R/setup_exercise_packages.R` — a single `from_github` flag per package. When any of the four GitHub-only packages reaches CRAN, flip its flag to `FALSE` and the next build pulls from CRAN instead. `DESCRIPTION` has matching `Imports:` and `Remotes:` entries so CI can install them either way.
* Chapter 1 picks up a small *"Looking ahead to end-of-chapter exercises"* subsection that walks new readers through installing the first GitHub-only package (`olympicAthletes`) with `remotes::install_github()` and previews the four other datasets they'll meet.

***

# ModernDive 2.3.0 — Quick checks + WebR pilot

* **Quick check quizzes** — **ten** multiple-choice questions per chapter with collapsible answers, placed right before each Conclusion. Wrong-answer distractors deliberately reflect common student misconceptions (e.g., `aes(constant)` in Ch 2; `==` vs `=` in Ch 3; "95% probability the parameter is in this CI" in Ch 8; the multiple-testing problem in Ch 9), and each answer block briefly explains why each tempting wrong option is wrong.
* **WebR-runnable code cells** — pilot in Chapters 2, 3, 4, and Appendix B. Click *Run Code* to execute R in your browser without installing anything; edit and re-run to experiment. Cells live inside collapsible "Try it interactively" callouts so the WebR runtime only loads when a reader actively expands one.

***

# ModernDive 2.2.0 — Reader UX layer

Substantive pedagogical scaffolding plus visual/navigation polish that the Quarto port made cheap to add.

## Pedagogical scaffolding

* **Learning objectives** at the top of each of the 11 main chapters — Bloom-style "by the end of this chapter, you'll be able to…" lists.
* **"Common mistake" callouts** at predictable trouble spots: `aes()` vs setting (Ch 2), the `na.rm = TRUE` reflex (Ch 3), correlation ≠ causation (Ch 5), the three distributions students confuse (Ch 7), the "95% probability the parameter is in this interval" misinterpretation (Ch 8), and the p-value as P(H₀ true) trap (Ch 9).
* **Per-chapter cheatsheets** — compact reference tables of the verbs/functions introduced in each chapter, in a dedicated callout.
* **Glossary appendix** — alphabetized definitions of ~25 stats / data-science terms (sampling distribution, p-value, LINE conditions, …), each linking back to the chapter that develops the concept.
* **New "Random sampling vs. random assignment" subsection** at the end of Chapter 7, with a 2×2 summary table mapping the four study-design quadrants (random sample / random assignment, with/without each) to what kind of conclusion each design supports — and explicitly placing this book's example datasets within that grid.

## Visual + navigation

* **Dark mode + lightbox** — sun/moon toggle in the navbar; click any figure to enlarge in a modal. Custom `.learncheck` / `.announcement` / `.review` styles have dark-aware variants.
* **Hyperlinked code** — function names in code blocks now link to their package documentation (Quarto's `code-link: true`).

***

# ModernDive 2.1.0 — Quarto port (HTML migration)

The mechanical bookdown→Quarto conversion plus the deploy/CI infrastructure that supports it. No new chapter content in this release — all pedagogy additions arrive in subsequent releases. PDF/Krantz support is intentionally deferred; this release is HTML-only.

## Migration: bookdown → Quarto

* All chapter source files renamed `.Rmd → .qmd`. `_bookdown.yml` and `_output.yml` replaced with a single `_quarto.yml`.
* All bookdown cross-reference syntax (`\@ref(fig:x)`, `\@ref(tab:x)`, section refs) converted to Quarto's `@fig-x` / `@tbl-x` / `@sec-x`. Chunk labels renamed accordingly.
* `{block, type="learncheck"}` paired blocks merged into single `:::{.learncheck}` fenced divs (one cohesive callout per Learning Check).
* CI workflow now uses `quarto-actions` and caches `.quarto/_freeze` for fast incremental builds.
* Cross-chapter R state (`version`, `dev_version`, `needed_CRAN_pkgs`, helper functions) moved to `R/image_functions.R`, sourced by every chapter's auto-prepended `setup-init` chunk (Quarto runs each chapter in its own R session).

## Deploy

* The bookdown source remains canonical on the `v2` branch; the Quarto build is published to the `v2-publish` branch and currently lives on the `v2-quarto-html` branch. Existing reader URLs are preserved.
* `_quarto.yml` `repo-actions: [edit, source, issue]` enables per-page edit/source/issue links in the navbar.
* `R/post-render-cleanup.sh` post-render hook keeps the working tree tidy of macOS Cocoa render artifacts.
* `_tools/convert_bookdown.pl` and `_tools/fix-chapter-refs.pl` preserved as the migration tooling for future reference.
* `quarto-publish.yml` now pre-installs the four GitHub-only exercise packages with `remotes::install_github()` *before* `setup-renv@v2` runs, so `renv::restore()` finds them already present and skips them — working around resolution failures on those entries in the lockfile.

***

# ModernDive 2.0.0

* Created https://moderndive.com/v2/ website to host the Second Edition (and later v2 and beyond) content
* Removed previous data sets `promotions` (Chapter 9) and `evals` (Chapters 5, 6, and 10) and replaced with `un_member_states_2024` and `spotify_by_genre` instead
* Replaced `pennies` with `almonds_bowl` in Chapter 7
* Moved some sections around in Chapters 7 and 10 to improve readability
* Moved model selection to Chapter 10 instead of Chapter 6
* Added `coffee_quality` and `old_faithful_2024` examples to Chapter 10
* Improved theory-based discussions in Chapters 8, 10, and 11
* Added use of `fit()` function for simulation-based inference with multiple linear regression
* Added `infer` package with `fit()` to Chapter 11 to discuss inference for regression
* Added content in the Appendices

* Used base-pipe `|>` instead of `%>%` in all code chunks since those are in other updates. Some inline functions like `"*"()` were kept using `%>%` since they are more readable than converting to the base-pipe functionality.
* Addressed the warning message explicitly for `group_by()` in text and fix `index.Rmd` to remove `options(dplyr.summarise.inform = FALSE)`
* Added `relocate()` to end of Chapter 3
* Added `envoy_flights` and `early_january_2023_weather` to `{moderndive}` package
* Explained that `{nycflights23}` is an updated version of `{nycflights13}` using the `{anyflights}` package
* Updated code and discussion throughout the book to use `{nycflights23}` instead of `{nycflights13}`

* Chapter 2 Data Visualization: Remove soft introduction to `%>%` operator (from Ch 3 Data Wrangling) since this only confused readers. Instead we now use a prepared `alaska_flights` and `early_january_weather` data frames from `moderndive` version 0.5.3
* Chapter 6 Multiple Regression: Per @kmkinnaird's suggestion, we split "6.3.1 Model selection" into:
    + "6.3.1 Model selection using visualizations"
    + Added "6.3.2 Model selection using R-squared"
* Chapter 7 Sampling: Per @kmkinnaird's suggestion, refactored as follows
    + "7.3.1 Terminology & notation": clustered definitions according to theme and connected back to sampling exercises
    + "7.3.2 Statistical definitions": 
    + Moved "7.5.2 Central Limit Theorem" to its own section to make it more prominent and not an after-thought
    + Created a new "7.6.2 Theory-based standard errors" which split "8.7.2 Theory-based confidence intervals" into two parts and moved the earlier part to Chapter 7 Sampling. That way all 4 statistical inference chapters (Ch 7-11) each of their own "theory-based X" subsection at the end bridging the gap between simulation based and traditional methods. 

***



# ModernDive 1.1.0

* Typo fixes and clarifying wording tweaks
* With a big assist from @mariumtapal, we cleaned and refactored all R Markdown code to make it easier for future bookdown users to understand. However all code seen by readers of the print edition has been left intact.
* Appendix C (online only):
    + Renamed from "Reach for the Stars" to "Tips and Tricks". 
    + Added C.1 section on most common data wrangling questions we've encountered, mostly written by @smetzer180


***


# ModernDive 1.0.0

* Version 1.0.0 corresponds to our [CRC Press print edition](https://www.crcpress.com/Statistical-Inference-via-Data-Science-A-ModernDive-into-R-and-the-Tidyverse/Ismay-Kim/p/book/9780367409821).
* Changed word in title of book from "moderndive" to "ModernDive" for consistency with hex sticker.
* Added Foreword by Kelly S. McConville. Thanks, @mcconvil!
* Fixed various typos throughout the book and tried to make language consistent. For example, using "data sets" instead of "datasets" or "data-sets".
* Switched from `gather()` and `spread()` with `tidyr` to `pivot_long()` and `pivot_wide()` following [this tidyverse article](https://tidyr.tidyverse.org/dev/articles/pivot.html)
* Added `geom_parallel_slopes()` user-defined geom extension to `ggplot2`


***


# ModernDive 0.6.1

* Changed chapter numbers. Chapter "1. Introduction" is now "Preface", thus all Chapter numbers decreased by one.
* Moved discussions on normal distribution (Ch on sampling) and log-transformations (Ch on tell your data story) to Appendix A "Statistical Background"
* Updated images used in book
* Did a full scan of the book for typos
* Created greyscale versions of many images for the CRC Press printed version


***


# ModernDive 0.6.0

We're only a few cosmetic edits away from v1.0.0, which will correspond to our print edition with CRC Press!


## Done first pass of infer chapters

Completed major re-organization and clean-up of Chapters 9-11 using the `infer` package for "tidy and transparent" statistcal inference.

* Chapter 9: Bootstrapping & confidence intervals
    + Tactile exercise of sampling 50 pennies from bank and resampling from this sample.
    + Added sections on
        1. "Interpreting confidence intervals", in particular determinants of CI width.
        1. "Theory-based confidence intervals" using formula for SE of p-hat, thereby bridging gap between simulation and theory-based methods.
* Chapter 10: Hypothesis testing
    + Added `promotions` example on gender discrimination in promotions at a bank. Data source: `openintro::gender.discrimination`
    + Added section on "Theory-based hypothesis tests" using t-test, thereby bridging gap between simulation and theory-based methods.
* Chapter 11: Inference for regression.
    + Discussion on LINE conditions for inference. In particular using `moderndive::get_regression_points()` wrapper function to `broom::augment()` so that novices can do their own residual analyses.

## Other changes

* Chapter 7: Multiple regression
    + Added Section 7.3.1 on model selection: choosing between "interaction" and "parallel slopes" models
* Chapter 8: Sampling
    + Added Section 8.5.3 with more in-depth discussion of normal distribution
* Chapter 12: Renamed to "Tell your story with data"



***


# ModernDive 0.5.0

## Highlights

* "Data wrangling" chapter now comes after "Tidy data" chapter.
* Improved explanations and examples of `geom_histogram()`, `geom_boxplot()`, and "tidy" data
* Moving residual analysis from regression Chapters 6 & 7 to Chap 11: Inference for regression
* Reorganized Chap 8 on Sampling
* All learning check solutions now in Appendix D
* PDF build re-added (still a work-in-progress)

## All content changes

* Changed title
    + From: "Statistical Inference via Data Science in R"
    + To: "Statistical Inference via Data Science: A moderndive into R and the tidyverse"
* Chapter 2 - Getting Started
    + Added subsection 2.2.3 "Errors, warnings, and messages" by @andrewheiss
* Chapter 3 - Data visualization:
    + Added simpler introductory `geom_histogram()` and `geom_boxplot()` examples
    + Started downweighting the amount of data wrangling previews included in this chapter, in particular `join`.
    + Cleaned up conclusion section
    + Added cheatsheet
* Switched order of "Chap 4 Tidy Data" and "Chap 5 Data Wrangling": Data Wrangling now comes first
* Chapter 4 - Data wrangling:
    + Added cheatsheet
* Chapter 5 - Renamed to "Importing and tidy data"
    + Reordered sections: importing then tidying
    + Added `fivethirtyeight::drinks` example of "hitting the non-tidy wall", then using `tidyr::gather()`
    + Made Guatemala democracy score a case study.
    + Added discussion on what `tidyverse` package is.
    + Moved discussion on normal forms to Ch4: Data Wrangling - joins.
    + Moved discussion on identification vs measurement variables to Ch2: Getting started with data.
* Chapter 6 - Basic regression:
    + Moved residual analysis to Chapter 11
* Chapter 7 - Multiple regression:
    + Moved residual analysis to Chapter 11
* Chapter 8 - Sampling: Major refactoring of presentation/exposition; see below
* Chapter 11 - Inference for regression:
    + Moved residual analysis from Chapter 6 & 7 here
* Moved all Learning Check solutions to Appendix D


### Chapter 8 Sampling Refactoring

**Old chapter structure**:

1. Introduction to sampling
    a) Concepts related to sampling
    b) Inference via sampling
2. Tactile sampling simulation
    a) Using the shovel once
    b) Using the shovel 33 times
3. Virtual sampling simulation
    a) Using the shovel once
    b) Using shovel 33 times
    c) Using shovel 1000 times
    d) Using different shovels
4. In real-life sampling: Polls
5. Conclusion
    a) Central Limit Theorem
    b) What’s to come?
    c) Script of R code

**New chapter structure**:

1. Activity: Sampling from a bowl
    a) Question: What proportion of this bowl is red?
    b) Using shovel once
    c) Using shovel 33 times
1. Computer simulation:
    a) What is a simulation? We just did a "tactile" one by hand, now let's do one using the the computer
    b) Using shovel once
    c) Using shovel 33 times
    d) Using shovel 1000 times
    e) Using different shovels
1. Goal: Study fluctuations due to sampling variation
    a) You probably already knew: Bigger sample size means "better" guess.
    b) Comparing shovels: Role of sample size
1. Framework: Sampling
    a) Terminology for sampling (population, sample, point estimate, etc)
    b) Statistical concepts: sampling distribution and standard error
    c) Computer's random number generator
1. Interpretation: 
    a) Visual display of differences
1. Case study: Obama poll 
1. Big picture: 
    a) Table of inferential scenarios: Add bowl and obama poll (both p)
    b) Why does this work? Theoretial result: CLT
    c) There's a formula for that: SE formula that has sqrt(n) at the bottom
    d) Appendix: Normal distribution discuss



***



# ModernDive 0.4.0

## Highlights

1. The [`infer` package](http://infer.netlify.com/) is ready for prime-time! Thus we made a first pass at incorporating it into the book in Chapters 9 and 10 on confidence intervals and hypothesis testing!
1. Chapter 12 on "Thinking with Data" now includes a case study using the [Seattle house prices](https://www.kaggle.com/harlfoxem/housesalesprediction) dataset on Kaggle.com. Chapters 3 and 4 from new ["Modeling with Data in the Tidyverse"](https://www.datacamp.com/courses/modeling-with-data-in-the-tidyverse) DataCamp course by Albert Y. Kim are based on this analysis!
1. Speaking of DataCamp, we point readers to [various DataCamp courses](https://moderndive.netlify.com/index.html#datacamp) that directly align with various chapters in the book!
1. We significantly cleaned up Chapter 8 on sampling! In particular: adding a [2013 Obama approval rating poll](https://www.npr.org/sections/itsallpolitics/2013/12/04/248793753/poll-support-for-obama-among-young-americans-eroding) example to tie in with our sampling bowl tactile and virtual simulations and making it very clear that ultimately we are performing statistical **inference via sampling**.

## All content changes

* Introduction: Added section on correspondence of chapters to various DataCamp courses. Furthermore, links to relevant DataCamp course are included at the outset of each chapter.
* Chapter 3 - Data visualization:
    + Added simplified `geom_jitter()` example
    + More explanations for how whiskers and outliers are constructed in `geom_boxplots`
    + Added summary of table of all 5 named graphs
* Chapter 4 - Tidy data:
    + Added section on importing Excel data via RStudio
    + Added example of tidy vs non-tidy: `fivethirtyeight::drinks`
* Chapter 5 - Data wrangling:
    + Added computing [available seat miles](https://en.wikipedia.org/wiki/Available_seat_miles) data wrangling case study
    + Abandoned "5 Main Verbs" 5MV notion
    + Added `_join()` and `group_by()` multiple variables
* Chapter 6 - Basic regression:
    + Clarified explanations of indicator/dummy variables when using categorical variable in regression. 
    + Expanded "Correlation is not necessarily causation" subsection with example of "does sleeping with shoes on cause headaches?" including [causal diagram](https://github.com/moderndive/moderndive_book/blob/master/images/flowcharts/flowchart.009-cropped.png)
    + Introduced concept of a "wrapper function" when introducing `moderndive::get_regression_table()` function
    + Replaced all `base::summary()` with `skimr::skim()` for quick numerical summaries
* Chapter 7 - Multiple regression:
    + Changed all "everything else being equal" interpretation statements with "taking into account/controlling for all other variables in our model"
* Chapter 8 - Sampling:
    + Significantly cleaned up sampling terminology and definitions and made more clear that we are **sampling for inference**
    + Cleaned up section and subsection structure to be much cleaner:
        1. Tactile sampling simulation
        1. Virtual sampling simulation
        1. In real-life sampling: Introduced example of 2013 Obama approval rating poll and then tie everything with [sampling bowl](https://github.com/moderndive/moderndive_book/blob/master/images/sampling_bowl.jpeg).
* **Major overhaul**: Chapter 9 - Confidence intervals
    + [`infer` package](http://infer.netlify.com/) now being ready for prime-time, we made first pass at incorporation into book.
* **Major overhaul**: Chapter 10 - Hypothesis testing
    + [`infer` package](http://infer.netlify.com/) now being ready for prime-time, we made first pass at incorporation into book.
    + Added discussion on Allan Downey's ["There is only one test"](http://allendowney.blogspot.com/2016/06/there-is-still-only-one-test.html) ideas
* Chapter 11 - Inference for Regression
    + Added a simple linear regression example using the `infer` package    
* **Major overhaul**: Chapter 12 - Thinking with data
    + Added case study of [Seattle house prices](https://www.kaggle.com/harlfoxem/housesalesprediction) dataset from Kaggle, which is now available in `house_prices` dataframe in `moderndive` package. 
        1. Chapters 3 and 4 from new ["Modeling with Data in the Tidyverse"](https://www.datacamp.com/courses/modeling-with-data-in-the-tidyverse) DataCamp course are based on this analysis
        1. Includes a discussion on the importance of `log10`-transformations
        1. Introduces modeling/regression for prediction: predicting house prices
    + Laid outline for "effective data storytelling" using `fivethirtyeight` data and added one small example using US births data
    + At the beginning of chapter, we now come full circle and revisit the discussion on the ModernDive [flowchart](https://github.com/moderndive/moderndive_book/blob/master/images/flowcharts/flowchart/flowchart.002.png) in the introduction.

## Other changes

* Updated `moderndive` package on CRAN to 0.2.0. See [`NEWS.md`](https://github.com/moderndive/moderndive/releases)



***


# ModernDive 0.3.0

## Content changes

* Reorganized chapter sequencing according to flowchart at top of [Section 1.1](https://moderndive.com/index.html#intro-for-students)
* Chapter 2 - Getting Started: Added more explanation on R packages, including analogy for `install.packages()` and `library()` (akin to downloading apps onto phone)
* Added "Data Modeling" portion to book
    + Chapter 6 - Basic regression: one numerical explanatory variable, correlation, one categorical explanatory variable)
    + Chapter 7 - Multiple regression: two numerical explanatory variables, one numerical and one categorical, interaction effects, Simpson's Paradox
    + Uses new [`moderndive`](https://moderndive.github.io/moderndive/) package, which includes `get_regression_table()` and `get_regression_points()` wrapper functions to simplify outputting of clean regression tables and observed/fitted values + residuals
* Added "statistical inference" portion to book
    + Added Chapter 8 - Sampling (still under construction) using [sampling bowl](https://github.com/moderndive/moderndive/blob/master/data-raw/sampling_bowl.jpeg)
    + Chapters 9 and 10 on confidence intervals and hypothesis testing have not yet been updated, as we were awaiting the now launched package: [`infer`: A tidyverse-friendly R package fo statistical inference](https://github.com/andrewpbray/infer)
    + Added Chapter 11 - Inference for regression (still under construction), where we'll revisit the regression models fit in Chapters 6 & 7

## Other changes

- Development version of book now available at <https://moderndive.netlify.com/>; deployed via travis-ci + netlify. 
- Added wide ModernDive logo to top of each chapter and `logos` folder
- Added favicon (icon in browser tab)
- Moved home GitHub repository from <https://github.com/ismayc/moderndiver-book/> to <https://github.com/moderndive/moderndive_book>



***



# ModernDive 0.2.0

## Content changes

* Incorporated feedback from consultations with Prof. Jude Weinstein Jones, cognitive psychological scientist and co-founder of [The Learning Scientists](https://www.learningscientists.org/about).
* Restructured/revamped chapters
    + **Chapter 1: Introduction**
        + Friendlier introduction targeted to students is first thing users see. Followed then by introduction  for instructors, ways to connect/contribute, and technical details.
        + Added links to example student projects from two courses that have previously used ModernDive:
            + Middlebury College [MATH 116 Introduction to Statistical and Data Sciences](https://rudeboybert.github.io/MATH116/PS/final_project/final_project_outline.html#past_examples) using student collected data.
            + Pacific University [SOC 301 Social Statistics](https://ismayc.github.io/soc301_s2017/group-projects/index.html) using data from the [fivethirtyeight R package](https://cran.r-project.org/web/packages/fivethirtyeight/vignettes/fivethirtyeight.html)
    + **Chapter 2: Getting Started** New chapter added meant for new R users/coders, including
        + Discussions on R vs RStudio and how to install both (with support videos)
        + A "How do I code in R?" section with links to [DataCamp.com](https://www.datacamp.com/) courses that covers the console, data types, vectors, factors, data frames, boolean operators, functions etc
        + Thorough discussion on R packages
        + An end-to-end starter example analysis of the data frames in the `nycflights13` package using the console, `View()`, `glimpse()` etc.
    + **Chapter 3: Data Visualization via `ggplot2`** now first non-intro chapter.
        + Replaced Menard's "Napolean's March on Moscow" with Hans Rosling's (RIP) "Gapminder" plots as introductory example to Grammar of Graphics.
        + Added `geom_col()` for making barcharts when data is pre-tabulated, instead of using `geom_bar(stat="identity")` 
    + **Chapter 4: Tidy Data via `tidyr`** bumped back. Added sections on converting from wide to long/tidy format and importing CSV's
    + **Chapter 5: Data ~~Manipulation~~ Wrangling via `dplyr`**
    + **Chapter 6: Data Modeling using Regression via `broom`** bumped up from end of book to here given its pedagogical importance, added notes on viewing regression in a prediction framework.
    + **Chapter 7-9: Sampling, Hypothesis Testing, Confidence Intervals** Mostly unchanged for now; see pending changes section below.

## Technical changes

* Book is now hosted on [ModernDive.com](https://moderndive.com/)
* Development version now on original ModernDive site [https://ismayc.github.io/moderndiver-book/](https://ismayc.github.io/moderndiver-book/)
* Added links to digital copies and source code of all past versions of ModernDive in Chapter 1.
* Cut build/compilation time of book from ~20 minutes to ~1 minute
* Disabled gitbook PDF output

## Pending changes for next version

* **Chapter 6: Data Modeling using Regression via `broom`**
    + Better treatment of experimental design and its effect on bias/causation than currently exists in chapter.
    + Examples of regression with categorical predictors with 3 or more levels.
    + Multivariate regression, in particular the following predictor scenarios: 2 numerical, 2 categorical, and 1 numerical + 1 categorical
    + Interaction effects
* **Chapter 7-9: Sampling, Hypothesis Testing, Confidence Intervals** have largely not been updated, pending developments of [`infer`: A tidyverse-friendly R package fo statistical inference](https://github.com/andrewpbray/infer)



***



# ModernDive 0.1.3

* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/moderndive/moderndive_book/issues/2)
    * Reverted to using screenshot with link instead
* Updated link to `dplyr` [cheatsheet](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/data-transformation-cheatsheet.pdf) and `ggplot2` [cheatsheet](https://www.rstudio.com/wp-content/uploads/2016/11/ggplot2-cheatsheet-2.1.pdf)
* Began adding DataCamp chapters as Review Questions to the end of Chapters 3 and 4 (More to come)
* Updated link to MailChimp
* Fixed wording in a few Ch 3 Learning Checks



***



# ModernDive 0.1.2

* Converted last updated in index.Rmd to inline instead of R chunk
* Fixed edit link to point to moderndive-book GitHub repo instead of moderndive-source repo
* Fixed broken links to script files at the end of Chapters 4-9
* Added `purl=FALSE` to chunks that do not contain useful code to the reader
* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/moderndive/moderndive_book/issues/2)



***



# ModernDive 0.1.1

* Fixed the problems of chapter cross-references not working by removing the backticks in chapter names
    + Issue created on `bookdown` [here](https://github.com/rstudio/bookdown/issues/294)
* Looked for typos throughout all chapters
* Added coggle diagrams to Chapter 4 and Appendix B
* Followed the same format of having a Conclusion section at the end of each chapter
* Fixed $T$ distribution plot with histogram in Chapter 7
    + May be weird issue with `cache = TRUE` that incorrectly plotted values on 1/10^th^ the correct scale
    + Will need to keep an eye on it going forward
* Fixed typo on Reach for the Stars chapter name



***



# ModernDive 0.1.0

* Fiat Lux!
* Basic chapter structure in place
* First pass at II Inference section (Chapters 6-9) complete
* First revisions of I Data Exploration (Chapters 3-5) nearly complete
