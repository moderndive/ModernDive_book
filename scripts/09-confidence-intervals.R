## ----message=FALSE, warning=FALSE----------------------------------------
library(tidyverse)
library(moderndive)
library(infer)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in the text
library(knitr)
library(kableExtra)
library(patchwork)
library(purrr)
# Ensure pennies_sample is loaded (might not be needed)
data("pennies_sample")








## ------------------------------------------------------------------------
pennies_sample


## ----pennies-sample-histogram, fig.cap="Distribution of year on 50 US pennies."----
ggplot(pennies_sample, aes(x = year)) +
  geom_histogram(binwidth = 10, color = "white")


## ------------------------------------------------------------------------
pennies_sample %>% 
  summarize(mean_year = mean(year))

## ---- echo=FALSE---------------------------------------------------------
x_bar <- pennies_sample %>% 
  summarize(mean_year = mean(year))


## ----summarytable-ch8-b, echo=FALSE, message=FALSE-----------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  # Only first two scenarios
  filter(Scenario <= 2) %>% 
  kable(
    caption = "\\label{tab:summarytable-ch8}Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position")) %>%
  column_spec(1, width = "0.5in") %>% 
  column_spec(2, width = "0.7in") %>%
  column_spec(3, width = "1in") %>%
  column_spec(4, width = "1.1in") %>% 
  column_spec(5, width = "1in")










## ------------------------------------------------------------------------
pennies_resample <- tibble(
  year = c(1976, 1962, 1976, 1983, 2017, 2015, 2015, 1962, 2016, 1976, 
           2006, 1997, 1988, 2015, 2015, 1988, 2016, 1978, 1979, 1997, 
           1974, 2013, 1978, 2015, 2008, 1982, 1986, 1979, 1981, 2004, 
           2000, 1995, 1999, 2006, 1979, 2015, 1979, 1998, 1981, 2015, 
           2000, 1999, 1988, 2017, 1992, 1997, 1990, 1988, 2006, 2000)
)




## ----eval=FALSE----------------------------------------------------------
## ggplot(pennies_resample, aes(x = year)) +
##   geom_histogram(binwidth = 10, color = "white") +
##   labs(title = "Resample of 50 pennies")
## ggplot(pennies_sample, aes(x = year)) +
##   geom_histogram(binwidth = 10, color = "white") +
##   labs(title = "Original sample of 50 pennies")




## ------------------------------------------------------------------------
pennies_resample %>% 
  summarize(mean_year = mean(year))

## ---- echo=FALSE---------------------------------------------------------
resample_mean <- pennies_resample %>% 
  summarize(mean_year = mean(year))




## ------------------------------------------------------------------------
pennies_resamples


## ------------------------------------------------------------------------
resampled_means <- pennies_resamples %>% 
  group_by(name) %>% 
  summarize(mean_year = mean(year))
resampled_means






## ----eval=FALSE----------------------------------------------------------
## virtual_resample <- pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE)


## ----eval=FALSE----------------------------------------------------------
## View(virtual_resample)


## ----virtual-resample, echo=FALSE----------------------------------------
virtual_resample <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1)
virtual_resample %>% 
  slice(1:10) %>%
  knitr::kable(
    align = c("r", "r", "r"),
    digits = 3,
    caption = "First 10 resampled rows of 50 in virtual sample",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ------------------------------------------------------------------------
virtual_resample %>% 
  summarize(resample_mean = mean(year))


## ------------------------------------------------------------------------
virtual_resamples <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 35)
virtual_resamples


## ---- eval=TRUE----------------------------------------------------------
virtual_resampled_means <- virtual_resamples %>% 
  group_by(replicate) %>% 
  summarize(mean_year = mean(year))
virtual_resampled_means










## ------------------------------------------------------------------------

# Repeat resampling 1000 times
virtual_resamples <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1000)

# Compute 1000 sample means
virtual_resampled_means <- virtual_resamples %>% 
  group_by(replicate) %>% 
  summarize(mean_year = mean(year))


## ------------------------------------------------------------------------
virtual_resampled_means <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>% 
  group_by(replicate) %>% 
  summarize(mean_year = mean(year))
virtual_resampled_means


## ----one-thousand-sample-means, echo=FALSE, message=FALSE, fig.cap="Bootstrap resampling distribution based on 1000 resamples."----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
  labs(x = "sample mean")


