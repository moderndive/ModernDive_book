# This script is called in index.qmd whenever the book is built. It creates .R
# scripts of all code the readers see and saves them in the docs/scripts folder

# Update this if the number of chapters in the book increases
num_chapters <- 11

# For %>%
library(dplyr)

# Create vector of qmd file names
qmds <- list.files(pattern = "*.qmd")

# Get chapter numbers from files
file_numbers <- list.files(pattern = "*.qmd") %>%
  stringr::str_extract(pattern = "[0-9]+") %>%
  as.numeric()

# Get only those qmd files that we'd like to purl()
qmd_files <- qmds[
  1 <= file_numbers &
    file_numbers <= num_chapters &
    !is.na(file_numbers)
]

# Replace "qmd" with "R" to create R output file names
r_files <- stringr::str_replace(qmd_files, "qmd", "R")

# Create `docs`` folder and `scripts` subfolder
if (!dir.exists("docs")) {
  dir.create("docs")
}
if (!dir.exists(here::here("docs", "scripts"))) {
  dir.create(here::here("docs", "scripts"))
}

# Append full path to `r_files`
r_files <- here::here("docs", "scripts", r_files)

# Iterate over both the `qmd_files` and `r_files` vectors with `knitr::purl()`
purrr::walk2(qmd_files, r_files, knitr::purl)
