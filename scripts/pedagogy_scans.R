#!/usr/bin/env Rscript
# Concept-introduction & forward-reference scans for ModernDive.

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

# Order matters — chapter 1 is the earliest, 11 latest.
chap_files <- sprintf(c(
  "01-getting-started.qmd", "02-visualization.qmd", "03-wrangling.qmd",
  "04-tidy.qmd",            "05-regression.qmd",    "06-multiple-regression.qmd",
  "07-sampling.qmd",        "08-confidence-intervals.qmd",
  "09-hypothesis-testing.qmd","10-inference-for-regression.qmd",
  "11-tell-your-story-with-data.qmd"
))
chap_num <- 1:11
names(chap_files) <- chap_num

read_chap <- function(f) readLines(f, warn = FALSE)
chap_lines <- lapply(chap_files, read_chap)
names(chap_lines) <- chap_num

# --- Helper: classify each line as prose vs code-chunk vs other ---
classify_lines <- function(lines) {
  # Code chunks are between ```{...} and ```
  in_chunk <- FALSE
  state <- character(length(lines))
  for (i in seq_along(lines)) {
    l <- lines[i]
    if (!in_chunk && grepl("^```\\{", l)) {
      in_chunk <- TRUE
      state[i] <- "chunk_fence"
    } else if (in_chunk && grepl("^```\\s*$", l)) {
      in_chunk <- FALSE
      state[i] <- "chunk_fence"
    } else if (in_chunk) {
      state[i] <- "code"
    } else {
      state[i] <- "prose"
    }
  }
  state
}

chap_state <- lapply(chap_lines, classify_lines)
names(chap_state) <- chap_num

# --- Section anchor → chapter map ---
# Find every {#sec-X} in any chapter file, record its chapter.
sec_anchor_map <- list()
for (n in chap_num) {
  lines <- chap_lines[[as.character(n)]]
  matches <- str_extract_all(lines, "\\{#(sec-[A-Za-z0-9_.-]+)")
  for (i in seq_along(matches)) {
    if (length(matches[[i]]) > 0) {
      for (m in matches[[i]]) {
        anc <- sub("^\\{#", "", m)
        sec_anchor_map[[anc]] <- n
      }
    }
  }
}
# Also include glossary anchors (chapter "G")
gloss_lines <- readLines("96-glossary.qmd", warn = FALSE)
gloss_anchors <- str_extract_all(gloss_lines, "\\{#(sec-[A-Za-z0-9_.-]+)")
for (m in unlist(gloss_anchors)) {
  if (is.na(m)) next
  anc <- sub("^\\{#", "", m)
  if (is.null(sec_anchor_map[[anc]])) sec_anchor_map[[anc]] <- "G"
}

cat(sprintf("Found %d unique section anchors across the book.\n",
            length(sec_anchor_map)))

# Track which chapter+line is in which section (to flag refs in Conclusion/Exercises)
section_at_line <- function(lines) {
  cur <- ""
  out <- character(length(lines))
  for (i in seq_along(lines)) {
    if (grepl("^## ", lines[i])) cur <- trimws(sub("\\{.*$", "", sub("^## ", "", lines[i])))
    out[i] <- cur
  }
  out
}
chap_section <- lapply(chap_lines, section_at_line)
names(chap_section) <- chap_num

# ============================================================
# SCAN 3: Cross-chapter dependency audit (run first, simplest)
# ============================================================
cat("\n\n========== SCAN 3: CROSS-CHAPTER DEPENDENCIES ==========\n")
cat("Flag: chapter N's prose references @sec-X where X lives in chapter M > N\n")
cat("(forward dependency — material the reader hasn't seen yet)\n\n")

# A "foreshadowing context" is fine: ## Conclusion / What's to come / Exercises Extensions /
# or text that begins with explicit forward-looking phrases.
benign_sections <- c("Conclusion", "Exercises", "Quick checks", "Concluding remarks",
                     "Summary and final remarks", "What's to come?", "What's to come",
                     "Additional resources", "Summary of statistical inference")
benign_section_pat <- "Conclusion|Exercises|Quick checks|Concluding remarks|Final remarks|What's to come|Additional resources|Summary of"

