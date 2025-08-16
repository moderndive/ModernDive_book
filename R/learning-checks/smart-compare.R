# deps
library(tidyverse)
library(stringdist)   # stringdistmatrix()
library(clue)         # solve_LSAP()

# --- helpers ---------------------------------------------------------------

lc_token_re <- "\\*\\*`r\\s*paste0\\([^`]*\\)`\\*\\*"

extract_questions_from_md <- function(md_lines) {
  # keep only the LC lines; strip token; keep index
  keep <- str_detect(md_lines, lc_token_re)
  tibble(
    idx  = which(keep),
    text = md_lines[keep] %>%
      str_replace(lc_token_re, "") %>%
      str_squish()
  )
}

prep_text <- function(x) {
  x %>%
    str_to_lower() %>%
    str_replace_all("`[^`]+`", " ") %>%       # drop inline code (e.g., `temp`, `wind_speed`)
    str_replace_all("\\b(19|20)\\d{2}\\b", " <year> ") %>%  # normalize years
    str_replace_all("\\b\\d+\\b", " <num> ") %>%
    str_replace_all("[[:punct:]]+", " ") %>%
    str_replace_all("\\b(the|a|an|of|for|in|on|to|with|that|this|these|those|and|or)\\b", " ") %>%
    str_squish()
}

# Build a square cost matrix with an "unmatched" penalty padding
build_cost_matrix <- function(v1_clean, v2_clean,
                              method = "cosine", q = 3, p = 0.1,
                              lambda = 0.08,           # position prior
                              unmatched_cost = 0.9) {  # big cost for "leave unmatched"
  n1 <- length(v1_clean); n2 <- length(v2_clean)
  if (!n1 || !n2) {
    N <- max(n1, n2); return(matrix(unmatched_cost, nrow = N, ncol = N))
  }

  base <- stringdistmatrix(v2_clean, v1_clean, method = method, q = q, p = p)
  # add a soft position prior (prefers near-diagonal)
  pos <- outer(seq_len(n2), seq_len(n1), function(i, j) abs(i - j) / max(n1, n2))
  cost <- base + lambda * pos

  # pad to square with unmatched penalty
  N <- max(n1, n2)
  M <- matrix(unmatched_cost, nrow = N, ncol = N)
  M[seq_len(n2), seq_len(n1)] <- cost
  M
}

# --- main ------------------------------------------------------------------

compare_chapters_lsap <- function(v1_lines,
                                  v2_lines,
                                  compare_solutions = FALSE,   # kept for API parity
                                  method = "cosine", q = 3, p = 0.1,
                                  max_dist = 0.45,              # accept <= this distance
                                  minor_edit = 0.12,            # tiny edits threshold
                                  lambda = 0.08,
                                  unmatched_cost = 0.9) {

  v1_tbl <- extract_questions_from_md(v1_lines) %>%
    mutate(clean = prep_text(text))
  v2_tbl <- extract_questions_from_md(v2_lines) %>%
    mutate(clean = prep_text(text))

  n1 <- nrow(v1_tbl); n2 <- nrow(v2_tbl)
  N  <- max(n1, n2)

  cost <- build_cost_matrix(v1_tbl$clean, v2_tbl$clean,
                            method = method, q = q, p = p,
                            lambda = lambda, unmatched_cost = unmatched_cost)

  # Solve LSAP (rows = v2, columns = v1, both padded to N)
  assign <- solve_LSAP(cost)           # length N, values in 1..N (column chosen for each row)

  # Build result rows for the first n2 rows (real v2 rows)
  res <- tibble(
    v2_lc = seq_len(N),
    v1_col = as.integer(assign),
    dist   = cost[cbind(v2_lc, v1_col)]
  ) %>%
    filter(v2_lc <= n2) %>%
    mutate(
      matched_v1 = v1_col <= n1,                # TRUE if matched to a real v1
      v2_idx  = v2_tbl$idx[v2_lc],
      v2_text = v2_tbl$text[v2_lc],
      v1_lc  = ifelse(matched_v1, v1_col, NA_integer_),
      v1_idx  = ifelse(matched_v1, v1_tbl$idx[v1_lc], NA_integer_),
      v1_text = ifelse(matched_v1, v1_tbl$text[v1_lc], NA_character_),

      status  = case_when(
        !matched_v1 ~ "new",
        dist <= minor_edit & v2_lc == v1_lc                 ~ "same_or_tiny_edit",
        dist <= minor_edit & v2_lc != v1_lc                 ~ "moved",
        dist <= max_dist  & v2_lc == v1_lc                  ~ "edited",
        dist <= max_dist  & v2_lc != v1_lc                  ~ "moved_and_edited",
        TRUE                                                   ~ "new"  # cost too high => treat as new
      )
    ) %>%
    select(v2_lc, v2_idx, v2_text, v1_lc, v1_idx, v1_text, dist, status)

  # Add v1 rows that were not used (removed)
  used_v1_cols <- res %>% filter(!is.na(v1_lc)) %>% pull(v1_lc)
  removed <- tibble(v1_lc = setdiff(seq_len(n1), used_v1_cols)) %>%
    mutate(
      v1_idx  = v1_tbl$idx[v1_lc],
      v1_text = v1_tbl$text[v1_lc],
      v2_lc  = NA_integer_, v2_idx = NA_integer_, v2_text = NA_character_,
      dist    = NA_real_, status = "removed"
    ) %>%
    select(v2_lc, v2_idx, v2_text, v1_lc, v1_idx, v1_text, dist, status)

  bind_rows(res, removed) %>%
    arrange(coalesce(v2_lc, Inf), coalesce(v1_lc, Inf))
}

compare_one_chapter <- function(chapter_num,
                                method = "cosine",
                                q = 3,
                                max_dist = 0.45,
                                minor_edit = 0.12) {

  v2_lines <- readLines(glue("R/lc/{chapter_num}_learning-checks.md"))
  v1_lines <- readLines(glue("R/v1/{chapter_num}_v1_learning-checks.md"))

  differences <- compare_chapters_lsap(
    v1_lines, v2_lines,
    method = method, q = q,
    max_dist = max_dist, minor_edit = minor_edit
  ) %>%
    mutate(chapter_num = chapter_num, .before = 1) %>%
    relocate(status, .after = 1)

  differences %>%
    mutate(
      status_simple = case_when(
        !is.na(v1_lc) & !is.na(dist) & dist == 0 ~ "unchanged",
        !is.na(v1_lc) & !is.na(dist) & dist > 0  ~ "edited",
        status == "new"                          ~ "new",
        status == "removed"                      ~ "removed",
        TRUE                                     ~ "edited"
      ),
      .after = status
    )
}

# Example: run for all chapters 01–11
chapter_nums <- sprintf("%02d", 1:11)

all_diffs <- map_dfr(chapter_nums, compare_one_chapter) %>%
  select(-status)

all_diffs

write_csv(all_diffs, "R/all_v1_v2_lc_diffs.csv")

