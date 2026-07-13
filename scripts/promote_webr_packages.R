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

index <- tryCatch(readLines(index_url), error = function(e) {
  stop("Could not read the webR PACKAGES index at ", index_url, ": ",
       conditionMessage(e))
})
available <- sub("^Package: ", "", grep("^Package: ", index, value = TRUE))

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
