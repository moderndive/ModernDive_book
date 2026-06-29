#!/usr/bin/env Rscript
# Build data/webr-shadow-help.rds: the help index consumed by the `?dataset`
# shim in scripts/webr-shadow-library.R. For each GitHub-only companion
# dataset shadow-loaded in webR, we extract the .Rd title and the per-column
# \format \item glosses from the *installed* package, so `?olympic_athletes`
# (and friends) can render an inline help page in webR, where those packages
# can't be installed and there is no help database.
#
# Re-run this whenever the companion packages' documentation changes:
#   Rscript scripts/build-webr-shadow-help.R
# then commit data/webr-shadow-help.rds to the v2 and v2-quarto-html branches.

want <- list(
  olympicAthletes = c("olympic_athletes", "editions", "medal_table",
                      "athletics_athletes", "gymnastics_athletes",
                      "basketball_athletes", "olympic_athletes_2000_2026"),
  steves    = c("episodes"),
  exoplanets = c("planets"),
  volcanoes = c("eruptions", "volcanoes")
)

extract_items <- function(rd) {
  items <- list()
  walk <- function(x) {
    tag <- attr(x, "Rd_tag")
    if (!is.null(tag) && tag == "\\item" && length(x) >= 2) {
      nm <- trimws(paste(unlist(x[[1]]), collapse = ""))
      ds <- trimws(gsub("[[:space:]]+", " ", paste(unlist(x[[2]]), collapse = "")))
      if (nzchar(nm)) items[[nm]] <<- ds
    }
    if (is.list(x)) for (e in x) walk(e)
  }
  walk(rd)
  items
}

out <- list()
for (pkg in names(want)) {
  db <- tryCatch(tools::Rd_db(pkg), error = function(e) NULL)
  if (is.null(db)) { message("No Rd_db for ", pkg, " (is it installed?)"); next }
  for (ds in want[[pkg]]) {
    hit <- NULL
    for (nm in names(db)) {
      al <- tools:::.Rd_get_metadata(db[[nm]], "alias")
      if (ds %in% al) { hit <- db[[nm]]; break }
    }
    if (is.null(hit)) { message("  no Rd for ", pkg, "::", ds); next }
    ti <- trimws(gsub("[[:space:]]+", " ",
      paste(unlist(tools:::.Rd_get_metadata(hit, "title")), collapse = " ")))
    out[[ds]] <- list(pkg = pkg, title = ti, items = extract_items(hit))
    message(sprintf("  %s::%s  (%d documented columns)", pkg, ds,
                    length(out[[ds]]$items)))
  }
}

dir.create("data", showWarnings = FALSE)
saveRDS(out, "data/webr-shadow-help.rds")  # gzip (gzcon-readable in webR)
message("Wrote data/webr-shadow-help.rds for ", length(out), " datasets.")