foreshadow_pat <- "we'?ll see|we'?ll explore|we'?ll cover|we'?ll revisit|we'?ll learn|will be (covered|discussed|introduced)|to be discussed|in (a )?later chapter|in upcoming|in @sec-|Starting (with|in)|preview of|We'?re next|We'?ll now move|leave .* until after|Once we have covered|coming up|See @sec-"

forward_refs <- list()
for (n in chap_num) {
  lines  <- chap_lines[[as.character(n)]]
  states <- chap_state[[as.character(n)]]
  sections <- chap_section[[as.character(n)]]
  for (i in seq_along(lines)) {
    if (states[i] != "prose") next
    refs <- str_extract_all(lines[i], "@(sec-[A-Za-z0-9_-]+)")[[1]]
    if (!length(refs)) next
    in_benign_section <- grepl(benign_section_pat, sections[i], ignore.case = TRUE)
    is_foreshadow <- grepl(foreshadow_pat, lines[i], ignore.case = TRUE)
    for (r in refs) {
      anc <- sub("^@", "", r)
      anc <- sub("[.]+$", "", anc)
      target_chap <- sec_anchor_map[[anc]]
      if (is.null(target_chap)) next
      if (target_chap == "G") next
      if (suppressWarnings(as.integer(target_chap)) > n) {
        forward_refs[[length(forward_refs) + 1]] <- list(
          from_chap = n,
          line = i,
          target_chap = target_chap,
          anchor = anc,
          section = sections[i],
          in_benign_section = in_benign_section,
          is_foreshadow = is_foreshadow,
          context = lines[i]
        )
      }
    }
  }
}

cat(sprintf("Total forward @sec-* references: %d\n", length(forward_refs)))
benign_ct <- sum(sapply(forward_refs, function(x) x$in_benign_section || x$is_foreshadow))
flag_ct <- length(forward_refs) - benign_ct
cat(sprintf("  - %d in Conclusion/Exercises/foreshadowing prose (benign)\n", benign_ct))
cat(sprintf("  - %d in MID-CHAPTER prose without foreshadowing language (FLAGGED)\n\n", flag_ct))

if (length(forward_refs)) {
  cat("--- FLAGGED forward references (mid-chapter, non-foreshadowing) ---\n")
  for (fr in forward_refs) {
    if (fr$in_benign_section || fr$is_foreshadow) next
    snippet <- substr(trimws(fr$context), 1, 200)
    cat(sprintf("  Ch %s L%d (in '%s') -> Ch %s (@%s):\n    %s\n",
                fr$from_chap, fr$line, fr$section,
                fr$target_chap, fr$anchor, snippet))
  }
  cat("\n--- Benign (Conclusion/foreshadowing) forward-ref counts by pair ---\n")
  pair_counts <- table(
    sapply(forward_refs, function(x) {
      if (x$in_benign_section || x$is_foreshadow)
        sprintf("Ch %s -> Ch %s", x$from_chap, x$target_chap)
      else NA
    })
  )
  print(sort(pair_counts[!is.na(names(pair_counts))], decreasing = TRUE))
}

# ============================================================
# SCAN 1: First-use lexicon (glossary-driven)
# ============================================================
cat("\n\n========== SCAN 1: FIRST-USE LEXICON ==========\n")
cat("For each glossary term, find its 'See @sec-X' chapter (introduction chapter),\n")
cat("then flag prose mentions of the term in any EARLIER chapter.\n\n")

# Parse glossary: each term is a `## Term {#sec-gloss-X .unnumbered}` heading
# followed by a definition paragraph that often ends with "See @sec-Y."
gloss_text <- paste(gloss_lines, collapse = "\n")
entries <- str_match_all(
  gloss_text,
  "##\\s+([^\\n{]+?)\\s*\\{#sec-gloss-[^}]+\\}([^#]*?)(?=\\n##\\s|$)"
)[[1]]
colnames(entries) <- c("full", "term", "body")
glossary <- data.frame(term = trimws(entries[, "term"]),
                       body = entries[, "body"],
                       stringsAsFactors = FALSE)
