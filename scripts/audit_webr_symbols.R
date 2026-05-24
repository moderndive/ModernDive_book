#!/usr/bin/env Rscript
# Static webR audit: catch undefined data-symbol references in webR cells.
#
# webR cells (`{webr-r}` in chapter qmds, `webr:` fields in exercises/*.yml)
# run in a separate browser-side R session. If a cell references a data frame
# or chapter-derived object that the chapter's `#| context: setup` cell
# doesn't load/define, the student gets "object 'X' not found" — and prior
# to this audit, nothing in CI caught it. The five chapters' `bball`,
# `UN_data_chN`, `planets_lite`, `dem_score`, `bob_long` bugs (NEWS 2.8.18)
# were all caught by an earlier version of this script.
#
# Detects:
#   - Bare data-frame references in {webr-r} cells (qmds + appendices)
#   - Same in exercises/*.yml `webr:` fields
#
# Considers a symbol "defined" if it is:
#   - In webR's preloaded packages (see PRELOADED_DATA below)
#   - Loaded by `library(<github-only-pkg>)` in the chapter setup (shadow
#     library() maps olympicAthletes -> olympic_athletes/editions/medal_table,
#     steves -> episodes, exoplanets -> planets, volcanoes -> eruptions/volcanoes)
#   - Defined as `X <- ...` in the chapter setup cell
#   - Defined as `X <- ...` earlier in the same cell

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

`%||%` <- function(x, y) if (is.null(x)) y else x

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

# Datasets webR exposes via the preloaded packages in _quarto.yml's webr:
# packages list, plus base R built-ins. Keep in sync if you add a package.
PRELOADED_DATA <- c(
  # moderndive (preloaded) — the ones actually referenced in the book
  "mythbusters_yawn", "pennies_sample", "pennies", "promotions", "saratoga_houses",
  "house_prices", "amazon_books", "movies_sample", "evals", "gapminder",
  "envoy_flights", "early_january_2023_weather", "bowl", "un_member_states_2024",
  "almonds_bowl", "almonds_sample", "tactile_prop_red", "MA_schools",
  # nycflights23 (preloaded)
  "flights", "airlines", "airports", "planes", "weather",
  # fivethirtyeight (preloaded)
  "bob_ross", "fandango", "hate_crimes", "bechdel", "flying", "bad_drivers",
  # dplyr/ggplot/base built-ins
  "starwars", "storms", "band_members", "band_instruments", "iris", "mtcars",
  "diamonds", "mpg", "economics", "midwest", "msleep", "txhousing",
  "AirPassengers", "CO2", "Titanic", "USArrests"
)

# Datasets the shadow library() loads when you call library(<pkg>) in webR.
SHADOW_MAP <- list(
  olympicAthletes = c("olympic_athletes", "editions", "medal_table"),
  steves          = c("episodes"),
  exoplanets      = c("planets"),
  volcanoes       = c("eruptions", "volcanoes")
)

# Common false-positive symbols (function names, common locals, keywords)
IGNORE_SYMS <- c(
  "data", "na", "TRUE", "FALSE", "NA", "NULL", "cat", "print", "message",
  "x", "y", "z", "i", "j", "k", "n", "m", "tmp", "res", "result",
  "lm", "glm", "aov", "function", "if", "else", "for", "while", "return",
  "filter", "aes", "across", "replicate", "sort", "mutate", "select",
  "group_by", "summarize", "summarise", "arrange", "count", "rename",
  "head", "tail", "nrow", "ncol", "summary", "str", "glimpse"
)

# Symbols that look like first arg to a verb/function but are really
# column names (regex captures over-match on column refs).
extract_columns_in_yml <- function(yml_path) {
  if (!file.exists(yml_path)) return(character(0))
  data <- tryCatch(yaml::read_yaml(yml_path), error = function(e) NULL)
  if (is.null(data)) return(character(0))
  items <- if (is.list(data) && !is.null(data$exercises)) data$exercises else data
  cols <- character(0)
  for (ex in items) {
    if (!is.list(ex)) next
    txt <- paste(unlist(lapply(ex, as.character)), collapse = " ")
    # x$colname and y$colname references
    m <- str_match_all(txt, "\\$\\s*([A-Za-z_][A-Za-z0-9_]*)")[[1]]
    if (nrow(m) > 0) cols <- c(cols, m[, 2])
    # aes(x = colname, y = colname)
    m2 <- str_match_all(txt, "\\baes\\([^)]*[xy]\\s*=\\s*([A-Za-z_][A-Za-z0-9_]*)")[[1]]
    if (nrow(m2) > 0) cols <- c(cols, m2[, 2])
  }
  unique(cols)
}

# Pull bare data-symbol references out of a chunk of R code
find_symbols <- function(code) {
  patterns <- c(
    "\\bdata\\s*=\\s*([A-Za-z_][A-Za-z0-9_]*)",      # data = X
    "(?m)^([A-Za-z_][A-Za-z0-9_]*)\\s*(?:\\|>|%>%)", # X |> ...
    "\\b(?:glimpse|head|nrow|ncol|str|summary|View|print|dim|class|tidy_summary)\\(\\s*([A-Za-z_][A-Za-z0-9_]*)"
  )
  syms <- character(0)
  for (pat in patterns) {
    m <- str_match_all(code, pat)[[1]]
    if (nrow(m) > 0) syms <- c(syms, m[, 2])
  }
  unique(syms)
}

