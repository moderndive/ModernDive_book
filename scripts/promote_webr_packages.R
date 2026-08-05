# Watch webR's binary repo for wasm builds of the GitHub-only companion data
# packages and prune graduated ones from the shadow library.
#
# The shadow library (scripts/webr-shadow-library.R) exists because those
# packages can't be `webr::install()`ed from repo.r-wasm.org. The moment a
# package gets a wasm binary there, its shadow entry should be dropped so
# `library(<pkg>)` in the book's webR cells installs the real package instead
# of reading the .rds mirror. This script:
#
#   1. reads the watched package names from `pkg_data` in the shadow library
#      (so it needs no hand-maintained list and stops watching a package the
#      moment its entry is gone),
#   2. checks webR's binary PACKAGES index for them, and
#   3. removes graduated entries from `pkg_data` (fixing the trailing comma
#      and re-`parse()`ing the file as a syntax guard).
#
# It ALSO watches `pkg_extras`, but only to REPORT — never to prune. The two
# lists are not interchangeable:
#
#   * a `pkg_data` package is absent from webR altogether, so its entry can be
#     dropped the moment any wasm build appears — presence is the whole test;
#   * a `pkg_extras` package IS installed from webR, and its entry backfills
#     datasets that webR's (older) binary lacks. Presence therefore proves
#     nothing — `moderndive` has been on repo.r-wasm.org at 0.7.0 the entire
#     time the entry existed — so the test is a VERSION minimum. And even once
#     met, retiring the entry is not a lone edit: the `_quarto.yml` webR
#     version pin and the r-universe repo entry come with it, so a human does
#     it (see RELEASE-0.8.0-RUNBOOK.md step 9 in the moderndive repo).
#
# Flagged `pkg_extras` names are written to the file named by WEBR_FLAGGED_FILE
# (comma-separated, written even when empty) so the workflow can raise them
# separately. stdout stays reserved for the pruned `pkg_data` names.
#
# It deliberately does NOT touch instructor-solutions/common-errors.qmd —
# that page is tracked in the moderndive-instructor-resources repo (the
# copy here is gitignored); pruning its package list is a follow-up noted
# in the PR body.
#
# Run daily by .github/workflows/webr-watch.yml — which lives on the DEFAULT
# branch (v2, where scheduled workflows must be) but runs against a checkout
# of v2-quarto-html and opens a PR into v2-quarto-html. Prints the promoted
# names (comma-separated) to stdout and nothing when there is nothing to
# promote; all diagnostics go to stderr. Usage:
#
#   Rscript --vanilla scripts/promote_webr_packages.R [book_dir]
#
# --vanilla matters: it skips the repo's .Rprofile/renv activation, whose
# startup chatter would pollute stdout (the workflow captures stdout as the
# promoted-package list). Set WEBR_PACKAGES_URL to override the index
# location (used by tests).

args     <- commandArgs(trailingOnly = TRUE)
book_dir <- if (length(args) >= 1) args[[1]] else "."

shadow_path <- file.path(book_dir, "scripts", "webr-shadow-library.R")

# webR 0.6.0 (pinned under `webr:` in _quarto.yml) ships R 4.6.0, so its
# binary index lives under contrib/4.6. Bump this alongside the webR pin.
index_url <- Sys.getenv(
  "WEBR_PACKAGES_URL",
  "https://repo.r-wasm.org/bin/emscripten/contrib/4.6/PACKAGES"
)

lines <- readLines(shadow_path)

# Locate the pkg_data block and its `<name> = c(` ... `),` entries.
block_start <- grep("^  pkg_data <- list\\($", lines)
if (length(block_start) != 1) {
  stop("Expected exactly one `pkg_data <- list(` in ", shadow_path)
}
closes    <- grep("^  \\)$", lines)
block_end <- closes[closes > block_start][1]
if (is.na(block_end)) stop("Could not find the end of the pkg_data block")

entry_starts <- grep("^    [A-Za-z][A-Za-z0-9.]* = c\\($", lines)
entry_starts <- entry_starts[entry_starts > block_start & entry_starts < block_end]
watched      <- sub(" = c\\($", "", trimws(lines[entry_starts]))
message("Watching (from pkg_data): ", paste(watched, collapse = ", "))

