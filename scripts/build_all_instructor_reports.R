#!/usr/bin/env Rscript
# Master driver: runs every standalone instructor-report script in one
# Rscript invocation. Saves ~5-10 sec per script of R-startup tax —
# about 1 minute total across all 11 reports — by re-using one R session.
#
# Each child script does its own setwd() if needed and writes output to
# instructor-solutions/_site/, so sourcing them sequentially in a single
# R process gives identical output to running them separately.
#
# Run:  Rscript scripts/build_all_instructor_reports.R

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

scripts <- c(
  "scripts/build_homework_planner.R",
  "scripts/build_lesson_plans.R",
  "scripts/exercise_coverage_map.R",
  "scripts/build_concept_map.R",
  "scripts/build_assessment_matrix.R",
  "scripts/build_misconceptions.R",
  "scripts/build_exam_bank.R",          # also writes LMS exports
  "scripts/build_pacing_calculator.R",
  "scripts/build_cumulative_review.R",
  "scripts/build_flashcards.R",
  "scripts/build_diagrams.R",            # SVG + PNG teaching diagrams
  "scripts/audit_accessibility.R"        # runs LAST so it sees everything
)

t_start <- Sys.time()
for (s in scripts) {
  cat(sprintf("\n=== %s ===\n", s))
  s_start <- Sys.time()
  # local = TRUE keeps each script's top-level assignments scoped, so
  # later scripts don't accidentally see leftover state. Functions in
  # _hub_nav.R get re-sourced each time but that's only a few ms.
  source(s, local = TRUE)
  cat(sprintf("  -> %.1fs\n", as.numeric(difftime(Sys.time(), s_start, units = "secs"))))
}
cat(sprintf("\n=== All %d reports done in %.1fs ===\n",
            length(scripts),
            as.numeric(difftime(Sys.time(), t_start, units = "secs"))))
