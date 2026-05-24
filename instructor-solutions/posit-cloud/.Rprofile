# Per-project R startup for the ModernDive template.
# Quiet, helpful defaults.

# Friendlier startup message
if (interactive()) {
  message("ModernDive Posit Cloud template — packages ready.")
  message("Run source('setup.R') if you need to (re)install packages.")
  message("Open welcome.qmd to get started.")
}

# Default to tidyverse-y options
options(
  stringsAsFactors = FALSE,
  digits = 4,
  scipen = 6,
  show.signif.stars = FALSE
)

# CRAN mirror
local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.rstudio.com"
  options(repos = r)
})
