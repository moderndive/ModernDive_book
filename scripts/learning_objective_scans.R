#!/usr/bin/env Rscript
# Learning-objective coherence scans for ModernDive.
#
# Scan 4: Quick-check alignment — map each QC to a subsection (heuristic);
#         flag substantial subsections with no QC and QCs that only touch Conclusion.
# Scan 5: LC distribution — count inline learncheck blocks per subsection;
#         flag substantial subsections with no LC.
# Scan 6: Difficulty progression — within each exercise YAML `group`,
#         flag groups that jump ★ → ★★★ without a ★★ rung.

suppressPackageStartupMessages({
  library(stringr)
  library(yaml)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

chap_files <- c(
  "01-getting-started.qmd", "02-visualization.qmd", "03-wrangling.qmd",
  "04-tidy.qmd",            "05-regression.qmd",    "06-multiple-regression.qmd",
  "07-sampling.qmd",        "08-confidence-intervals.qmd",
  "09-hypothesis-testing.qmd","10-inference-for-regression.qmd",
  "11-tell-your-story-with-data.qmd"
)
chap_num <- 1:11
names(chap_files) <- chap_num
chap_lines <- lapply(chap_files, function(f) readLines(f, warn = FALSE))
names(chap_lines) <- chap_num

# Helper: line classifier (prose vs code) — same logic as the lexicon scan.
classify_lines <- function(lines) {
  in_chunk <- FALSE
  state <- character(length(lines))
  for (i in seq_along(lines)) {
    l <- lines[i]
    if (!in_chunk && grepl("^```\\{", l)) { in_chunk <- TRUE; state[i] <- "fence" }
    else if (in_chunk && grepl("^```\\s*$", l)) { in_chunk <- FALSE; state[i] <- "fence" }
    else if (in_chunk) state[i] <- "code"
    else state[i] <- "prose"
  }
  state
}
chap_state <- lapply(chap_lines, classify_lines)
names(chap_state) <- chap_num

# Helper: parse out (##/### header line ranges, title, level) per chapter.
parse_headers <- function(lines) {
  res <- data.frame(line = integer(), level = integer(), title = character(),
                    raw = character(), stringsAsFactors = FALSE)
  for (i in seq_along(lines)) {
    m <- str_match(lines[i], "^(##+)\\s+([^{]+?)(?:\\s*\\{[^}]*\\})?\\s*$")
    if (!is.na(m[1, 1])) {
      level <- nchar(m[1, 2])
      title <- trimws(m[1, 3])
      res <- rbind(res, data.frame(line = i, level = level, title = title,
                                    raw = lines[i], stringsAsFactors = FALSE))
    }
  }
  res
}
chap_headers <- lapply(chap_lines, parse_headers)
names(chap_headers) <- chap_num

# For each chapter, build "sections" = list of (title, start_line, end_line,
# subsection_titles, content_length_lines).
build_section_table <- function(headers, n_lines) {
  # Only level-2 (##) sections, with nested level-3 (###).
  l2 <- which(headers$level == 2)
  out <- list()
  for (i in seq_along(l2)) {
    start <- headers$line[l2[i]]
    end <- if (i < length(l2)) headers$line[l2[i + 1]] - 1 else n_lines
    sub_idx <- which(headers$level == 3 & headers$line > start & headers$line <= end)
    subs <- if (length(sub_idx)) {
      sub_starts <- headers$line[sub_idx]
      sub_ends <- c(sub_starts[-1] - 1, end)
      data.frame(title = headers$title[sub_idx],
                 start = sub_starts, end = sub_ends,
                 length = sub_ends - sub_starts + 1,
                 stringsAsFactors = FALSE)
    } else NULL
    out[[i]] <- list(title = headers$title[l2[i]],
                     start = start, end = end,
                     length = end - start + 1,
                     subs = subs)
  }
  out
}
chap_sections <- mapply(function(h, l) build_section_table(h, length(l)),
                        chap_headers, chap_lines, SIMPLIFY = FALSE)
names(chap_sections) <- chap_num

# Helper: which level-2 + level-3 contains a given line?
locate_line <- function(line, sections) {
  for (s in sections) {
    if (line >= s$start && line <= s$end) {
      sub <- NA_character_
      if (!is.null(s$subs)) {
        for (k in seq_len(nrow(s$subs))) {
          if (line >= s$subs$start[k] && line <= s$subs$end[k]) {
            sub <- s$subs$title[k]; break
          }
        }
      }
      return(list(section = s$title, subsection = sub))
    }
  }
  list(section = NA, subsection = NA)
}

# ============================================================
# SCAN 5: Learning-check distribution
# ============================================================
cat("\n========== SCAN 5: LC DISTRIBUTION ==========\n")
cat("Map each `::: {.learncheck}` block to its containing section/subsection.\n")
cat("Flag substantial sections with zero LC blocks.\n\n")

for (n in chap_num) {
  lines <- chap_lines[[as.character(n)]]
  sections <- chap_sections[[as.character(n)]]
  lc_lines <- grep("^::: \\{\\.learncheck\\}", lines)

  # Count per (section, subsection)
  lc_map <- list()
  for (ll in lc_lines) {
    loc <- locate_line(ll, sections)
    key <- paste0(loc$section, " || ", loc$subsection)
    if (is.null(lc_map[[key]])) lc_map[[key]] <- 0L
    lc_map[[key]] <- lc_map[[key]] + 1L
  }

  cat(sprintf("\n--- Chapter %d (%s) — %d LC blocks total ---\n",
              n, chap_files[as.character(n)], length(lc_lines)))
  cat("  LC counts by section / subsection:\n")
  for (k in names(lc_map)) {
    cat(sprintf("    %-60s : %d\n", k, lc_map[[k]]))
  }

  # Identify substantial sections (length > 100 lines, excluding setup/conclusion/exercises/quick checks)
  benign_titles <- c("Needed packages", "Conclusion", "Exercises", "Quick checks",
                     "Summary and final remarks", "Concluding remarks")
  substantial <- Filter(function(s) {
    if (s$title %in% benign_titles) return(FALSE)
    s$length > 80
  }, sections)

  lc_per_section <- sapply(substantial, function(s) {
    sum(lc_lines >= s$start & lc_lines <= s$end)
  })

  zero_lc <- substantial[lc_per_section == 0]
  if (length(zero_lc)) {
    cat("  FLAG — substantial sections (>80 lines) with NO LC blocks:\n")
    for (s in zero_lc) {
      cat(sprintf("    - %s (lines %d-%d, length %d)\n",
                  s$title, s$start, s$end, s$length))
    }
  }

  # Also: substantial *subsections* with no LC
  zero_lc_subs <- character()
  for (s in substantial) {
    if (is.null(s$subs)) next
    for (k in seq_len(nrow(s$subs))) {
      if (s$subs$length[k] < 80) next
      sub_lcs <- sum(lc_lines >= s$subs$start[k] & lc_lines <= s$subs$end[k])
      if (sub_lcs == 0) {
        zero_lc_subs <- c(zero_lc_subs,
          sprintf("    - %s :: %s (lines %d-%d, length %d)",
                  s$title, s$subs$title[k],
                  s$subs$start[k], s$subs$end[k], s$subs$length[k]))
      }
    }
  }
  if (length(zero_lc_subs)) {
    cat("  FLAG — substantial subsections (>80 lines) with NO LC blocks:\n")
    cat(paste(zero_lc_subs, collapse = "\n"), "\n")
  }
}

# ============================================================
# SCAN 4: Quick-check alignment
# ============================================================
cat("\n\n========== SCAN 4: QUICK-CHECK ALIGNMENT ==========\n")
cat("Parse each `## Quick checks` block; for each Qn stem, infer the targeted\n")
cat("section by keyword overlap with section/subsection titles.\n\n")

# Keyword tokenizer
tokenize <- function(s) {
  s <- tolower(s)
  s <- gsub("[`*_$\\\\{}()|^/=+~<>!?'\"\\[\\],.;:#@-]", " ", s, perl = TRUE)
  toks <- str_split(s, "\\s+")[[1]]
  toks <- toks[nchar(toks) > 2]
  # Common stop words
  stop <- c("the", "and", "for", "with", "are", "this", "that", "from", "any",
            "what", "does", "true", "false", "one", "two", "all", "but", "you",
            "your", "not", "into", "their", "have", "has", "had", "would",
            "could", "should", "can", "may", "will", "which", "when", "where",
            "how", "why", "between", "among", "than", "then", "also", "some",
            "many", "few", "more", "less", "most", "least", "very", "much",
            "over", "under", "off", "out", "set", "let", "now", "new", "old",
            "use", "using", "used", "value", "values", "variable", "variables",
            "function", "functions", "data", "rows", "row", "columns", "column",
            "interpret", "called")
  toks[!toks %in% stop]
}

for (n in chap_num) {
  lines <- chap_lines[[as.character(n)]]
  sections <- chap_sections[[as.character(n)]]

  # Find ## Quick checks block
  qc_start <- grep("^## Quick checks", lines)
  if (!length(qc_start)) {
    cat(sprintf("\n--- Chapter %d — no Quick checks section ---\n", n))
    next
  }
  qc_start <- qc_start[1]
  qc_end <- {
    next_l2 <- which(grepl("^## ", lines) & seq_along(lines) > qc_start)
    if (length(next_l2)) next_l2[1] - 1 else length(lines)
  }
  qc_block <- lines[qc_start:qc_end]

  # Parse Qn stems: lines starting with **Qn.**
  q_idx <- grep("^\\*\\*Q[0-9]+\\.\\*\\*", qc_block)
  qs <- list()
  for (i in seq_along(q_idx)) {
    s <- q_idx[i]
    e <- if (i < length(q_idx)) q_idx[i + 1] - 1 else length(qc_block)
    # Stem = the lines up to the first option line (a., b., etc.) or "::: {.callout"
    opt <- grep("^[a-d]\\.\\s|^- [A-D]\\.\\s", qc_block[s:e])
    end_stem <- if (length(opt)) s + opt[1] - 2 else e
    stem <- paste(qc_block[s:end_stem], collapse = " ")
    stem <- gsub("^\\*\\*Q[0-9]+\\.\\*\\*\\s*", "", stem)
    qs[[i]] <- list(num = i, line = qc_start + s - 1, stem = stem)
  }

  # For each Qn, score against each subsection title.
  # The "best" subsection wins (largest token overlap), with section as fallback.
  sub_titles <- c()
  sub_meta <- list()
  for (s in sections) {
    if (s$title %in% c("Needed packages", "Conclusion", "Exercises", "Quick checks",
                       "Summary and final remarks", "Concluding remarks",
                       "Summary of statistical inference")) next
    sub_titles <- c(sub_titles, s$title)
    sub_meta[[length(sub_meta) + 1]] <- list(title = s$title, level = 2, length = s$length)
    if (!is.null(s$subs)) {
      for (k in seq_len(nrow(s$subs))) {
        sub_titles <- c(sub_titles, s$subs$title[k])
        sub_meta[[length(sub_meta) + 1]] <- list(
          title = s$subs$title[k], level = 3, length = s$subs$length[k],
          parent = s$title
        )
      }
    }
  }
  title_toks <- lapply(sub_titles, tokenize)

  cat(sprintf("\n--- Chapter %d (%s) — %d QC questions ---\n",
              n, chap_files[as.character(n)], length(qs)))
  qc_to_section <- character(length(qs))
  for (q in qs) {
    q_toks <- tokenize(q$stem)
    overlaps <- sapply(title_toks, function(tt) length(intersect(q_toks, tt)))
    if (max(overlaps) == 0) {
      best <- "(no keyword match — possibly Conclusion-only)"
    } else {
      best_idx <- which.max(overlaps)
      best <- sprintf("%s [overlap=%d]", sub_titles[best_idx], overlaps[best_idx])
    }
    qc_to_section[q$num] <- best
    stem_short <- substr(trimws(gsub("\\s+", " ", q$stem)), 1, 110)
    cat(sprintf("  Q%-2d -> %-65s | %s\n", q$num, best, stem_short))
  }

  # Now: which substantial subsections have ZERO QC coverage?
  covered <- unique(sub("\\s\\[overlap=.*$", "", qc_to_section))
  substantial_subs <- Filter(function(m) m$length > 80, sub_meta)
  uncovered <- Filter(function(m) !(m$title %in% covered), substantial_subs)
  if (length(uncovered)) {
    cat("  FLAG — substantial subsections (>80 lines) with no QC keyword match:\n")
    for (m in uncovered) {
      parent <- if (!is.null(m$parent)) sprintf(" (in '%s')", m$parent) else ""
      cat(sprintf("    - %s%s [length=%d]\n", m$title, parent, m$length))
    }
  }
}

# ============================================================
# SCAN 6: Difficulty progression
# ============================================================
cat("\n\n========== SCAN 6: DIFFICULTY PROGRESSION ==========\n")
cat("For each exercise YAML `group`, list the difficulty sequence in YAML order.\n")
cat("Flag groups where a ★★★ appears with no preceding ★★ in the same group.\n\n")

for (n in chap_num) {
  yml_path <- sprintf("exercises/%02d.yml", n)
  if (!file.exists(yml_path)) next
  d <- yaml::read_yaml(yml_path)
  # Group exercises by `group`, preserving order
  by_group <- list()
  for (ex in d$exercises) {
    g <- ex$group %||% "<none>"
    if (is.null(by_group[[g]])) by_group[[g]] <- list()
    by_group[[g]][[length(by_group[[g]]) + 1]] <- list(num = ex$ex_num,
                                                       diff = ex$difficulty)
  }
  cat(sprintf("\n--- Chapter %d ---\n", n))
  for (g in names(by_group)) {
    exes <- by_group[[g]]
    diffs <- sapply(exes, function(x) as.integer(x$diff))
    seq_str <- paste(diffs, collapse = "")
    flag <- ""
    # Flag: ★★★ without preceding ★★ (in YAML order within group)
    if (any(diffs == 3) && !any(diffs == 2)) flag <- "  <<< missing ★★ rung"
    # Flag: jumps from 1 -> 3 with NO 2 anywhere
    cat(sprintf("  %-50s %s%s\n", g, seq_str, flag))
  }
}

# Helper for yaml `%||%`
`%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a

cat("\n========== DONE ==========\n")
