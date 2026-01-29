# Common R setup for all chapters
# This file is sourced at the start of each chapter

library(knitr)

# Load image helper functions
source("R/image_functions.R")

# Default chunk options
knitr::opts_chunk$set(
  echo = TRUE,
  eval = TRUE,
  warning = FALSE,
  message = TRUE,
  comment = "",
  fig.align = "center"
)

# Global options
options(
  width = 120,
  digits = 7,
  knitr.kable.NA = "NA",
  scipen = 99
)