## ----eval=TRUE-----------------------------------------------------------
virtual_resampled_means %>% 
  summarize(mean_of_means = mean(mean_year))

## ----echo=FALSE----------------------------------------------------------
mean_of_means <- virtual_resampled_means %>% 
  summarize(mean(mean_year)) %>% 
  pull()






## ----echo=FALSE----------------------------------------------------------
# Can also use conf_int() and get_confidence_interval() instead of get_ci(),
# as they are aliases that work the exact same way.
percentile_ci <- virtual_resampled_means %>% 
  rename(stat = mean_year) %>% 
  get_ci(level = 0.95, type = "percentile")


## ----percentile-method, echo=FALSE, message=FALSE, fig.cap="Percentile method 95% confidence interval."----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  labs(x = "sample mean") +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = percentile_ci[[1, 1]], color = "red", size = 1) +
  geom_vline(xintercept = percentile_ci[[1, 2]], color = "red", size = 1)


## ----echo=FALSE----------------------------------------------------------
# Can also use conf_int() and get_confidence_interval() instead of get_ci(),
# as they are aliases that work the exact same way.
standard_error_ci <- virtual_resampled_means %>% 
  rename(stat = mean_year) %>% 
  get_ci(type = "se", point_estimate = x_bar)

# bootstrap SE value as scalar
bootstrap_se <- virtual_resampled_means %>% 
  summarize(se = sd(mean_year)) %>% 
  pull(se)


## ------------------------------------------------------------------------
virtual_resampled_means %>% 
  summarize(SE = sd(mean_year))


## ----percentile-and-se-method, echo=FALSE, message=FALSE, fig.cap="Comparing 95% confidence interval methods."----
both_CI <- bind_rows(
  percentile_ci %>% gather(endpoint, value) %>% mutate(type = "percentile"),
  standard_error_ci %>% gather(endpoint, value) %>% mutate(type = "SE")
)
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  labs(x = "sample mean", title = "Percentile method CI in red, SE method CI in blue") +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = percentile_ci[[1, 1]], color = "red", size = 1) +
  geom_vline(xintercept = percentile_ci[[1, 2]], color = "red", size = 1) + 
  geom_vline(xintercept = standard_error_ci[[1, 1]], color = "blue", size = 1) +
  geom_vline(xintercept = standard_error_ci[[1, 2]], color = "blue", size = 1)


## ----eval=FALSE----------------------------------------------------------
## standard_error_ci <- bootstrap_distribution %>%
##   get_ci(type = "se", point_estimate = x_bar)
## standard_error_ci






## ----eval=FALSE----------------------------------------------------------
## pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000)


## ----eval=FALSE----------------------------------------------------------
## pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>%
##   group_by(replicate)


## ----eval=FALSE----------------------------------------------------------
## pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>%
##   group_by(replicate) %>%
##   summarize(mean_year = mean(year))


## ----fig.align='center', echo=FALSE, out.width='20%'---------------------
knitr::include_graphics("images/flowcharts/infer/specify.png")


## ------------------------------------------------------------------------
pennies_sample %>% 
  specify(response = year)


## ---- eval = FALSE-------------------------------------------------------
## pennies_sample %>%
##   specify(formula = year ~ NULL)


## ----fig.align='center', echo=FALSE, out.width='50%'---------------------
knitr::include_graphics("images/flowcharts/infer/generate.png")


## ------------------------------------------------------------------------
pennies_sample %>% 
  specify(response = year) %>% 
  generate(reps = 1000, type = "bootstrap")


## ----eval=FALSE----------------------------------------------------------
## # infer workflow:               # Original workflow:
## pennies_sample %>%              pennies_sample %>%
##   specify(response = year) %>%    rep_sample_n(size = 50, replace = TRUE, reps = 1000)
##   generate(reps = 1000)


## ----fig.align='center', echo=FALSE, out.width='70%'---------------------
knitr::include_graphics("images/flowcharts/infer/calculate.png")


## ------------------------------------------------------------------------
bootstrap_distribution <- pennies_sample %>% 
  specify(response = year) %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "mean")
bootstrap_distribution


## ----eval=FALSE----------------------------------------------------------
## # infer workflow:               # Original workflow:
## pennies_sample %>%              pennies_sample %>%
##   specify(response = year) %>%    rep_sample_n(size = 50, replace = TRUE, reps = 1000)
##   generate(reps = 1000) %>%       group_by(replicate) %>%
##   calculate(stat = "mean")        summarize(mean_year = mean(year))


## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/visualize.png")


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution %>%
##   visualize()



## ----eval=FALSE----------------------------------------------------------
## # infer workflow:             # Original workflow:
## bootstrap_distribution %>%    ggplot(bootstrap_distribution, aes(x = stat)) +
##   visualize()                   geom_histogram()




## ------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution %>%
##   visualize() +
##   shade_confidence_interval(endpoints = c(1991.28, 1999.76))



## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution %>%
##   visualize() +
##   shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")

## ----echo=FALSE----------------------------------------------------------
# Will need to make a tweak to the {infer} package so that it doesn't always display "Null" here
bootstrap_distribution %>% 
  visualize() + 
  ggtitle("Simulation-Based Bootstrap Distribution") +
  shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")


## ------------------------------------------------------------------------
standard_error_ci <- bootstrap_distribution %>% 
  get_confidence_interval(type = "se", point_estimate = 1995.44)
standard_error_ci


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution %>%
##   visualize() +
##   shade_confidence_interval(endpoints = standard_error_ci)



## ------------------------------------------------------------------------
bowl %>% 
  summarize(p_red = mean(color == "red"))

## ---- echo = FALSE-------------------------------------------------------
p_red <- bowl %>% 
  summarize(prop_red = mean(color == "red")) %>% 
  pull(prop_red)


## ------------------------------------------------------------------------
bowl_sample_1


## ---- eval=FALSE---------------------------------------------------------
## bowl_sample_1 %>%
##   specify(response = color)


## ------------------------------------------------------------------------
bowl_sample_1 %>% 
  specify(response = color, success = "red")


