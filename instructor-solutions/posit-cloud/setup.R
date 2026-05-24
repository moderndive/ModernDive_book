#!/usr/bin/env Rscript
# ModernDive — Posit Cloud workspace setup script.
#
# Run this ONCE in a fresh Posit Cloud project to install every package
# the course uses, including the GitHub-only dataset packages that webR
# students otherwise can't access locally.
#
# Usage in the Posit Cloud console:
#   source("setup.R")
#
# Total install time: ~4-6 minutes on a fresh Posit Cloud container.

cran_packages <- c(
  # Core
  "tidyverse", "knitr", "rmarkdown", "quarto",
  # Wrangling helpers
  "janitor", "lubridate", "stringr", "forcats",
  # Visualization
  "ggplot2", "scales", "viridis",
  # Dataset packages (CRAN)
  "palmerpenguins", "nycflights13", "gapminder", "fivethirtyeight",
  # Inference + modeling
  "moderndive", "infer", "broom",
  # Reading / writing
  "readr", "readxl", "writexl",
  # Misc
  "skimr", "naniar", "GGally"
)

github_packages <- c(
  "moderndive/olympicAthletes",
  "ismayc/steves",
  "moderndive/exoplanets",
  "moderndive/volcanoes"
)

cat("\n=== ModernDive Posit Cloud setup ===\n")
cat(sprintf("Installing %d CRAN packages and %d GitHub-only packages.\n",
            length(cran_packages), length(github_packages)))
cat("This takes ~4-6 minutes on a fresh Posit Cloud container.\n\n")

# CRAN packages — only install what's missing
to_install_cran <- setdiff(cran_packages, rownames(installed.packages()))
if (length(to_install_cran)) {
  cat(sprintf("[1/2] Installing %d CRAN packages...\n", length(to_install_cran)))
  install.packages(to_install_cran, repos = "https://cran.rstudio.com")
} else {
  cat("[1/2] All CRAN packages already installed.\n")
}

# GitHub packages — need `remotes`
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes", repos = "https://cran.rstudio.com")
}
cat(sprintf("\n[2/2] Installing %d GitHub-only packages...\n",
            length(github_packages)))
for (pkg in github_packages) {
  pkg_name <- sub("^.*/", "", pkg)
  if (requireNamespace(pkg_name, quietly = TRUE)) {
    cat(sprintf("  - %s: already installed (skipping)\n", pkg))
    next
  }
  cat(sprintf("  - installing %s ...\n", pkg))
  tryCatch(
    remotes::install_github(pkg, upgrade = "never", quiet = TRUE),
    error = function(e) {
      cat(sprintf("    WARN: failed to install %s: %s\n", pkg, conditionMessage(e)))
    }
  )
}

# Sanity check: every package can be loaded
cat("\n=== Sanity check: loading every required package ===\n")
all_pkgs <- c(cran_packages, sub("^.*/", "", github_packages))
failed <- character()
for (pkg in all_pkgs) {
  ok <- suppressMessages(suppressWarnings(
    requireNamespace(pkg, quietly = TRUE)))
  status <- if (ok) "OK" else "FAIL"
  cat(sprintf("  %-5s %s\n", status, pkg))
  if (!ok) failed <- c(failed, pkg)
}

if (length(failed)) {
  cat(sprintf("\n[WARNING] %d packages failed to load: %s\n",
              length(failed), paste(failed, collapse = ", ")))
  cat("Re-run setup.R or install those packages manually.\n")
} else {
  cat("\n[SUCCESS] All packages installed and loadable.\n")
  cat("This workspace is ready for ModernDive. Open welcome.qmd to start.\n")
}
