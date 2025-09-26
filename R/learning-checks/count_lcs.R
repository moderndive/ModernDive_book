library(tidyverse)

files <- list.files("R/lc/", pattern = "^[0-9]+.*\\.md$", full.names = TRUE)

counts <- tibble(
  file = basename(files),
  n_checks = map_int(files, ~ sum(str_detect(read_lines(.x), "\\*\\*`r\\s*paste0\\(")))
)

counts

# A tibble: 11 × 2
# file                  n_checks
# <chr>                    <int>
#   1 01_learning-checks.md        7
# 2 02_learning-checks.md       37
# 3 03_learning-checks.md       20
# 4 04_learning-checks.md        5
# 5 05_learning-checks.md       19
# 6 06_learning-checks.md       12
# 7 07_learning-checks.md       18
# 8 08_learning-checks.md       18
# 9 09_learning-checks.md       15
# 10 10_learning-checks.md       26
# 11 11_learning-checks.md        5
