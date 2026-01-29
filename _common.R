# Common setup for all chapters
library(knitr)

# Source image functions if available
if (file.exists("R/image_functions.R")) {
  source("R/image_functions.R", local = knitr::knit_global())
}

# Version information
version <- "2.0.0"
date <- "December 4, 2024"
latest_release_version <- "2.0.0"
latest_release_date <- "March 20, 2025"

# Load commonly used packages if available, suppress errors
safe_library <- function(pkg) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    library(pkg, character.only = TRUE, quietly = TRUE)
    return(TRUE)
  }
  return(FALSE)
}

# Try to load common packages
safe_library("ggplot2")
safe_library("dplyr")
safe_library("tidyr")
safe_library("readr")
safe_library("tibble")