# Same trick for `pkg_extras`, whose entries are `<name> = list(` rather than
# `= c(`. Report-only, so nothing here is ever spliced out.
extras_start <- grep("^  pkg_extras <- list\\($", lines)
watched_extras <- character()
if (length(extras_start) == 1) {
  extras_end <- closes[closes > extras_start][1]
  ex_starts  <- grep("^    [A-Za-z][A-Za-z0-9.]* = list\\($", lines)
  ex_starts  <- ex_starts[ex_starts > extras_start &
                          (is.na(extras_end) | ex_starts < extras_end)]
  watched_extras <- sub(" = list\\($", "", trimws(lines[ex_starts]))
}
message("Watching (from pkg_extras, report-only): ",
        paste(watched_extras, collapse = ", "))

# The minimum wasm version at which each `pkg_extras` entry stops being needed.
# Presence alone is meaningless here (see the header), so an entry with no
# minimum listed is never flagged rather than flagged immediately.
extras_min <- c(
  # 0.8.0 exports View() and ships envoy_flights,
  # early_january_2023_weather, and un_member_states_2024.
  moderndive      = "0.8.0",
  # season_counts was added in olympicAthletes 0.5.7.
  olympicAthletes = "0.5.7"
)

index <- tryCatch(readLines(index_url), error = function(e) {
  stop("Could not read the webR PACKAGES index at ", index_url, ": ",
       conditionMessage(e))
})
# Parse the DCF index once into name -> version. read.dcf rather than pairing
# `^Package:` / `^Version:` lines by position, because the version gate below
# depends on that pairing being right.
idx <- read.dcf(textConnection(index), fields = c("Package", "Version"))
available <- idx[, "Package"]
avail_ver <- stats::setNames(idx[, "Version"], idx[, "Package"])

# pkg_extras: flag only where webR's build meets the minimum.
flagged <- Filter(function(pkg) {
  if (!pkg %in% names(avail_ver) || is.na(avail_ver[[pkg]])) return(FALSE)
  if (!pkg %in% names(extras_min)) return(FALSE)
  utils::compareVersion(avail_ver[[pkg]], extras_min[[pkg]]) >= 0
}, watched_extras)
for (pkg in watched_extras) {
  have <- if (pkg %in% names(avail_ver)) avail_ver[[pkg]] else "absent"
  want <- if (pkg %in% names(extras_min)) extras_min[[pkg]] else "(no minimum)"
  message(sprintf("  pkg_extras %-16s webR has %-8s needs %s%s",
                  pkg, have, want, if (pkg %in% flagged) "  <- READY" else ""))
}
flag_file <- Sys.getenv("WEBR_FLAGGED_FILE", "")
if (nzchar(flag_file)) {
  writeLines(paste(flagged, collapse = ","), flag_file)
}

promoted <- intersect(watched, available)
if (length(promoted) == 0) {
  message("No watched packages on webR yet.")
  quit(save = "no", status = 0)
}
message("On webR now: ", paste(promoted, collapse = ", "))

# Drop each promoted entry: from its `<pkg> = c(` line through the next
# `),` / `)` line at the same depth.
drop <- integer()
for (pkg in promoted) {
  start <- entry_starts[watched == pkg]
  ends  <- grep("^    \\),?$", lines)
  end   <- ends[ends > start][1]
  drop  <- c(drop, start:end)
}
lines <- lines[-drop]

# If the removed entry was the last one, the previous entry now ends with a
# trailing `),` right before the block's `  )` — invalid R. Fix it.
block_start <- grep("^  pkg_data <- list\\($", lines)
closes      <- grep("^  \\)$", lines)
block_end   <- closes[closes > block_start][1]
if (lines[block_end - 1] == "    ),") lines[block_end - 1] <- "    )"

# Syntax guard: refuse to write a file R can't parse. (invisible(): the
# parsed expression must not print — stdout is reserved for the result.)
invisible(tryCatch(parse(text = lines), error = function(e) {
  stop("Edited ", shadow_path, " no longer parses — aborting: ",
       conditionMessage(e))
}))
writeLines(lines, shadow_path)
message("Pruned pkg_data entries in ", shadow_path)

cat(paste(promoted, collapse = ","))
