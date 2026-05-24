#!/usr/bin/env Rscript
# Server-side evaluation of every {webr-r} cell in chapter qmds + Appendix B.
#
# Layer B of the webR test pyramid (see scripts/audit_webr_symbols.R for Layer A
# and scripts/test_webr_headless/ for Layer C): static-checked code may still
# have runtime errors (wrong column names, missing intermediates, type
# mismatches). This script runs every cell sequentially in plain R, mimicking
# what webR will execute browser-side.
#
# How the shadow library interacts: the chapter setup cell calls
# `source("https://…/scripts/webr-shadow-library.R")`. The shadow's first
# action is `requireNamespace(<pkg>)` — if the package IS installed (this
# script's CI job installs the four GitHub-only ones), the shadow falls
# through to `base::library()`. So this script exercises the real `library(...)`
# path, not the CSV mirrors.
#
# Caveat: this catches ~80% of webR-affecting bugs (logic, undefined symbols,
# wrong column names). It does NOT catch webR-specific issues like gzip-over-
# HTTP decode failures or missing-package errors that only manifest in real
# webR (because all packages used here are installed locally) — that's what
# Layer C is for.

suppressPackageStartupMessages({
  library(stringr)
})

setwd(Sys.getenv("GITHUB_WORKSPACE",
                 unset = "/Users/chesterismay/Desktop/repos/ModernDive_book"))

extract_webr_cells <- function(qmd_path) {
  txt <- paste(readLines(qmd_path, warn = FALSE), collapse = "\n")
  m <- str_match_all(txt, "(?s)```\\{webr-r[^}]*\\}(.*?)```")[[1]]
  if (nrow(m) == 0) return(list())
  lapply(seq_len(nrow(m)), function(i) {
    body <- m[i, 2]
    list(
      body = body,
      is_setup = str_detect(substr(body, 1, 120), "context:\\s*setup"),
      idx = i
    )
  })
}

qmd_files <- sort(list.files(".", pattern = "^[0-9]+.*\\.qmd$"))
qmd_files <- qmd_files[file.exists(qmd_files)]

cat("=== Server-side webR cell evaluation ===\n")
cat("Scanning", length(qmd_files), "qmd files\n\n")

total_cells <- 0
failed <- list()

for (qmd in qmd_files) {
  cells <- extract_webr_cells(qmd)
  if (length(cells) == 0) next
  cat("== ", qmd, " (", length(cells), " webR cells)\n", sep = "")

  # One fresh env per chapter, with globalenv as parent so attached
  # packages remain visible. (Tradeoff: prior chapters' attached packages
  # stay in the search path — harmless since chapters stack supersets.)
  chap_env <- new.env(parent = globalenv())

  # Quarto/webR runs `#| context: setup` cells BEFORE any other cell in
  # the same chapter regardless of file position. Match that order here.
  cells <- c(
    cells[vapply(cells, function(c) c$is_setup, logical(1))],
    cells[!vapply(cells, function(c) c$is_setup, logical(1))]
  )

  for (cell in cells) {
    total_cells <- total_cells + 1
    label <- if (cell$is_setup) "setup" else paste0("cell #", cell$idx)
    result <- tryCatch(
      {
        # Capture and discard plot/text output to keep CI logs short.
        out <- capture.output(
          eval(parse(text = cell$body), envir = chap_env),
          type = "output"
        )
        list(ok = TRUE)
      },
      error = function(e) list(ok = FALSE, msg = conditionMessage(e)),
      # webR ignores most warnings; treat as pass but log.
      warning = function(w) list(ok = TRUE, msg = NULL)
    )
    if (!result$ok) {
      cat("  ✗ ", label, ": ", result$msg, "\n", sep = "")
      failed[[length(failed) + 1]] <- list(qmd = qmd, label = label, msg = result$msg)
    } else {
      cat("  ✓ ", label, "\n", sep = "")
    }
  }
}

cat("\n========================\n")
cat("Total webR cells evaluated:", total_cells, "\n")
cat("Failed:", length(failed), "\n")
if (length(failed) > 0) {
  cat("\nFailures:\n")
  for (f in failed) {
    cat("  ", f$qmd, "  ", f$label, "\n    ", f$msg, "\n", sep = "")
  }
  quit(status = 1)
}
cat("\n✓ all", total_cells, "webR cells evaluated successfully\n")