# Extract "See @sec-X" from body to determine introduction chapter
glossary$intro_anchor <- sapply(glossary$body, function(b) {
  m <- str_match(b, "See @(sec-[A-Za-z0-9_-]+)")[1, 2]
  if (is.na(m)) NA_character_ else sub("[.]+$", "", m)
})
glossary$intro_chap <- sapply(glossary$intro_anchor, function(a) {
  if (is.na(a)) return(NA)
  v <- sec_anchor_map[[a]]
  if (is.null(v)) NA else v
})

# Clean term for matching: lowercase, strip parenthetical/backticks
glossary$match_term <- sapply(glossary$term, function(t) {
  t <- sub("\\s*\\(.*$", "", t)
  t <- gsub("`", "", t)
  trimws(tolower(t))
})

cat("Glossary entries with intro chapters:\n")
print(glossary[, c("term", "match_term", "intro_chap")], row.names = FALSE)

# For each term, search earlier chapters' prose for the term.
flag_lexicon <- list()
for (k in seq_len(nrow(glossary))) {
  term <- glossary$match_term[k]
  intro <- suppressWarnings(as.integer(glossary$intro_chap[k]))
  if (is.na(intro) || intro <= 1) next
  pattern <- paste0("\\b", str_replace_all(term, " ", "[ -]"), "\\b")
  for (n in seq_len(intro - 1)) {
    lines  <- chap_lines[[as.character(n)]]
    states <- chap_state[[as.character(n)]]
    prose_idx <- which(states == "prose")
    hits <- prose_idx[str_detect(tolower(lines[prose_idx]), pattern)]
    for (i in hits) {
      flag_lexicon[[length(flag_lexicon) + 1]] <- list(
        term = glossary$term[k],
        intro_chap = intro,
        used_in_chap = n,
        line = i,
        context = lines[i]
      )
    }
  }
}

cat(sprintf("\nTotal first-use lexicon flags: %d\n", length(flag_lexicon)))
if (length(flag_lexicon)) {
  by_term <- split(flag_lexicon, sapply(flag_lexicon, function(x) x$term))
  cat("\nFlags per term (term :: intro_chap :: # earlier-chapter hits):\n")
  for (term in names(by_term)) {
    intro <- by_term[[term]][[1]]$intro_chap
    cat(sprintf("  %-30s intro=Ch %d  hits=%d\n", term, intro, length(by_term[[term]])))
  }
  cat("\nDetailed flags (capped at 60):\n")
  show_n <- min(60, length(flag_lexicon))
  for (i in seq_len(show_n)) {
    fl <- flag_lexicon[[i]]
    snippet <- substr(trimws(fl$context), 1, 140)
    cat(sprintf("  [%s] used Ch %d L%d (intro=Ch %d): %s\n",
                fl$term, fl$used_in_chap, fl$line, fl$intro_chap, snippet))
  }
}

# ============================================================
# SCAN 2: Function-introduction map
# ============================================================
cat("\n\n========== SCAN 2: FUNCTION-INTRODUCTION MAP ==========\n")
cat("For each function used in a code chunk, find its first-introduction chapter,\n")
cat("then flag PROSE mentions (in backticks) in EARLIER chapters.\n\n")

# Functions to ignore (universal/syntactic):
ignore_funs <- c(
  "c", "list", "vector", "matrix", "data.frame", "tibble", "as.numeric",
  "as.integer", "as.character", "as.factor", "as.logical", "as.data.frame",
  "sum", "mean", "median", "min", "max", "sd", "var", "abs", "round", "sqrt",
  "exp", "log", "log10", "log2", "factor", "names", "length", "nrow", "ncol",
  "dim", "head", "tail", "print", "cat", "paste", "paste0", "sprintf", "format",
  "is.na", "ifelse", "if", "for", "while", "function", "return", "seq",
  "seq_len", "seq_along", "rep", "is.null", "T", "F", "TRUE", "FALSE",
  "library", "require", "set.seed", "source", "options", "knitr", "include_graphics",
  "kbl", "kable", "kable_styling", "knit_child", "ifelse", "do.call", "match.arg"
)

# Extract function calls per chapter from code lines
fn_intro_code  <- list()  # function -> first chapter it's used in a code chunk
fn_intro_prose <- list()  # function -> first chapter it's mentioned in prose backticks

