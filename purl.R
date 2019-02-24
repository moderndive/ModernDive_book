if(!dir.exists("docs/scripts")){
  dir.create("docs")
  dir.create("docs/scripts")
}

# For Chapter 5
solutions_shown <- c('')
show_solutions <- function(section){
  return(solutions_shown == "ALL" | section %in% solutions_shown)
}

# Note order matters here:
chapter_titles <- c("getting-started",
                    "visualization",
                    "wrangling",
                    "tidy",
                    "regression",
                    "multiple-regression",
                    "sampling",
                    "confidence-intervals",
                    "hypothesis-testing",
                    "inference-for-regression",
                    "thinking-with-data")
chapter_numbers <- stringr::str_pad(
  string = 2:(length(chapter_titles) + 1),
  width = 2,
  side = "left",
  pad = "0"
  )
for(i in seq_len(length(chapter_numbers))){
  Rmd_file <- stringr::str_c(chapter_numbers[i], "-",
                             chapter_titles[i], ".Rmd")
  R_file <- stringr::str_c("docs/scripts/", chapter_numbers[i],
                           "-", chapter_titles[i], ".R")
  knitr::purl(Rmd_file, R_file)
}
