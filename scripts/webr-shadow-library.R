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
      olympic_athletes        = "olympic_athletes.rds",
      editions                = "olympic_editions.rds",
      medal_table             = "olympic_medal_table.rds",
      athletics_athletes      = "athletics_athletes.rds",
      gymnastics_athletes     = "gymnastics_athletes.rds",
      basketball_athletes     = "basketball_athletes.rds",
      recent_olympic_athletes = "recent_olympic_athletes.rds"
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

  load_from_mirror <- function(ds, file) {
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
    # library() with no arg lists installed packages — delegate.
    if (missing(package)) return(base::library())
    # Coerce to a single character regardless of how it was passed. webR's
    # quarto-webr cell driver calls library() with various shapes (symbol,
    # already-character with character.only=TRUE, sometimes via do.call); the
    # earlier `as.character(substitute(package))` blew up with "invalid
    # argument type" when the substituted expression wasn't a name/string.
    pkg <- tryCatch(
      if (character.only) as.character(package)[1] else as.character(substitute(package)),
      error = function(e) NA_character_
    )
    if (is.na(pkg) || !nzchar(pkg)) {
      return(invisible(base::library(package, ..., character.only = character.only)))
    }
    # Use the shadow path only when (a) we know this package, AND (b) the
    # real package isn't actually installed (webR's case). We use
    # `.packages(all.available = TRUE)` rather than `requireNamespace()`
    # because webR shims requireNamespace to attempt `webr::install()` on
    # miss, which logs "Requested package X not found in webR binary repo"
    # for our GitHub-only packages even when wrapped in quietly/suppressWarnings.
    is_installed <- tryCatch(
      pkg %in% .packages(all.available = TRUE),
      error = function(e) FALSE
    )
    use_shadow <- pkg %in% names(pkg_data) && !is_installed
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

  # Suppress quarto-webr's "Requested package <X> not found in webR binary repo"
  # warning for the four GitHub-only packages the shadow handles. webr::install
  # (called by quarto-webr's auto-install of any library() reference and by the
  # shimmed install.packages) checks repo.r-wasm.org — our packages aren't
  # there, hence the noisy warning. Shim it: silently no-op for shadow-handled
  # packages, delegate to the real install for everything else.
  if (requireNamespace("webr", quietly = TRUE)) {
    try({
      ns <- asNamespace("webr")
      if (exists("install", envir = ns)) {
        real_install <- get("install", envir = ns)
        shadow_install <- function(packages, ...) {
          packages <- setdiff(packages, names(pkg_data))
          if (length(packages) > 0) real_install(packages, ...)
        }
        # Unlock + replace + relock the binding inside the webr namespace.
        # utils::assignInNamespace handles this cleanly.
        utils::assignInNamespace("install", shadow_install, ns = "webr")
      }
    }, silent = TRUE)
  }
})