## ------------------------------------------------------------------------
bowl_sample_1 %>% 
  specify(response = color, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap")


## ------------------------------------------------------------------------
sample_1_bootstrap <- bowl_sample_1 %>% 
  specify(response = color, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "prop")
sample_1_bootstrap


## ------------------------------------------------------------------------
percentile_ci_1 <- sample_1_bootstrap %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci_1


## ----eval=FALSE----------------------------------------------------------
## sample_1_bootstrap %>%
##   visualize(bins = 15) +
##   shade_confidence_interval(endpoints = c(0.28, 0.56)) +
##   geom_vline(xintercept = 0.375, col = "red")



## ------------------------------------------------------------------------
bowl_sample_2 <- bowl %>% 
  rep_sample_n(size = 50)
bowl_sample_2


## ------------------------------------------------------------------------
sample_2_bootstrap <- bowl_sample_2 %>% 
  specify(response = color, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "prop")
sample_2_bootstrap


## ------------------------------------------------------------------------
percentile_ci_2 <- sample_2_bootstrap %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci_2


## ----reliable-percentile, fig.cap="100 SE-based 95% confidence intervals for p",echo=FALSE----
if(!file.exists("rds/balls_percentile_cis.rds")){
  set.seed(4)

  # Function to run infer pipeline
  bootstrap_pipeline <- function(sample_data){
    sample_data %>% 
      specify(formula = color ~ NULL, success = "red") %>% 
      generate(reps = 1000, type = "bootstrap") %>% 
      calculate(stat = "prop")
  }
  
  # Compute nested data frame with sampled data, sample proportions, all 
  # bootstrap replicates, and percentile_ci
  balls_percentile_cis <- bowl %>% 
    rep_sample_n(size = 50, reps = 100, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(sample_prop = map_dbl(data, ~mean(.x$color == "red"))) %>%
    # run infer pipeline on each nested tibble to generated bootstrap replicates
    mutate(bootstraps = map(data, bootstrap_pipeline)) %>% 
    group_by(replicate) %>% 
    # Compute 95% percentile CI's for each nested element
    mutate(percentile_ci = map(bootstraps, get_ci, type = "percentile", level = 0.95))
  
  # Save output to rds object
  saveRDS(object = balls_percentile_cis, "rds/balls_percentile_cis.rds")
} else {
  balls_percentile_cis <- readRDS("rds/balls_percentile_cis.rds")
}

# Identify if confidence interval captured true p
percentile_cis <- balls_percentile_cis %>% 
  unnest(percentile_ci) %>% 
  mutate(captured = `2.5%` <= p_red & p_red <= `97.5%`)

# Plot them!
ggplot(percentile_cis) +
  geom_segment(aes(y = replicate, yend = replicate, x = `2.5%`, xend = `97.5%`, color = captured)) +
  geom_point(aes(x = sample_prop, y = replicate, color = captured)) +
  labs(x = expression("Proportion of red balls"), y = "Replicate ID") +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = p_red, color = "red") 


## ----reliable-se, fig.cap="100 SE-based 85% confidence intervals for p",echo=FALSE----
if(!file.exists("rds/balls_se_cis.rds")){
  # Set random number generator seed value to 9 in honour of Maurice "Rocket" Richard.
  set.seed(9)
  
  # Function to run infer pipeline
  bootstrap_pipeline <- function(sample_data){
    sample_data %>% 
      specify(formula = color ~ NULL, success = "red") %>% 
      generate(reps = 1000, type = "bootstrap") %>% 
      calculate(stat = "prop")
  }
  
  # Compute nested data frame with sampled data, sample proportions, all 
  # bootstrap replicates, and se_ci
  balls_se_cis <- bowl %>% 
    rep_sample_n(size = 50, reps = 100, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(sample_prop = map_dbl(data, ~mean(.x$color == "red"))) %>%
    # run infer pipeline on each nested tibble to generated bootstrap replicates
    mutate(bootstraps = map(data, bootstrap_pipeline)) %>% 
    group_by(replicate) %>% 
    # Compute 95% se CI's for each nested element
    mutate(se_ci = map(bootstraps, get_ci, type = "se", level = 0.85,
                       point_estimate = sample_prop))
  
  # Save output to rds object
  saveRDS(object = balls_se_cis, "rds/balls_se_cis.rds")
} else {
  balls_se_cis <- readRDS("rds/balls_se_cis.rds")
}

# Identify if confidence interval captured true p
se_cis <- balls_se_cis %>% 
  unnest(se_ci) %>% 
  mutate(captured = lower <= p_red & p_red <= upper)

# Plot them!
ggplot(se_cis) +
  geom_segment(aes(y = replicate, yend = replicate, x = lower, xend = upper, color = captured)) +
  geom_point(aes(x = sample_prop, y = replicate, color = captured)) +
  labs(x = expression("Proportion of red balls"), y = "Replicate ID") +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = p_red, color = "red") 


## ----perc-sizes, echo=FALSE----------------------------------------------
if(!file.exists("rds/balls_perc_cis_80_95_99.rds")){
  set.seed(9)
  
  # Function to run infer pipeline:
  infer_pipeline <- function(entry, ci_level){
    entry %>% 
      specify(formula = color ~ NULL, success = "red") %>% 
      generate(reps = 1000, type = "bootstrap") %>% 
      calculate(stat = "prop") %>% 
      get_ci(level = ci_level)
  }
  
  # Compute 80% percentile CI's for each nested element
  perc_cis_80 <- bowl %>% 
    rep_sample_n(size = 50, reps = 10, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(
      percentile_ci = map(data, infer_pipeline, ci_level = 0.8),
      point_estimate = map_dbl(data, ~mean(.x$color == "red"))
    ) %>% 
    unnest(percentile_ci) %>% 
    rename(lower = `10%`, upper = `90%`) %>% 
    select(-data) %>% 
    mutate(confidence_level = "80%")
  
  # Compute 95% percentile CI's for each nested element
  perc_cis_95 <- bowl %>% 
    rep_sample_n(size = 50, reps = 10, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(
      percentile_ci = map(data, infer_pipeline, ci_level = 0.95),
      point_estimate = map_dbl(data, ~mean(.x$color == "red"))
    ) %>% 
    unnest(percentile_ci) %>% 
    rename(lower = `2.5%`, upper = `97.5%`) %>% 
    select(-data) %>% 
    mutate(confidence_level = "95%")
  
  # Compute 99% percentile CI's for each nested element
  perc_cis_99 <- bowl %>% 
    rep_sample_n(size = 50, reps = 10, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(
      percentile_ci = map(data, infer_pipeline, ci_level = 0.99),
      point_estimate = map_dbl(data, ~mean(.x$color == "red"))
    ) %>% 
    unnest(percentile_ci) %>% 
    rename(lower = `0.5%`, upper = `99.5%`) %>% 
    select(-data) %>% 
    mutate(confidence_level = "99%")
  
  # Combine into single data frame
  percentile_cis_by_level <- bind_rows(perc_cis_80, perc_cis_95, perc_cis_99)
  
  # Save output to rds object
  write_rds(percentile_cis_by_level, "rds/balls_perc_cis_80_95_99.rds")
} else {
  percentile_cis_by_level <- read_rds("rds/balls_perc_cis_80_95_99.rds")
}


## ----perc-cis-level-print, echo=FALSE------------------------------------
percentile_cis_by_level %>% 
  sample_n(10) %>% 
  kable(
    digits = 3,
    caption = "10 randomly sampled confidence intervals for p for varying confidence levels", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ----reliable-percentile-80-95-99, fig.cap="Ten 80%, 95%, & 99% confidence intervals for p based on n = 50.", echo=FALSE----
sample_of_cis <- percentile_cis_by_level %>% 
  group_by(confidence_level) %>% 
  mutate(sample_row = 1:10)

ggplot(sample_of_cis) +
  geom_point(aes(x = point_estimate, y = sample_row)) +
  geom_segment(aes(y = sample_row, yend = sample_row, x = lower, xend = upper)) +
  labs(x = expression("Proportion of red balls"), y = "") +
  scale_y_continuous(breaks = 1:10) +
  facet_wrap(~confidence_level) + 
  geom_vline(xintercept = p_red, color = "red")


## ----perc-cis-average-width, echo=FALSE----------------------------------
percentile_cis_by_level %>% 
  mutate(width = upper - lower) %>% 
  group_by(confidence_level) %>% 
  summarize(`Mean width` = mean(width)) %>% 
  rename(`Confidence level` = confidence_level) %>% 
  kable(
    digits = 3,
    caption = "Mean width of 80%, 95%, & 99% confidence intervals.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ----perc-sizes-2, echo=FALSE--------------------------------------------
if(!file.exists("rds/balls_perc_cis_n_25_50_100.rds")){
  set.seed(9)
  
  # Function to run infer pipeline:
  infer_pipeline <- function(entry, ci_level){
    entry %>% 
      specify(formula = color ~ NULL, success = "red") %>% 
      generate(reps = 1000, type = "bootstrap") %>% 
      calculate(stat = "prop") %>% 
      get_ci(level = 0.95)
  }
  
  # Compute 95% percentile CI's based on n=25 for each nested element
  perc_cis_n_25 <- bowl %>% 
    rep_sample_n(size = 25, reps = 10, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(
      percentile_ci = map(data, infer_pipeline),
      point_estimate = map_dbl(data, ~mean(.x$color == "red"))
    ) %>% 
    unnest(percentile_ci) %>% 
    rename(lower = `2.5%`, upper = `97.5%`) %>% 
    select(-data) %>%
    mutate(sample_size = "n = 25")
  
  # Compute 95% percentile CI's based on n=50 for each nested element
  perc_cis_n_50 <- bowl %>% 
    rep_sample_n(size = 50, reps = 10, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(
      percentile_ci = map(data, infer_pipeline),
      point_estimate = map_dbl(data, ~mean(.x$color == "red"))
    ) %>% 
    unnest(percentile_ci) %>% 
    rename(lower = `2.5%`, upper = `97.5%`) %>% 
    select(-data) %>%
    mutate(sample_size = "n = 50")
  
  # Compute 95% percentile CI's based on n=100 for each nested element
  perc_cis_n_100 <- bowl %>% 
    rep_sample_n(size = 100, reps = 10, replace = FALSE) %>% 
    group_by(replicate) %>% 
    nest() %>% 
    mutate(
      percentile_ci = map(data, infer_pipeline),
      point_estimate = map_dbl(data, ~mean(.x$color == "red"))
    ) %>% 
    unnest(percentile_ci) %>% 
    rename(lower = `2.5%`, upper = `97.5%`) %>% 
    select(-data) %>%
    mutate(sample_size = "n = 100")
  
  # Combine into single data frame
  percentile_cis_by_n <- bind_rows(perc_cis_n_25, perc_cis_n_50, perc_cis_n_100) %>% 
    mutate(sample_size = factor(sample_size, levels = c("n = 25", "n = 50", "n = 100")))
  
  # Save output to rds object
  write_rds(percentile_cis_by_n, "rds/balls_perc_cis_n_25_50_100.rds")
} else {
  percentile_cis_by_n <- read_rds("rds/balls_perc_cis_n_25_50_100.rds")
}


## ----reliable-percentile-n-25-50-100, fig.cap="Ten 95% confidence intervals for p based on n = 25, 50, & 100.", echo=FALSE----
sample_of_cis <- percentile_cis_by_n %>% 
  group_by(sample_size) %>% 
  mutate(sample_row = 1:10)

ggplot(sample_of_cis) +
  geom_point(aes(x = point_estimate, y = sample_row)) +
  geom_segment(aes(y = sample_row, yend = sample_row, x = lower, xend = upper)) +
  labs(x = expression("Proportion of red balls"), y = "") +
  scale_y_continuous(breaks = 1:10) +
  facet_wrap(~sample_size) + 
  geom_vline(xintercept = p_red, color = "red")


## ----perc-cis-average-width-2, echo=FALSE--------------------------------
percentile_cis_by_n %>% 
  mutate(width = upper - lower) %>% 
  group_by(sample_size) %>% 
  summarize(`Mean width` = mean(width)) %>% 
  rename(`Sample size` = sample_size) %>% 
  kable(
    digits = 3,
    caption = "Mean width of 95% confidence intervals based on n = 25, 50, & 100.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ------------------------------------------------------------------------
mythbusters_yawn


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  group_by(group, yawn) %>% 
  summarize(count = n())


## ----summarytable-ch8-c, echo=FALSE, message=FALSE-----------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  # Only first two scenarios
  filter(Scenario <= 3) %>% 
  kable(
    caption = "\\label{tab:summarytable-ch8}Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position")) %>%
  column_spec(1, width = "0.5in") %>% 
  column_spec(2, width = "0.7in") %>%
  column_spec(3, width = "1in") %>%
  column_spec(4, width = "1.1in") %>% 
  column_spec(5, width = "1in")


## ----eval=FALSE----------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group)


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes")


## ------------------------------------------------------------------------
head(mythbusters_yawn)


## ------------------------------------------------------------------------
head(mythbusters_yawn) %>% 
  sample_n(size = 6, replace = TRUE)


## ----eval=TRUE-----------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  generate(reps = 1000, type = "bootstrap")


## ---- eval=FALSE---------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props")


## ------------------------------------------------------------------------
bootstrap_distribution_yawning <- mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))
bootstrap_distribution_yawning


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution_yawning %>%
##   visualize()



## ------------------------------------------------------------------------
bootstrap_distribution_yawning %>% 
  get_confidence_interval(type = "percentile", level = 0.95)

## ----include=FALSE-------------------------------------------------------
myth_ci_percentile <- bootstrap_distribution_yawning %>% 
  get_confidence_interval(type = "percentile", level = 0.95)


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  # generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))


## ------------------------------------------------------------------------
bootstrap_distribution_yawning %>% 
  get_confidence_interval(type = "se", point_estimate = 0.0441176)

## ----include=FALSE-------------------------------------------------------
myth_ci_se <- bootstrap_distribution_yawning %>% 
  get_confidence_interval(type = "se", point_estimate = 0.0441176)




## ----echo=FALSE----------------------------------------------------------
set.seed(76)

## ------------------------------------------------------------------------
# Take 1000 virtual samples of size 50 from the bowl:
virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 1000)

# Compute the sampling distribution of 1000 values of p-hat
sampling_distribution <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

# Visualize sampling distribution of p-hat
ggplot(sampling_distribution, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
  labs(x = "Proportion of 50 balls that were red", title = "Sampling distribution")


## ------------------------------------------------------------------------
sampling_distribution %>% 
  summarize(se = sd(prop_red))

## ---- echo=FALSE---------------------------------------------------------
se_samp <- sampling_distribution %>% 
  summarize(se = sd(prop_red)) %>% 
  pull(se)


## ----echo=FALSE----------------------------------------------------------
set.seed(76)

## ------------------------------------------------------------------------
# Compute the bootstrap distribution using infer workflow:
bootstrap_distribution <- bowl_sample_1 %>% 
  specify(response = color, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "prop")

# Visualize bootstrap distribution of p-hat
bootstrap_distribution %>% 
  visualize(binwidth = 0.05, boundary = 0.4, color = "white") + 
  labs(x = "Proportion of 50 balls that were red", title = "Bootstrap distribution")


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  summarize(se = sd(stat))

## ---- echo=FALSE---------------------------------------------------------
se_boot <- bootstrap_distribution %>% 
  summarize(se = sd(stat)) %>% 
  pull(se)


## ----side-by-side, fig.height = 7, fig.cap="Comparing the sampling and bootstrap distributions of p-hat", echo=FALSE----
x_lim <- seq(from = 0.15, to = 0.65, by = 0.05)
y_lim <- c(0, 350)
p_samp <- ggplot(sampling_distribution, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, fill = "salmon", color = "white") +
  coord_cartesian(xlim = x_lim, ylim = y_lim) +
  labs(x = "", title = "Sampling distribution") +
  geom_vline(xintercept = p_red, size = 1, col = "red")
p_boot <- ggplot(bootstrap_distribution, aes(x = stat)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, fill = "blue", color = "white") + 
  coord_cartesian(xlim = x_lim, ylim = y_lim) +
  labs(x = "Proportion of 50 balls that were red", title = "Bootstrap distribution") +
  geom_vline(xintercept = p_red, size = 1, col = "red") +
  geom_vline(xintercept = 0.42, size = 1, linetype = "dashed")
p_samp + p_boot + plot_layout(ncol = 1, heights = c(1, 1))


## ----comparing-se, echo=FALSE, message=FALSE-----------------------------
tibble(
  `Distribution type` = c("Sampling distribution", "Bootstrap distribution"),
  `Standard error` = c(se_samp, se_boot)
) %>% 
  kable(
    caption = "Comparing standard errors", 
    digits = 3, 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ---- eval=TRUE, message=FALSE, warning=FALSE----------------------------
conf_ints <- tactile_prop_red %>% 
  rename(p_hat = prop_red) %>% 
  mutate(
    n = 50,
    SE = sqrt(p_hat * (1 - p_hat) / n),
    MoE = 1.96 * SE,
    lower_ci = p_hat - MoE,
    upper_ci = p_hat + MoE
  )
conf_ints


## ----tactile-conf-int, echo=FALSE, message=FALSE, warning=FALSE, fig.cap= "33 95% confidence intervals based on 33 tactile samples of size n=50", fig.height=6----
conf_ints <- conf_ints %>% 
  mutate(
    y = 1:n(),
    p = 900 / 2400,
    captured = lower_ci <= p & p <= upper_ci
  )
groups <- conf_ints$group

ggplot(conf_ints) +
  geom_point(aes(x = p_hat, y = y, col = captured)) +
  geom_vline(xintercept = 900 / 2400, col = "red") +
  geom_segment(aes(y = y, yend = y, x = lower_ci, xend = upper_ci, col = captured)) +
  scale_y_continuous(breaks = 1:33, labels = groups) +
  labs(x = expression("Proportion red"), y = "") +
  scale_color_manual(values = c("blue", "orange")) 


## ------------------------------------------------------------------------
# First: Take 100 virtual samples of n=50 balls
virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 100)

# Second: For each virtual sample compute the proportion red
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

# Third: Compute the 95% confidence interval as above
virtual_prop_red <- virtual_prop_red %>% 
  rename(p_hat = prop_red) %>% 
  mutate(
    n = 50,
    SE = sqrt(p_hat*(1-p_hat)/n),
    MoE = 1.96 * SE,
    lower_ci = p_hat - MoE,
    upper_ci = p_hat + MoE
  )


## ----virtual-conf-int, echo=FALSE, message=FALSE, warning=FALSE, fig.height=6, fig.cap="100 confidence intervals based on 100 virtual samples of size n=50"----
set.seed(79)

virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 100)

# Second: For each virtual sample compute the proportion red
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

# Third: Compute the 95% confidence interval as above
virtual_prop_red <- virtual_prop_red %>% 
  rename(p_hat = prop_red) %>% 
  mutate(
    n = 50,
    SE = sqrt(p_hat * (1 - p_hat) / n),
    MoE = 1.96 * SE,
    lower_ci = p_hat - MoE,
    upper_ci = p_hat + MoE
  ) %>% 
  mutate(
    y = seq_len(n()),
    p = 900 / 2400,
    captured = lower_ci <= p & p <= upper_ci
  )

ggplot(virtual_prop_red) +
  geom_point(aes(x = p_hat, y = y, color = captured)) +
  geom_segment(aes(y = y, yend = y, x = lower_ci, xend = upper_ci, 
                   color = captured)) +
  labs(
    x = expression("Proportion red"),
    y = "Replicate ID",
    title = expression(paste("95% confidence intervals for ", p, sep = ""))
  ) +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = 900 / 2400, color = "red") 

