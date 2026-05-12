#!/usr/bin/env Rscript
# Linter for exercise YAML files.
#
# Catches authoring bugs before render. For each `exercises/NN.yml` and
# (if present locally) `exercises/NN-solutions.yml`, validates:
#
#   1. Required fields present per exercise entry: `ex_num`, `difficulty`,
#      `prompt`. `group`, `book_section`, `book_subsection` recommended.
#   2. `difficulty` is 1, 2, or 3.
#   3. `ex_num` values within a chapter are unique.
#   4. Exercises whose prompt mentions running code (e.g., "fit", "plot",
#      "compute", "build", "run") have a `webr:` field — otherwise reader
#      gets a prose-only exercise that says "build a plot" with no canvas.
#      (Heuristic; flagged as warning, not error.)
#   5. Solution YAML's `ex_num` set is a subset of the exercise YAML's
#      `ex_num` set (no orphaned solutions).
#   6. Each non-Extensions exercise's `book_section` value resolves to a
#      real section in the corresponding chapter qmd (warns otherwise —
#      typo-catching).
#
# Exits non-zero if any *error*-level check fails; warnings print but
# don't fail.

suppressPackageStartupMessages({
  library(yaml)
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

required_fields <- c("ex_num", "difficulty", "prompt")
code_verbs <- c(
  "fit", "plot", "build", "compute", "run", "draw", "visualize",
  "sample", "simulate", "bootstrap", "generate", "calculate",
  "summarize", "filter", "mutate", "scatter", "histogram", "boxplot"
)
code_verbs_re <- paste0("\\b(", paste(code_verbs, collapse = "|"), ")\\b")

errors  <- character()
warnings <- character()

chap_section_titles <- function(chap) {
  qmd_file <- list.files(".", pattern = sprintf("^%02d-.*\\.qmd$", chap),
                         full.names = TRUE)
  if (!length(qmd_file)) return(character())
  lines <- readLines(qmd_file[1], warn = FALSE)
  # Section titles: lines starting with `## ` (and ` ` after to avoid `#`
  # in code), strip trailing `{#...}` attribute blocks.
  hdrs <- lines[grep("^##\\s+\\S", lines)]
  sub("\\s*\\{.*$", "", sub("^##\\s+", "", hdrs))
}

for (chap in 1:11) {
  pub_path <- sprintf("exercises/%02d.yml", chap)
  priv_path <- sprintf("exercises/%02d-solutions.yml", chap)
  if (!file.exists(pub_path)) next

  pub <- tryCatch(yaml::read_yaml(pub_path),
                  error = function(e) {
                    errors <<- c(errors,
                                 sprintf("[%s] YAML parse error: %s", pub_path, e$message))
                    NULL
                  })
  if (is.null(pub)) next
  if (is.null(pub$exercises) || !length(pub$exercises)) {
    warnings <- c(warnings, sprintf("[%s] no `exercises:` entries", pub_path))
    next
  }

  # Section titles in the corresponding chapter qmd (for typo-catching)
  section_titles <- chap_section_titles(chap)
  # `book_section` values seen, with extras for cross-cuts
  cross_cuts <- c("Setup", "Critical thinking", "Extensions", "Setup / EDA",
                  "Critical thinking / synthesis", "Critical thinking / open exploration",
                  "Critical thinking / synthesis (cross-section)",
                  "Critical thinking / synthesis / open exploration",
                  "Concluding remarks / cross-chapter synthesis",
                  "Practical / interpretation (cross-section)",
                  "Misuses / critical thinking (cross-section)",
                  "Model comparison / selection (cross-section)",
                  "Residual diagnostics (cross-cuts 5.1.3/5.2.3)")
  allowed_section_values <- function(title) {
    # Accept exact section titles, "N.M Title" or "N.M.K Title" prefixes,
    # cross-cut names, and the chapter-overview placeholders the YAMLs use.
    if (is.null(title)) return(TRUE)
    title <- as.character(title)
    if (grepl("^[0-9]+\\.[0-9]+", title)) return(TRUE)
    if (any(startsWith(title, cross_cuts))) return(TRUE)
    if (grepl("^Setup", title)) return(TRUE)
    title %in% section_titles
  }

  ex_nums <- integer()
  for (ex in pub$exercises) {
    # 1. Required fields
    for (f in required_fields) {
      if (is.null(ex[[f]])) {
        errors <- c(errors,
                    sprintf("[%s] ex_num=%s missing required field `%s`",
                            pub_path, as.character(ex$ex_num), f))
      }
    }
    # 2. Difficulty in {1, 2, 3}
    if (!is.null(ex$difficulty) && !(as.integer(ex$difficulty) %in% 1:3)) {
      errors <- c(errors,
                  sprintf("[%s] ex_num=%s has difficulty=%s (must be 1, 2, or 3)",
                          pub_path, ex$ex_num, ex$difficulty))
    }
    # 3. Unique ex_num within chapter
    if (!is.null(ex$ex_num)) {
      if (ex$ex_num %in% ex_nums) {
        errors <- c(errors,
                    sprintf("[%s] duplicate ex_num=%s", pub_path, ex$ex_num))
      }
      ex_nums <- c(ex_nums, as.integer(ex$ex_num))
    }
    # 4. Code-verb in prompt but no `webr` (warning only)
    if (!is.null(ex$prompt) && is.null(ex$webr)) {
      prompt_text <- tolower(as.character(ex$prompt))
      if (grepl(code_verbs_re, prompt_text)) {
        warnings <- c(warnings,
                      sprintf("[%s] ex_num=%s: prompt looks code-needing but no `webr` field set",
                              pub_path, ex$ex_num))
      }
    }
    # 6. book_section sanity (typo-catching, warning)
    if (!is.null(ex$book_section)) {
      bs <- as.character(ex$book_section)
      # Strip "N.M " or "N.M.K " prefix for comparison
      bs_title <- sub("^[0-9]+(\\.[0-9]+){0,2}\\s+", "", bs)
      if (length(section_titles) &&
          !any(startsWith(section_titles, bs_title)) &&
          !any(startsWith(bs, c(cross_cuts, "Setup", "Extensions",
                                "Residual diagnostics", "Concluding")))) {
        warnings <- c(warnings,
                      sprintf("[%s] ex_num=%s: book_section '%s' doesn't match any section title in chapter %d",
                              pub_path, ex$ex_num, bs, chap))
      }
    }
  }

  # 5. Solution YAML ex_num ⊆ exercise YAML ex_num
  if (file.exists(priv_path)) {
    priv <- tryCatch(yaml::read_yaml(priv_path),
                     error = function(e) {
                       warnings <<- c(warnings,
                                      sprintf("[%s] YAML parse error: %s", priv_path, e$message))
                       NULL
                     })
    if (!is.null(priv) && length(priv$exercises)) {
      priv_nums <- sapply(priv$exercises, function(x) as.integer(x$ex_num))
      orphans <- setdiff(priv_nums, ex_nums)
      if (length(orphans)) {
        warnings <- c(warnings,
                      sprintf("[%s] solution ex_num %s have no matching prompt in %s",
                              priv_path, paste(orphans, collapse = ", "), pub_path))
      }
    }
  }
}

# Report
cat(sprintf("Errors:   %d\nWarnings: %d\n\n", length(errors), length(warnings)))
if (length(errors)) {
  cat("=== ERRORS ===\n")
  for (e in errors) cat("  ", e, "\n", sep = "")
  cat("\n")
}
if (length(warnings)) {
  cat("=== WARNINGS ===\n")
  for (w in warnings) cat("  ", w, "\n", sep = "")
  cat("\n")
}
if (length(errors)) quit(status = 1)
cat("All exercise YAMLs OK.\n")
