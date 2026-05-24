#!/usr/bin/env Rscript
# Exercise lexicon audit.
#
# Extends the "no new terms in assessments" rule (already enforced in chapter
# prose via scripts/pedagogy_scans.R) to the *exercise YAMLs*. For each
# exercise prompt + webr field in `exercises/NN.yml`, checks:
#
#   1. Does it mention an R function (e.g., `foo()`) that is introduced
#      LATER than chapter N? Flag.
#   2. Does it mention a glossary term whose intro chapter is > N? Flag.
#   3. Does it mention a dataset (`olympic_athletes`, `planets`, etc.) that
#      isn't introduced until a later chapter, per the dataset-cadence map?
#
# Exceptions:
#   - Exercises in the "Extensions" group are exempt (Extensions are
#     deliberately allowed to introduce concepts beyond what the chapter
#     covers — that's their whole purpose, per the existing convention).
#   - Carry-over caveats (prompt text containing "Carried over from
#     Chapter X" or "from Chs Y–Z") are also exempt — they're an
#     explicit, deliberate signal.
#
# Output: per-flag detail. Exits non-zero on any non-exempt violation.

suppressPackageStartupMessages({
  library(yaml)
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

# Dataset cadence (mirrors project_exercise_system memory map)
dataset_intro <- list(
  olympic_athletes = 1L, medal_table = 1L, editions = 1L,
  episodes        = 3L,
  bob_ross        = 4L,
  planets         = 6L, stars = 6L,
  volcanoes       = 7L, eruptions = 7L, events = 7L,
  exoplanets      = 6L
)

# Glossary term -> intro chapter (reuse the helper from pedagogy_scans.R)
load_glossary_intro <- function() {
  gloss <- readLines("96-glossary.qmd", warn = FALSE)
  text <- paste(gloss, collapse = "\n")
  # Parse `## Term {#sec-gloss-X .unnumbered}` + body containing `See @sec-Y.`
  entries <- str_match_all(text,
    "##\\s+([^\\n{]+?)\\s*\\{#sec-gloss-[^}]+\\}([^#]*?)(?=\\n##\\s|$)")[[1]]
  out <- list()
  for (i in seq_len(nrow(entries))) {
    term <- tolower(trimws(gsub("`|\\([^)]*\\)", "", entries[i, 2])))
    body <- entries[i, 3]
    anchor <- str_match(body, "See @(sec-[A-Za-z0-9_-]+)")[1, 2]
    if (is.na(anchor)) next
    # Look up the anchor → chapter number by scanning chapter qmds for the
    # `{#anchor}` declaration. Build the anchor→chapter map once.
    out[[term]] <- anchor
  }
  out
}
gloss_term_to_anchor <- load_glossary_intro()

# Anchor -> chapter number map
anchor_to_chap <- list()
chap_files <- sort(list.files(".", pattern = "^[0-9]+-.*\\.qmd$"))
for (f in chap_files) {
  m <- str_match(f, "^([0-9]+)")
  if (is.na(m[1, 2])) next
  chap <- as.integer(m[1, 2])
  lines <- readLines(f, warn = FALSE)
  for (l in lines) {
    matches <- str_extract_all(l, "\\{#sec-[A-Za-z0-9_-]+")[[1]]
    for (mt in matches) {
      anchor <- sub("^\\{#", "", mt)
      anchor_to_chap[[anchor]] <- chap
    }
  }
}

# Function -> first code-chunk introduction chapter (reuse pedagogy approach)
function_intro <- list()
ignore_funs <- c("c", "list", "sum", "mean", "median", "min", "max", "sd", "var",
                 "abs", "round", "sqrt", "log", "exp", "factor", "names", "length",
                 "nrow", "ncol", "dim", "head", "tail", "print", "cat", "paste",
                 "paste0", "sprintf", "is.na", "if", "for", "while", "function",
                 "return", "seq", "seq_len", "seq_along", "rep", "is.null",
                 "library", "require", "set.seed", "options", "TRUE", "FALSE",
                 "data.frame", "tibble", "log10", "log2", "as.numeric",
                 "as.integer", "as.character", "as.factor", "as.logical")
in_chunk <- FALSE
chunk_visible <- TRUE
record_fns <- function(line, chap) {
  fns <- unlist(str_extract_all(line, "\\b[A-Za-z_][A-Za-z_0-9.]*(?=\\()"))
  for (fn in fns) {
    if (fn %in% ignore_funs) next
    if (is.null(function_intro[[fn]])) function_intro[[fn]] <<- chap
  }
}
for (f in chap_files) {
  m <- str_match(f, "^([0-9]+)")
  chap <- as.integer(m[1, 2])
  if (is.na(chap)) next
  in_chunk <- FALSE
  chunk_visible <- TRUE
  for (l in readLines(f, warn = FALSE)) {
    if (!in_chunk && grepl("^```\\{", l)) {
      in_chunk <- TRUE
      chunk_visible <- !grepl("echo\\s*=\\s*FALSE|include\\s*=\\s*FALSE", l)
      next
    }
    if (in_chunk && grepl("^```\\s*$", l)) {
      in_chunk <- FALSE
      chunk_visible <- TRUE
      next
    }
    if (in_chunk && grepl("^#\\|", l)) {
      if (grepl("echo:\\s*false|include:\\s*false", l, ignore.case = TRUE)) {
        chunk_visible <- FALSE
      }
      next
    }
    # Two valid intro paths:
    #   (a) visible code chunks (echo not FALSE)
    #   (b) backticked inline code in prose (e.g., `labs()`, `get_regression_table()`)
    # Either way, students have *encountered* the function name in the chapter.
    if (in_chunk && chunk_visible) {
      record_fns(l, chap)
    } else if (!in_chunk) {
      for (code in str_extract_all(l, "`[^`]+`")[[1]]) record_fns(code, chap)
    }
  }
}

# Walk every exercise prompt + webr, look for forward references
flags <- list()
for (chap in 1:11) {
  yml <- sprintf("exercises/%02d.yml", chap)
  if (!file.exists(yml)) next
  d <- tryCatch(yaml::read_yaml(yml), error = function(e) NULL)
  if (is.null(d) || !length(d$exercises)) next

  for (ex in d$exercises) {
    # Exempt: Extensions group
    if (!is.null(ex$group) && identical(ex$group, "Extensions")) next
    # Exempt: prompt mentions "Carried over from"
    prompt_text <- paste(ex$prompt %||% "", ex$webr %||% "", sep = "\n")
    if (grepl("Carried over from", prompt_text, ignore.case = TRUE)) next

    # 1. Function refs (`foo()` in backticks)
    fn_refs <- unique(unlist(str_extract_all(prompt_text, "`[A-Za-z_][A-Za-z_0-9.]*\\(\\)?`")))
    for (raw in fn_refs) {
      fn <- sub("^`", "", sub("\\(\\)?`$", "", raw))
      if (fn %in% ignore_funs) next
      intro <- function_intro[[fn]]
      if (!is.null(intro) && intro > chap) {
        flags[[length(flags) + 1]] <- list(
          chap = chap, ex = ex$ex_num, kind = "function", item = fn,
          intro_chap = intro,
          context = substr(prompt_text, 1, 140))
      }
    }

    # 2. Glossary term refs
    pt_lower <- tolower(prompt_text)
    for (term in names(gloss_term_to_anchor)) {
      anchor <- gloss_term_to_anchor[[term]]
      intro_chap <- anchor_to_chap[[anchor]]
      if (is.null(intro_chap) || intro_chap <= chap) next
      # Word-boundary match
      pat <- paste0("\\b", str_replace_all(term, " ", "\\\\s+"), "\\b")
      if (grepl(pat, pt_lower, perl = TRUE)) {
        flags[[length(flags) + 1]] <- list(
          chap = chap, ex = ex$ex_num, kind = "glossary", item = term,
          intro_chap = intro_chap,
          context = substr(prompt_text, 1, 140))
      }
    }

    # 3. Dataset refs — only flag when the dataset name appears as a CODE
    # SYMBOL (backticks, library()/data() call, or used in code as a data
    # object: `events,`, `events %>%`, `events$col`, `events[`). String
    # literals like `labs(y = "medal events")` and prose mentions like
    # "medal events" should NOT trigger the flag.
    webr_only <- ex$webr %||% ""
    # Strip string literals from the webr field before symbol matching so
    # `"medal events"` doesn't get treated as a reference to the `events`
    # dataset.
    webr_code <- gsub('"[^"]*"', "", webr_only)
    webr_code <- gsub("'[^']*'", "", webr_code)
    for (ds in names(dataset_intro)) {
      intro_chap <- dataset_intro[[ds]]
      if (intro_chap <= chap) next
      patterns <- c(
        paste0("`", ds, "`"),                          # `events`
        paste0("\\blibrary\\(\\s*", ds, "\\s*[,)]"),    # library(events)
        paste0("\\bdata\\(\\s*", ds, "\\s*[,)]")        # data(events)
      )
      hit_code <- any(sapply(patterns, function(p) grepl(p, prompt_text)))
      # In webr code, require dataset name to appear as a symbol followed
      # by a code-relevant punctuation/operator (i.e., used as a data var).
      symbol_pat <- paste0("\\b", ds, "\\b\\s*(\\$|\\[|,|\\)|%>%|\\|>)")
      hit_webr <- grepl(symbol_pat, webr_code)
      if (hit_code || hit_webr) {
        flags[[length(flags) + 1]] <- list(
          chap = chap, ex = ex$ex_num, kind = "dataset", item = ds,
          intro_chap = intro_chap,
          context = substr(prompt_text, 1, 140))
      }
    }
  }
}

cat(sprintf("Exercises scanned across chapters 1–11. Forward-reference flags: %d\n\n",
            length(flags)))
if (length(flags)) {
  by_chap <- split(flags, sapply(flags, function(x) x$chap))
  for (chap in names(by_chap)) {
    cat(sprintf("=== Chapter %s ===\n", chap))
    for (fl in by_chap[[chap]]) {
      cat(sprintf("  EX%s.%s: forward %s `%s` (intro Ch %d)\n    %s\n",
                  chap, fl$ex, fl$kind, fl$item, fl$intro_chap, fl$context))
    }
  }
  quit(status = 1)
}
cat("No forward-reference violations in exercise YAMLs.\n")
