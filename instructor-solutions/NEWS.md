---
title: "Instructor Resources — What's New"
subtitle: "Recent updates to the instructor hub"
format:
  html:
    theme:
      light: [cosmo, moderndive-instructor.scss]
      dark: darkly
    css: ../style.css
    toc: true
    toc-depth: 2
    embed-resources: true
---

This page tracks substantive changes to the **instructor resources hub** (this site) — new tools, redesigns, content additions, and fixes. The book itself has its own [`NEWS.md`](https://github.com/moderndive/ModernDive_book/blob/v2-quarto-html/NEWS.md) for student-facing changes.

# 2026-05-24 — Five new tools + concept-map rewrite

* **Pacing calculator** ([pacing-calculator.html](pacing-calculator.html)) — interactive bin-packer that fits the 11 chapters into your term given weeks-of-instruction, class-min/week, and out-of-class-min/week. Highlights weeks that overflow the per-week budget; ranks chapters by skippability for compressed terms. Per-chapter time budgets mirror the lesson-plans heuristic (150 wpm reading + 3 min/QC + 2 min/LC + 3 min/section).
* **Assessment alignment matrix** ([assessment-matrix.html](assessment-matrix.html)) — cross-references every chapter's Learning Objectives against its end-of-chapter exercises, scored by keyword overlap (backticked code = strongest signal, italic/bold next, prose weakest). Surfaces LOs that may be under-assessed.
* **Misconceptions cheat-sheet** ([misconceptions.html](misconceptions.html)) — 115 Quick checks across 11 chapters distilled into 345 distractor explanations ("students who pick (b) are probably thinking…"). Live keyword filter at top; per-chapter jump links. Pre-lecture skim or office-hours quick-lookup.
* **Exam question bank** ([exam-bank.html](exam-bank.html)) — 7 stratified-sample exam templates × 3 parallel forms each (versions A/B/C). Includes single-chapter quizzes, two midterms, comprehensive final, and an inference-unit exam. Print-ready with workspace, point values from difficulty stars, solution links per question. Pool of 331 non-Extension non-carryover exercises.
* **Cumulative review** ([cumulative-review.html](cumulative-review.html)) — three milestone student-facing study guides (after Ch 4, after Ch 7, comprehensive final). Curated medium-difficulty exercises from prior chapters + vocabulary checklist (glossary terms intro'd by that point) + concept-thread framing.
* **Concept map rewritten** ([concept-map.html](concept-map.html)) — previous design was a static SVG with 232 raw arcs piling into spaghetti. Replaced with an interactive vis-network force-directed graph (drag, hover-highlight neighbors, edge weight = ref count) plus an adjacency-matrix heatmap. 74 aggregated edges in the graph view + 73 filled matrix cells; every relationship visible at a glance.
* **Hub page expanded** — instructor-solutions/index.qmd now lists 13 resources across the three planning/teaching/assessing buckets.

# 2026-05-12 — Instructor tooling first pass

The initial set of eight instructor resources (syllabus, lesson plans, slide decks, facilitator notes, homework planner, coverage map, concept map, worked solutions) shipped in book release 2.8.11–2.8.13. See the book's NEWS for detail on each:

* [2.8.11](https://github.com/moderndive/ModernDive_book/blob/v2-quarto-html/NEWS.md#moderndive-2811--instructor-tooling-pass-lesson-plans-homework-planner-slide-decks) — Lesson plans, homework planner, slide decks
* [2.8.12](https://github.com/moderndive/ModernDive_book/blob/v2-quarto-html/NEWS.md#moderndive-2812--facilitator-notes-syllabus-shared-instructor-scss) — Facilitator notes, syllabus, shared SCSS
* [2.8.13](https://github.com/moderndive/ModernDive_book/blob/v2-quarto-html/NEWS.md#moderndive-2813--instructor-resources-hub-at--solutions-move-to-solutions) — Hub at root, solutions moved to `/solutions/`
