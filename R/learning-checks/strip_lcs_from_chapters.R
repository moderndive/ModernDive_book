# Load tidyverse helpers
library(tidyverse)

# --------------------------------------------------------------------------------
# extract_learning_checks_min()
# Reads a chapter .Rmd and writes a .md where EACH BLOCK is:
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** <full question text (collapsed)>
#
# Followed by:
# (blank line)
# **Solution**:
# (two blank lines)
#
# Multi-line fix:
# - After finding an LC token line, keep collecting subsequent "question" lines
#   until we hit either:
#     (a) the next LC token line, OR
#     (b) a new learncheck block starter: ```{block, type="learncheck", ...}
# - While collecting, drop formatting-only lines (\vspace, block markers, fences).
# --------------------------------------------------------------------------------
extract_learning_checks_min <- function(file_path, output_file = "learning_checks.md") {

  # Read the file as a character vector, one line per entry
  lines <- readr::read_lines(file_path)

  # Indices of lines that contain the LC inline-R token anywhere
  lc_idx <- stringr::str_which(lines, "\\*\\*`r\\s*paste0\\(")

  # If we found none, fail fast with a useful error
  if (length(lc_idx) == 0) {
    stop("No Learning Check tokens found in: ", file_path)
  }

  # Regex for the full bold inline-R LC token as written in the chapters
  token_re <- "\\*\\*`r\\s*paste0\\([^`]*\\)`\\*\\*"

  # Helper: a line that STARTS a learncheck block chunk (the spacer that ends an LC)
  is_learncheck_block_start <- function(x) {
    stringr::str_detect(stringr::str_trim(x),
                        "^```\\{block.*type\\s*=\\s*\"learncheck\"")
  }

  # Helper: lines that are NOT useful as question text (formatting only)
  is_junk <- function(x) {
    xt <- stringr::str_trim(x)
    xt == "" ||
      stringr::str_starts(xt, "\\\\vspace") ||              # \vspace
      stringr::str_starts(xt, "\\*\\*_Learning check_\\*\\*") ||  # section label
      stringr::str_starts(xt, "\\{block") ||                # literal "{block" (rare outside code fence)
      stringr::str_starts(xt, "```")                        # any fence line
  }

  # Build one output block per LC
  out_blocks <- purrr::map_chr(seq_along(lc_idx), function(k) {

    # Current LC line number
    i <- lc_idx[k]

    # Extract the LC token exactly (fallback to permissive if needed)
    token <- stringr::str_extract(lines[i], token_re)
    if (is.na(token)) token <- stringr::str_extract(lines[i], "\\*\\*`r[^`]*`\\*\\*")
    if (is.na(token)) return(paste0("<!-- Could not parse LC token on line ", i, " -->"))

    # Text after the token on the SAME line (often empty)
    same_line_tail <- lines[i] |>
      stringr::str_replace(token_re, "") |>
      stringr::str_squish()

    # Determine the farthest we might scan:
    # start with just before the NEXT LC (or EOF if none)
    next_lc_cutoff <- dplyr::coalesce(lc_idx[k + 1], length(lines) + 1L) - 1L

    # Also stop if we encounter a learncheck block starter before the next LC
    # (this is the spacer block that ends the current LC text)
    lookahead <- if (i + 1L <= next_lc_cutoff) lines[seq.int(i + 1L, next_lc_cutoff)] else character(0)
    block_rel <- purrr::detect_index(lookahead, is_learncheck_block_start)
    cutoff <- if (block_rel > 0) (i + block_rel) - 1L else next_lc_cutoff

    # Collect all “question” lines from (i+1) up to cutoff, skipping junk
    tails <- character(0)
    if (i + 1L <= cutoff) {
      for (j in seq.int(i + 1L, cutoff)) {
        lj <- lines[j]
        # Skip junk/formatting-only lines
        if (is_junk(lj)) next
        # Append usable text line (trim later)
        tails <- c(tails, lj)
      }
    }

    # Combine: same-line tail (if any) + subsequent tails
    parts <- c(same_line_tail, tails) %>%
      discard(~ .x == "") %>%           # guard against all-empty
      map_chr(stringr::str_trim)

    # Collapse multi-line question into ONE tidy line
    question <- if (length(parts)) stringr::str_squish(paste(parts, collapse = " ")) else ""

    # Compose final block text
    paste0(token,
           if (question != "") paste0(" ", question) else "",
           "\n\n**Solution**:\n\n")
  })

  # Write blocks to file (one LC block after another)
  readr::write_lines(out_blocks, output_file)

  invisible(out_blocks)
}

# ---------------------------
# Example:
# extract_learning_checks_min("01-getting-started.Rmd", "R/lc/01-learning-checks.md")
# ---------------------------

# For all chapters in V2
chapter_rmds <- list.files(
  pattern = "^(0[1-9]|10|11)-.*\\.Rmd$"
)

chap_nums <- stringr::str_extract(chapter_rmds, "^\\d{2}")

purrr::walk2(chapter_rmds,
             paste0("R/lc/", chap_nums, "_learning-checks.md"),
             extract_learning_checks_min)

# For all chapters in V1
v1_chapter_rmds <- list.files(
  path = "R/v1",
  pattern = "^(0[1-9]|10|11)-.*\\.Rmd$",
  full.names = TRUE
)

purrr::walk2(v1_chapter_rmds,
             paste0("R/v1/", chap_nums, "_v1_learning-checks.md"),
             extract_learning_checks_min)
