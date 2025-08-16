# install.packages(c("stringr","dplyr"), repos = "https://cloud.r-project.org")
library(stringr)
library(dplyr)
library(glue)

# --- Core parser: split into LC "blocks" and extract question + solution ---
parse_lc_blocks <- function(lines) {
  # find starts of LC prompts (lines beginning with **`r paste0(...)`**)
  lc_start <- which(str_detect(lines, "^\\*\\*`r\\s+paste0\\("))
  if (length(lc_start) == 0) return(tibble(idx = integer(), question = character(), solution = character()))

  # end of each block is the line before the next start (or EOF)
  lc_end <- c(lc_start[-1] - 1L, length(lines))

  purrr::map2_dfr(seq_along(lc_start), seq_along(lc_end), function(i, j) {
    rng <- lc_start[i]:lc_end[j]

    # The first line is the LC question line
    q_line <- lines[rng[1]]

    # Remove the inline LC label **`r paste0(...)`** and leading spaces to get the question text
    question <- q_line |>
      str_replace("^\\*\\*`r\\s+paste0\\([^`]+\\)`\\*\\*\\s*", "") |>
      str_squish()

    # Try to find a "**Solution**:" line inside this block and capture the (possibly blank) next line(s) up to an empty line
    sol_idx <- which(str_detect(lines[rng], "^\\*\\*Solution\\*\\*:"))
    solution <- ""
    if (length(sol_idx)) {
      # take everything after the **Solution**: line until the next blank line or block end
      after <- lines[rng][(sol_idx[1] + 1L):length(rng)]
      stop_at <- which(after == "") %>% { if (length(.) == 0) length(after) else (.[1] - 1L) }
      solution <- after[seq_len(stop_at)] |> paste(collapse = "\n") |> str_squish()
    }

    tibble(
      idx = i,                # order within the chapter
      question = question,
      solution = solution
    )
  })
}

# --- Comparison wrapper: returns only differences (by question and/or solution) ---
compare_chapters <- function(v1_lines, v2_lines, compare_solutions = FALSE) {
  v1 <- parse_lc_blocks(v1_lines)
  v2 <- parse_lc_blocks(v2_lines)

  # align by position (idx). If you render LCs the same way across versions, order is stable.
  joined <- full_join(v1, v2, by = "idx", suffix = c("_v1", "_v2")) |>
    mutate(
      question_equal = str_squish(question_v1) == str_squish(question_v2),
      solution_equal = str_squish(solution_v1) == str_squish(solution_v2),
      changed = if (compare_solutions) !(question_equal & solution_equal) else !question_equal
    )

  # Keep only changed rows, with clean columns
  out <- joined |>
    filter(changed | is.na(changed)) |>
    transmute(
      idx,
      question_v1 = coalesce(question_v1, "(missing)"),
      question_v2 = coalesce(question_v2, "(missing)"),
      # include solutions only if you ask to compare them
      solution_v1 = if (compare_solutions) coalesce(solution_v1, "") else NULL,
      solution_v2 = if (compare_solutions) coalesce(solution_v2, "") else NULL
    ) |>
    arrange(idx)

  out
}

chapter_num <- "01"

v2_lines <- readLines(glue("R/lc/{chapter_num}_learning-checks.md"))
v1_lines <- readLines(glue("R/v1/{chapter_num}_v1_learning-checks.md"))

# Run the comparison (questions only)
differences <- compare_chapters(v1_lines, v2_lines, compare_solutions = FALSE)

# If you want to see all differences:
differences

## ACROSS ALL FILES
chapter_nums <- sprintf("%02d", 1:11)

all_diffs <- map_dfr(chapter_nums, function(chap) {
  v2_lines <- readLines(glue("R/lc/{chap}_learning-checks.md"))
  v1_lines <- readLines(glue("R/v1/{chap}_v1_learning-checks.md"))

  compare_chapters(v1_lines, v2_lines, compare_solutions = FALSE) %>%
    mutate(chapter_num = chap, .before = 1)
})

all_diffs