# Find X <- or X = assignments at line starts
find_assigned <- function(code) {
  m <- str_match_all(code, "(?m)^\\s*([A-Za-z_][A-Za-z0-9_]*)\\s*(?:<-|=(?!=))")[[1]]
  if (nrow(m) > 0) unique(m[, 2]) else character(0)
}

# What does a chapter's setup cell make available?
chapter_loaded <- function(qmd_path) {
  txt <- paste(readLines(qmd_path, warn = FALSE), collapse = "\n")
  m <- str_match(txt,
                 "(?s)```\\{webr-r\\}\\s*\n#\\|\\s*context:\\s*setup(.*?)```")
  if (is.na(m[1, 1])) return(character(0))
  body <- m[1, 2]
  loaded <- character(0)
  # library(<pkg>) — shadow-mapped datasets
  libs <- str_match_all(body, "\\blibrary\\(\\s*([A-Za-z_][A-Za-z0-9_]*)")[[1]]
  if (nrow(libs) > 0) {
    for (pkg in libs[, 2]) {
      if (pkg %in% names(SHADOW_MAP)) loaded <- c(loaded, SHADOW_MAP[[pkg]])
    }
  }
  # Anything assigned at top level in setup
  loaded <- c(loaded, find_assigned(body))
  unique(loaded)
}

# Pull all {webr-r} cells (with optional opts) from a qmd
extract_webr_cells <- function(qmd_path) {
  txt <- paste(readLines(qmd_path, warn = FALSE), collapse = "\n")
  m <- str_match_all(txt, "(?s)```\\{webr-r[^}]*\\}(.*?)```")[[1]]
  if (nrow(m) == 0) return(character(0))
  m[, 2]
}

is_setup_cell <- function(cell_body) {
  str_detect(substr(cell_body, 1, 100), "context:\\s*setup")
}

# ---- Scan chapter qmds ----
qmd_files <- sort(list.files(".", pattern = "^[0-9]+.*\\.qmd$"))
qmd_files <- c(qmd_files, "92-appendixB.qmd")
qmd_files <- unique(qmd_files)
qmd_files <- qmd_files[file.exists(qmd_files)]

cat("=== Static webR symbol audit ===\n")
cat("Scanning", length(qmd_files), "qmd files\n\n")

total_flags <- 0

for (qmd in qmd_files) {
  loaded <- c(chapter_loaded(qmd), PRELOADED_DATA)
  # Column-name false-positive filter: pull cols from matching exercises yml
  chap_num <- str_match(qmd, "^([0-9]+)")[1, 2]
  yml_path <- if (!is.na(chap_num)) paste0("exercises/", chap_num, ".yml") else NA
  cols <- if (!is.na(yml_path)) extract_columns_in_yml(yml_path) else character(0)

  cells <- extract_webr_cells(qmd)
  flags_here <- list()
  for (i in seq_along(cells)) {
    cell <- cells[i]
    if (is_setup_cell(cell)) next
    local <- find_assigned(cell)
    syms <- find_symbols(cell)
    for (s in syms) {
      if (s %in% local || s %in% loaded || s %in% cols || s %in% IGNORE_SYMS) next
      flags_here[[length(flags_here) + 1]] <- list(cell_idx = i, sym = s)
    }
  }
  if (length(flags_here) > 0) {
    cat("⚠ ", qmd, "\n", sep = "")
    cat("    setup defines: ", paste(setdiff(loaded, PRELOADED_DATA), collapse = ", "), "\n", sep = "")
    for (f in flags_here) {
      cat("    UNDEFINED  ", f$sym, "  (cell ", f$cell_idx, ")\n", sep = "")
      total_flags <- total_flags + 1
    }
  }
}

# ---- Scan exercises/*.yml webr: fields ----
yml_files <- sort(list.files("exercises", pattern = "\\.yml$", full.names = TRUE))
cat("\nScanning", length(yml_files), "exercise yml files\n\n")

for (yml in yml_files) {
  data <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(data)) next
  items <- if (is.list(data) && !is.null(data$exercises)) data$exercises else data
  if (!is.list(items)) next
  # Chapter number from filename
  chap_num <- str_match(basename(yml), "^([0-9]+)")[1, 2]
  qmd_match <- list.files(".", pattern = paste0("^", chap_num, "-.*\\.qmd$"))
  loaded <- if (length(qmd_match) > 0) {
    c(chapter_loaded(qmd_match[1]), PRELOADED_DATA)
  } else PRELOADED_DATA
  cols <- extract_columns_in_yml(yml)
  flags_here <- list()
  for (ex in items) {
    if (!is.list(ex)) next
    webr <- ex$webr
    if (is.null(webr) || nchar(webr) == 0) next
    local <- find_assigned(webr)
    syms <- find_symbols(webr)
    for (s in syms) {
      if (s %in% local || s %in% loaded || s %in% cols || s %in% IGNORE_SYMS) next
      flags_here[[length(flags_here) + 1]] <- list(ex_num = ex$ex_num %||% "?", sym = s)
    }
  }
  if (length(flags_here) > 0) {
    cat("⚠ ", yml, "\n", sep = "")
    for (f in flags_here) {
      cat("    UNDEFINED  ", f$sym, "  (ex_num=", f$ex_num, ")\n", sep = "")
      total_flags <- total_flags + 1
    }
  }
}

cat("\n========================\n")
cat("Total flags:", total_flags, "\n")
if (total_flags > 0) quit(status = 1)
cat("✓ webR symbol audit clean\n")
