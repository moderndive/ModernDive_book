# Shadow library() for the ModernDive v2 Quarto book's webR cells.
#
# In webR (browser-side R) the four GitHub-only companion packages —
# olympicAthletes, steves, exoplanets, volcanoes — can't be installed. To keep
# student code identical to what they'd write in local RStudio
# (`library(olympicAthletes)`), this shadow intercepts those four package
# names and, *only when the real package isn't already installed*, reads the
# matching `.csv.gz` mirrors on the v2 branch into globalenv(). For any
# other package — or when the real package IS available (local R, server-side
# CI eval) — it delegates to base::library() unchanged.
#
# Net result:
#   webR:                shadow loads from CSV mirror
#   local RStudio:       shadow no-ops; base::library loads the real package
#   server-side CI eval: same as local RStudio
#
# Sourced from each chapter's `#| context: setup` webR cell. Idempotent: a
# repeat `library(<gh-pkg>)` call skips datasets already in globalenv().
#
# To add a dataset: append it to `pkg_data` below and ship the matching
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
    # Fall through to base::library if (a) we don't know this package, OR
    # (b) it's a known GitHub-only one but is actually installed (local R / CI).
    use_shadow <- pkg %in% names(pkg_data) &&
      !requireNamespace(pkg, quietly = TRUE)
    if (use_shadow) {
      # We do NOT use readr::read_csv() with the gz URL directly because webR's
      # readr hangs indefinitely on .csv.gz URLs (gzip decoding from a remote
      # stream isn't wired up). The base-R pattern below works reliably:
      # download.file() fetches the bytes, then read.csv(gzfile(...)) decodes
      # locally. The same pattern works identically in regular R.
      for (ds in names(pkg_data[[pkg]])) {
        if (!exists(ds, envir = globalenv(), inherits = FALSE)) {
          tmp <- tempfile(fileext = ".csv.gz")
          url <- paste0(base_url, pkg_data[[pkg]][[ds]])
          download.file(url, tmp, quiet = TRUE, mode = "wb")
          assign(ds, read.csv(gzfile(tmp)), envir = globalenv())
          unlink(tmp)
        }
      }
      invisible()
    } else {
      base::library(pkg, ..., character.only = TRUE)
    }
  }
  assign("library", shadow_library, envir = globalenv())
})
