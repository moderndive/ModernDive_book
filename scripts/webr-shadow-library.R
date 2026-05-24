# Shadow library() for the ModernDive v2 Quarto book's webR cells.
#
# Two webR-specific gaps this addresses:
#
# (1) The four GitHub-only companion packages — olympicAthletes, steves,
#     exoplanets, volcanoes — can't be installed in webR. For those, the
#     shadow reads each package's datasets from a v2 raw .rds mirror into
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
#   webR:                .rds mirror fills both gaps
#   local RStudio:       base::library + dataset lookup, no network reads
#   server-side CI eval: same as local RStudio
#
# We use `.rds` (R's native binary format via saveRDS/readRDS) rather than
# `.csv.gz` because (a) readRDS in webR is roughly 2x faster than
# read.csv(gzfile(...)) for large data frames and (b) the big file
# (olympic_athletes) shrinks from 5.8 MB → 3.2 MB with xz compression. The
# previous readr-based CSV path doesn't work — webR's readr hangs on remote
# URLs, and parsing 315k rows of CSV in wasm is slow even after download.
#
# Sourced from each chapter's `#| context: setup` webR cell. Idempotent:
# repeat `library()` calls skip datasets already in globalenv().
#
# To add a dataset:
#   - GitHub-only package -> append to `pkg_data`
#   - Newer-than-webR moderndive dataset -> append to `pkg_extras$moderndive`
# Then ship the matching .rds on the v2 branch.

local({
  # Datasets to load from the v2 RDS mirror when a GitHub-only package
  # isn't installed (webR's case).
  pkg_data <- list(
    olympicAthletes = c(
      olympic_athletes = "olympic_athletes.rds",
      editions         = "olympic_editions.rds",
      medal_table      = "olympic_medal_table.rds"
    ),
    steves = c(
      episodes = "steves_episodes.rds"
    ),
    exoplanets = c(
      planets = "exoplanets_planets.rds"
    ),
    volcanoes = c(
      eruptions = "volcanoes_eruptions.rds",
      volcanoes = "volcanoes_volcanoes.rds"
    )
  )

  # Datasets to fill in after base::library succeeds when webR's binary
  # version of a package lags CRAN. Each entry: package -> dataset:file.
  pkg_extras <- list(
    moderndive = list(
      envoy_flights              = "envoy_flights.rds",
      early_january_2023_weather = "early_january_2023_weather.rds",
      un_member_states_2024      = "un_member_states_2024.rds"
    )
  )

  base_url <- "https://raw.githubusercontent.com/moderndive/ModernDive_book/v2/data/"

  # Push a transient toast like "Loading olympic_athletes…" to the DOM helper
  # defined in _includes/webr-status.html. Silent no-op outside webR (the
  # `webr` package isn't installed in regular R, so the call errors and try()
  # swallows it) — this keeps Layer B / local sourcing of the shadow clean.
  set_status <- function(msg) {
    js <- sprintf(
      "if (window.moderndiveSetStatus) window.moderndiveSetStatus('%s');",
      gsub("'", "\\\\'", msg, fixed = TRUE)
    )
    try(webr::eval_js(js), silent = TRUE)
  }

  load_from_mirror <- function(ds, file) {
    set_status(sprintf("Loading %s…", ds))
    # `download.file()` can hang indefinitely in webR's browser worker
    # (synchronous network calls in Web Workers are unreliable). Streaming
    # the gzipped RDS through `gzcon(url(...))` uses R's url-connection
    # path, which webR routes through the async-compatible fetch API.
    # Works identically in regular R.
    con <- gzcon(url(paste0(base_url, file), "rb"))
    on.exit(close(con), add = TRUE)
    assign(ds, readRDS(con), envir = globalenv())
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
