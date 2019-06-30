library(tidyverse)
library(ggplot2movies)

## ----message=FALSE, warning=FALSE----------------------------------------
movies_trimmed <- movies %>%
  select(title, year, rating, Action, Romance)


## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  filter(!(Action == 1 & Romance == 1))


## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  mutate(genre = case_when( (Action == 1) ~ "Action",
                            (Romance == 1) ~ "Romance",
                            TRUE ~ "Neither")) %>%
  filter(genre != "Neither") %>%
  select(-Action, -Romance)

set.seed(2017)
movies_genre_sample <- movies_trimmed %>%
  group_by(genre) %>%
  sample_n(34) %>%
  ungroup()

obs_diff <- movies_genre_sample %>%
  specify(formula = rating ~ genre) %>%
  calculate(stat = "diff in means", order = c("Romance", "Action"))
obs_diff

generated_samples <- readRDS("rds/generated_samples.rds")

null_distribution_two_means <- generated_samples %>%
  calculate(stat = "diff in means", order = c("Romance", "Action"))
