# Shadow library() for the ModernDive v2 Quarto book's webR cells.
#
# Two webR-specific gaps this addresses:
#
# (1) The four GitHub-only companion packages — olympicAthletes, steves,
#     exoplanets, volcanoes — can't be installed in webR. For those, the
#     shadow reads each package's datasets from a v2 raw .csv.gz mirror into
#     globalenv() when `library(<pkg>)` is called.
#
# (2) webR's binary moderndive (from repo.r-wasm.org) can lag behind CRAN
#     and miss newer datasets (`envoy_flights`, `early_january_2023_weather`,
#     etc.) that chapter cells reference. After `library(moderndive)` succeeds
#     via base::library, the shadow tops up any datasets the local install
#     doesn't already have, also from the v2 raw mirror.
#
# For every other package — or when a known GitHub-only package IS
# installed (local R, server-side CI eval) — the shadow delegates to
# `base::library()` unchanged. Same student code path in all environments.
#
# Net result:
#   webR:                CSV mirror fills both gaps
#   local RStudio:       base::library + dataset lookup, no network reads
#   server-side CI eval: same as local RStudio
#
# Sourced from each chapter's `#| context: setup` webR cell. Idempotent:
# repeat `library()` calls skip datasets already in globalenv().
#
# To add a dataset:
#   - GitHub-only package -> append to `pkg_data`
#   - Newer-than-webR moderndive dataset -> append to `pkg_extras$moderndive`
# Then ship the matching .csv.gz on the v2 branch.

local({
  # Datasets to load from the v2 CSV mirror when a GitHub-only package
  # isn't installed (webR's case).
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

  # Datasets to fill in after base::library succeeds when webR's binary
  # version of a package lags CRAN. Each entry: package -> dataset:file.
  pkg_extras <- list(
    moderndive = list(
      envoy_flights              = "envoy_flights.csv.gz",
      early_january_2023_weather = "early_january_2023_weather.csv.gz"
    )
  )

  base_url <- "https://raw.githubusercontent.com/moderndive/ModernDive_book/v2/data/"

  load_from_mirror <- function(ds, file) {
    tmp <- tempfile(fileext = ".csv.gz")
    download.file(paste0(base_url, file), tmp, quiet = TRUE, mode = "wb")
    assign(ds, read.csv(gzfile(tmp)), envir = globalenv())
    unlink(tmp)
  }

  fill_missing_datasets <- function(pkg) {
    extras <- pkg_extras[[pkg]]
    if (is.null(extras)) return(invisible())
    for (ds in names(extras)) {
      if (exists(ds, envir = globalenv(), inherits = FALSE)) next
      # Try the attached package first
      found <- tryCatch({
        suppressWarnings(data(list = ds, envir = globalenv(), package = pkg))
        exists(ds, envir = globalenv(), inherits = FALSE)
      }, error = function(e) FALSE)
      if (!found) load_from_mirror(ds, extras[[ds]])
    }
  }

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
          load_from_mirror(ds, pkg_data[[pkg]][[ds]])
        }
      }
      invisible()
    } else {
      base::library(pkg, ..., character.only = TRUE)
      fill_missing_datasets(pkg)
    }
  }
  assign("library", shadow_library, envir = globalenv())
})
