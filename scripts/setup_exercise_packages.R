# Centralized installer/loader for exercise dataset packages.
#
# Each chapter's exercise section sources this file and calls
# `install_exercise_packages()` for the packages it needs. Once a package
# lands on CRAN, flip its `from_github` flag to FALSE here and the next
# build will pull from CRAN instead of GitHub. No other code needs to change.

EXERCISE_PACKAGES <- list(
  olympicAthletes = list(
    repo        = NA_character_,
    from_github = FALSE
  ),
  steves = list(
    repo        = NA_character_,
    from_github = FALSE
  ),
  exoplanetdata = list(
    repo        = NA_character_,
    from_github = FALSE
  ),
  volcanoes = list(
    repo        = NA_character_,
    from_github = FALSE
  ),
  fivethirtyeight = list(
    repo        = NA_character_,
    from_github = FALSE
  )
)

install_exercise_packages <- function(packages = names(EXERCISE_PACKAGES),
                                      quiet    = TRUE) {
  for (pkg in packages) {
    if (requireNamespace(pkg, quietly = TRUE)) next
    spec <- EXERCISE_PACKAGES[[pkg]]
    if (is.null(spec)) {
      stop("Unknown exercise package: ", pkg,
           ". Add an entry to EXERCISE_PACKAGES in scripts/setup_exercise_packages.R.")
    }
    if (isTRUE(spec$from_github)) {
      if (!requireNamespace("remotes", quietly = TRUE)) {
        install.packages("remotes", quiet = quiet)
      }
      remotes::install_github(
        spec$repo,
        quiet   = quiet,
        upgrade = "never"
      )
    } else {
      install.packages(pkg, quiet = quiet)
    }
  }
  invisible(packages)
}
