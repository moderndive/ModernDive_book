dir.create("docs/scripts")

# Note order matters here:
chapter_titles <- c("getting-started", "visualization", "tidy", "wrangling", 
                    "regression", "multiple-regression", "sampling", 
                    "confidence-intervals", "hypothesis-testing",
                    "inference-for-regression", "thinking-with-data")
chapter_numbers <- stringr::str_pad(2:(length(chapter_titles) + 1), 2, "left", pad = "0")
for(i in 1:length(chapter_numbers)){
  Rmd_file <- stringr::str_c(chapter_numbers[i], "-", chapter_titles[i], ".Rmd")
  R_file <- stringr::str_c("docs/scripts/", chapter_numbers[i], "-", chapter_titles[i], ".R")
  knitr::purl(Rmd_file, R_file)
}