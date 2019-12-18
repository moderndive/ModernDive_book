library(tidyverse)
library(moderndive)
library(here)

# Note this assumes there are 40 students in your class

locations <-
  tibble(
    x = rep(1:8, times = 5),
    y = rep(1:5, each = 8)
  )

for(i in 1:nrow(pennies_sample_2)){
  # Set year
  locations <- locations %>%
    mutate(year = pennies_sample_2$year[i])

  grid <- ggplot(locations, aes(x = x, y = y, label = year)) +
    geom_text(size = 10) +
    geom_hline(yintercept = seq(0.5, 5.5, by = 1)) +
    geom_vline(xintercept = seq(0.5, 8.5, by = 1)) +
    theme_void() +
    coord_fixed(ratio = 1)

  str_pad(i, width = 2, pad = "0") %>%
    str_c("penny_", ., ".pdf") %>%
    here("images", "sampling", "pennies", .) %>%
    ggsave(grid, width = 11, height = 8.5)
}


system("\"/System/Library/Automator/Combine PDF Pages.action/Contents/Resources/join.py\" -o images/sampling/pennies/all_pennies.pdf images/sampling/pennies/*.pdf")
system("rm images/sampling/pennies/penny_*.pdf")
