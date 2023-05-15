library(tidyverse)
library(googledrive)
library(googlesheets4)
drive_find(n_max = 25)


"1y3kOsU_wDrDd5eiJbEtLeHT9L5SvpZb_TrzwFBsouk0" %>%
  gs_key() %>%
  gs_read(ws = 1)  %>%
  select(-`Resampled penny #`) %>%
  apply(2, mean) %>%
  tibble(x = .) %>%
  ggplot(aes(x)) +
  geom_histogram(binwidth = 2.5) +
  labs(x = "sample mean year", title = "Bootstrap resampling distribution")
ggsave("~/Desktop/bootstrap_distribution.png", width = 8, height = 4.5)
