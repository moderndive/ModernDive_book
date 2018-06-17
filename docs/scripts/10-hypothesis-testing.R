## ---- message=FALSE, warning=FALSE---------------------------------------
library(dplyr)
library(ggplot2)
library(infer)

# Clean data
mtcars <- mtcars %>%
  as_tibble() %>% 
  mutate(am = factor(am))

# Observed test statistic
obs_diff <- mtcars %>% 
  specify(mpg ~ am) %>%
  calculate(stat = "diff in means", order = c("1", "0"))

# Simulate null distribution of two-sample difference in means:
null_distribution <- mtcars %>%
  specify(mpg ~ am) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>% 
  calculate(stat = "diff in means", order = c("1", "0"))

# Visualize:
null_distribution %>% 
  visualize(obs_stat = obs_diff, direction = "greater")

