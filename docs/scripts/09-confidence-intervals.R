## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(moderndive)
# remotes::install_github("andrewpbray/infer", ref = "p_value")
library(infer)
# For loading CSV files:
library(readr)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)

## ----include=FALSE-------------------------------------------------------
set.seed(2018)
pennies_sample <- pennies %>% sample_n(40)

## ------------------------------------------------------------------------
pennies_sample

## ------------------------------------------------------------------------
ggplot(pennies_sample, aes(x = age_in_2011)) +
  geom_histogram(bins = 10, color = "white")

## ------------------------------------------------------------------------
x_bar <- pennies_sample %>% 
  summarize(stat = mean(age_in_2011))
x_bar

## ----include=FALSE-------------------------------------------------------
set.seed(201)

## ------------------------------------------------------------------------
bootstrap_sample1 <- pennies_sample %>% 
  rep_sample_n(size = 40, replace = TRUE, reps = 1)
bootstrap_sample1

## ------------------------------------------------------------------------
ggplot(bootstrap_sample1, aes(x = age_in_2011)) +
  geom_histogram(bins = 10, color = "white")

## ------------------------------------------------------------------------
bootstrap_sample1 %>% 
  summarize(stat = mean(age_in_2011))

## ------------------------------------------------------------------------
six_bootstrap_samples <- pennies_sample %>% 
  rep_sample_n(size = 40, replace = TRUE, reps = 6)

## ------------------------------------------------------------------------
ggplot(six_bootstrap_samples, aes(x = age_in_2011)) +
  geom_histogram(bins = 10, color = "white") +
  facet_wrap(~ replicate)

## ------------------------------------------------------------------------
six_bootstrap_samples %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(age_in_2011))

## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/specify.png")

## ------------------------------------------------------------------------
pennies_sample %>% 
  specify(response = age_in_2011)

## ------------------------------------------------------------------------
pennies_sample %>% 
  specify(formula = age_in_2011 ~ NULL)

## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/generate.png")

## ------------------------------------------------------------------------
thousand_bootstrap_samples <- pennies_sample %>% 
  specify(response = age_in_2011) %>% 
  generate(reps = 1000)

## ------------------------------------------------------------------------
thousand_bootstrap_samples %>% count(replicate)

## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/calculate.png")

## ------------------------------------------------------------------------
bootstrap_distribution <- pennies_sample %>% 
  specify(response = age_in_2011) %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "mean")
bootstrap_distribution

## ------------------------------------------------------------------------
pennies_sample %>% 
  summarize(stat = mean(age_in_2011))

## ------------------------------------------------------------------------
pennies_sample %>% 
  specify(response = age_in_2011) %>% 
  calculate(stat = "mean")

## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/visualize.png")

## ------------------------------------------------------------------------
bootstrap_distribution %>% visualize()

## ------------------------------------------------------------------------
bootstrap_distribution %>% visualize(obs_stat = x_bar)

## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  summarize(mean_of_means = mean(stat))

## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  get_ci(level = 0.95, type = "percentile")

## ------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_ci()
percentile_ci

## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  visualize(endpoints = percentile_ci, direction = "between")

## ------------------------------------------------------------------------
standard_error_ci <- bootstrap_distribution %>% 
  get_ci(type = "se", point_estimate = x_bar)
standard_error_ci

## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  visualize(endpoints = standard_error_ci, direction = "between")

