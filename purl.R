# This script is called in index.Rmd whenever the book is built. It creates .R
# scripts of all code the readers see and saves them in the docs/scripts folder

# Update this if the number of chapters in the book increases
num_chapters <- 11

# For %>%
library(dplyr)

# Create vector of Rmd file names
rmds <- list.files(pattern = "*.Rmd")

# Get chapter numbers from files
file_numbers <- list.files(pattern = "*.Rmd") %>%
  stringr::str_extract(pattern = "[0-9]+") %>%
  as.numeric()

# Get only those Rmd files that we'd like to purl()
rmd_files <- rmds[
  1 <= file_numbers &
    file_numbers <= num_chapters &
    !is.na(file_numbers)
]

# Replace "Rmd" with "R" to create R output file names
r_files <- stringr::str_replace(rmd_files, "Rmd", "R")

# Create `docs`` folder and `scripts` subfolder
if (!dir.exists("docs")) {
  dir.create("docs")
}
if (!dir.exists(here::here("docs", "scripts"))) {
  dir.create(here::here("docs", "scripts"))
}

# Append full path to `r_files`
r_files <- here::here("docs", "scripts", r_files)

# Iterate over both the `rmd_files` and `r_files` vectors with `knitr::purl()`
purrr::walk2(rmd_files, r_files, knitr::purl)