for (n in chap_num) {
  lines  <- chap_lines[[as.character(n)]]
  states <- chap_state[[as.character(n)]]
  for (i in which(states == "code")) {
    fns <- unlist(str_extract_all(lines[i], "\\b[A-Za-z_][A-Za-z_0-9.]*(?=\\()"))
    for (fn in fns) {
      if (fn %in% ignore_funs) next
      if (is.null(fn_intro_code[[fn]])) fn_intro_code[[fn]] <- n
    }
  }
  for (i in which(states == "prose")) {
    matches <- unlist(str_extract_all(lines[i], "`[A-Za-z_][A-Za-z_0-9.]*\\(\\)?`"))
    if (!length(matches)) next
    fns <- sub("^`", "", sub("\\(\\)?`$", "", matches))
    for (fn in fns) {
      if (fn %in% ignore_funs) next
      if (is.null(fn_intro_prose[[fn]])) fn_intro_prose[[fn]] <- n
    }
  }
}

fn_uses_in_prose <- list()  # function -> list of (chap, line, context)
fn_intro <- fn_intro_code  # for back-compat with the original flag-detection loop below

# Now scan prose for backticked function refs `foo()`
for (n in chap_num) {
  lines  <- chap_lines[[as.character(n)]]
  states <- chap_state[[as.character(n)]]
  for (i in which(states == "prose")) {
    matches <- unlist(str_extract_all(lines[i], "`[A-Za-z_][A-Za-z_0-9.]*\\(\\)?`"))
    if (!length(matches)) next
    fns <- sub("^`", "", sub("\\(\\)?`$", "", matches))
    for (fn in fns) {
      if (fn %in% ignore_funs) next
      first <- fn_intro[[fn]]
      if (!is.null(first) && first > n) {
        # Used in prose in ch n but first code-introduced in ch first > n: forward use
        if (is.null(fn_uses_in_prose[[fn]])) fn_uses_in_prose[[fn]] <- list()
        fn_uses_in_prose[[fn]][[length(fn_uses_in_prose[[fn]]) + 1]] <- list(
          chap = n, line = i, context = lines[i], intro_chap = first
        )
      }
    }
  }
}

cat("---- Functions where prose-intro precedes code-intro (potential forward refs in prose) ----\n")
prose_before_code <- character()
for (fn in names(fn_intro_prose)) {
  p <- fn_intro_prose[[fn]]
  c <- fn_intro_code[[fn]]
  if (!is.null(p) && !is.null(c) && p < c) {
    prose_before_code <- c(prose_before_code,
      sprintf("  %-25s prose-intro=Ch %d  code-intro=Ch %d", fn, p, c))
  }
}
if (length(prose_before_code)) {
  cat(paste(prose_before_code, collapse = "\n"), "\n")
} else {
  cat("  (none)\n")
}

cat("\nFunctions with forward prose uses: %d\n", sprintf("%d", length(fn_uses_in_prose)))
if (length(fn_uses_in_prose)) {
  cat("\nBy function (fn :: intro_chap :: # forward prose uses):\n")
  ord <- order(sapply(fn_uses_in_prose, function(x) x[[1]]$intro_chap))
  for (fn in names(fn_uses_in_prose)[ord]) {
    uses <- fn_uses_in_prose[[fn]]
    cat(sprintf("  %-25s intro=Ch %d  uses=%d\n", fn, uses[[1]]$intro_chap, length(uses)))
  }
  cat("\nDetails (capped at 60):\n")
  flat <- list()
  for (fn in names(fn_uses_in_prose)) {
    for (u in fn_uses_in_prose[[fn]]) {
      flat[[length(flat) + 1]] <- list(fn = fn, chap = u$chap, line = u$line,
                                       context = u$context, intro_chap = u$intro_chap)
    }
  }
  show_n <- min(60, length(flat))
  flat <- flat[order(sapply(flat, function(x) x$chap))]
  for (i in seq_len(show_n)) {
    f <- flat[[i]]
    snippet <- substr(trimws(f$context), 1, 140)
    cat(sprintf("  `%s()` used Ch %d L%d (intro=Ch %d): %s\n",
                f$fn, f$chap, f$line, f$intro_chap, snippet))
  }
}

cat("\n========== DONE ==========\n")
