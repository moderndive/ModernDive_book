# Shadow library() for the ModernDive v2 Quarto book's webR cells.
#
# webR (browser-side R) can't install the four GitHub-only companion packages
# (olympicAthletes, steves, exoplanets, volcanoes). To keep student code
# identical to what they'd write in local RStudio — `library(olympicAthletes)`
# — this shadow intercepts those four package names and reads each package's
# datasets from the v2 raw CSV mirror into globalenv(). For any other package
# name it delegates to base::library(), so `library(dplyr)` etc. behave normally.
#
# Sourced from each chapter's `#| context: setup` webR cell. Idempotent: a
# repeat `library(<gh-pkg>)` call skips datasets already in globalenv().
#
# To add a dataset: append it to `.gh_pkg_data` below and ship the matching
# .csv.gz on the v2 branch.

local({
  pkg_data <- list(
    olympicAthletes = c(
      olympic_athletes = "olympic_athletes.csv.gz",
      editions         = "olympic_editions.csv.gz",
      medal_table      = "olympic_medal_table.csv.gz"
    ),
    steves = c(
      episodes = "steves_episodes.csv.gz"
    ),
    exoplanets = c(
      planets = "exoplanets_planets.csv.gz"
    ),
    volcanoes = c(
      eruptions = "volcanoes_eruptions.csv.gz",
      volcanoes = "volcanoes_volcanoes.csv.gz"
    )
  )
  base_url <- "https://raw.githubusercontent.com/moderndive/ModernDive_book/v2/data/"

  shadow_library <- function(package, ..., character.only = FALSE) {
    pkg <- if (character.only) package else as.character(substitute(package))
    if (pkg %in% names(pkg_data)) {
      for (ds in names(pkg_data[[pkg]])) {
        if (!exists(ds, envir = globalenv(), inherits = FALSE)) {
          assign(
            ds,
            readr::read_csv(
              paste0(base_url, pkg_data[[pkg]][[ds]]),
              show_col_types = FALSE
            ),
            envir = globalenv()
          )
        }
      }
      invisible()
    } else {
      base::library(pkg, ..., character.only = TRUE)
    }
  }
  assign("library", shadow_library, envir = globalenv())
})
