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


## ----table-ch8-b, echo=FALSE, message=FALSE------------------------------
# The following Google Doc is published to CSV and loaded using read_csv():
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

if(!file.exists("rds/sampling_scenarios.rds")){
  sampling_scenarios <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
    read_csv(na = "")
    write_rds(table_ch3, "rds/sampling_scenarios.rds")
} else {
  sampling_scenarios <- read_rds("rds/sampling_scenarios.rds")
}

sampling_scenarios %>%  
  # Only first two scenarios
  filter(Scenario <= 2) %>% 
  kable(
    caption = "Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position")) %>%
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






## ------------------------------------------------------------------------
virtual_resample <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE)


## ------------------------------------------------------------------------
virtual_resample


## ------------------------------------------------------------------------
virtual_resample %>% 
  summarize(resample_mean = mean(year))


## ------------------------------------------------------------------------
virtual_resamples <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 35)
virtual_resamples


## ------------------------------------------------------------------------
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


## ----one-thousand-sample-means, message=FALSE, fig.cap="Bootstrap resampling distribution based on 1000 resamples."----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
  labs(x = "sample mean")


## ----eval=TRUE-----------------------------------------------------------
virtual_resampled_means %>% 
  summarize(mean_of_means = mean(mean_year))

## ----echo=FALSE----------------------------------------------------------
mean_of_means <- virtual_resampled_means %>% 
  summarize(mean(mean_year)) %>% 
  pull() %>% 
  round(2)








## ----echo=FALSE----------------------------------------------------------
# Can also use conf_int() and get_confidence_interval() instead of get_ci(),
# as they are aliases that work the exact same way.
percentile_ci <- virtual_resampled_means %>% 
  rename(stat = mean_year) %>% 
  get_ci(level = 0.95, type = "percentile")


## ----percentile-method, echo=FALSE, message=FALSE, fig.cap="Percentile method 95 percent confidence interval. Interval marked by vertical lines."----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  labs(x = "Resample sample mean") +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = percentile_ci[[1, 1]], size = 1) +
  geom_vline(xintercept = percentile_ci[[1, 2]], size = 1)


## ----echo=FALSE----------------------------------------------------------
# Can also use get_confidence_interval() instead of get_ci(),
# as it is an alias that works the exact same way.
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


## ----percentile-and-se-method, echo=FALSE, message=FALSE, fig.cap="Comparing two 95 percent confidence interval methods."----
both_CI <- bind_rows(
  percentile_ci %>% gather(endpoint, value) %>% mutate(type = "percentile"),
  standard_error_ci %>% gather(endpoint, value) %>% mutate(type = "SE")
)
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  labs(x = "sample mean", title = "Percentile method CI (solid lines), SE method CI (dashed lines)") +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = percentile_ci[[1, 1]], size = 1) +
  geom_vline(xintercept = percentile_ci[[1, 2]], size = 1) + 
  geom_vline(xintercept = standard_error_ci[[1, 1]], linetype = "dashed", size = 1) +
  geom_vline(xintercept = standard_error_ci[[1, 2]], linetype = "dashed", size = 1)


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


## ---- eval=FALSE---------------------------------------------------------
## pennies_sample %>%
##   summarize(stat = mean(year))


## ---- eval=FALSE---------------------------------------------------------
## pennies_sample %>%
##   specify(response = year) %>%
##   calculate(stat = "mean")




## ------------------------------------------------------------------------
pennies_sample %>% 
  specify(response = year)


## ---- eval=FALSE---------------------------------------------------------
## pennies_sample %>%
##   specify(formula = year ~ NULL)




## ----eval=FALSE----------------------------------------------------------
## pennies_sample %>%
##   specify(response = year) %>%
##   generate(reps = 1000, type = "bootstrap")


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/pennies_sample_generate.rds")){
  pennies_sample_generate <- pennies_sample %>% 
    specify(response = year) %>% 
    generate(reps = 1000, type = "bootstrap")
  write_rds(pennies_sample_generate, "rds/pennies_sample_generate.rds")
} else {
  pennies_sample_generate <- read_rds("rds/pennies_sample_generate.rds")
}
pennies_sample_generate


## ----eval=FALSE----------------------------------------------------------
## # infer workflow:                   # Original workflow:
## pennies_sample %>%                  pennies_sample %>%
##   specify(response = year) %>%        rep_sample_n(size = 50, replace = TRUE,
##   generate(reps = 1000)                            reps = 1000)
## 




## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution <- pennies_sample %>%
##   specify(response = year) %>%
##   generate(reps = 1000) %>%
##   calculate(stat = "mean")
## bootstrap_distribution


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/bootstrap_distribution_pennies.rds")){
  bootstrap_distribution <- pennies_sample %>% 
    specify(response = year) %>% 
    generate(reps = 1000) %>% 
    calculate(stat = "mean")
  write_rds(bootstrap_distribution, "rds/bootstrap_distribution_pennies.rds")
} else {
  bootstrap_distribution <- read_rds("rds/bootstrap_distribution_pennies.rds")
}
bootstrap_distribution


## ----eval=FALSE----------------------------------------------------------
## # infer workflow:                   # Original workflow:
## pennies_sample %>%                  pennies_sample %>%
##   specify(response = year) %>%        rep_sample_n(size = 50, replace = TRUE,
##   generate(reps = 1000) %>%                        reps = 1000) %>%
##   calculate(stat = "mean")            group_by(replicate) %>%
##                                       summarize(mean_year = mean(year))




## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution)




## ----eval=FALSE----------------------------------------------------------
## # infer workflow:                    # Original workflow:
## visualize(bootstrap_distribution)    ggplot(bootstrap_distribution,
##                                             aes(x = stat)) +
##                                        geom_histogram()




## ------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = percentile_ci)




## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")


## ------------------------------------------------------------------------
standard_error_ci <- bootstrap_distribution %>% 
  get_confidence_interval(type = "se", point_estimate = 1995.44)
standard_error_ci


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = standard_error_ci)







## ------------------------------------------------------------------------
bowl %>% 
  summarize(p_red = mean(color == "red"))

## ---- echo=FALSE---------------------------------------------------------
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


## ----eval=FALSE----------------------------------------------------------
## bowl_sample_1 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap")

## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/bowl_sample_1_generate.rds")){
   bowl_sample_1_generate <- bowl_sample_1 %>% 
    specify(response = color, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap")
   write_rds(bowl_sample_1_generate, 
             "rds/bowl_sample_1_generate.rds")
} else {
  bowl_sample_1_generate <- read_rds("rds/bowl_sample_1_generate.rds")
}
bowl_sample_1_generate


## ----eval=FALSE----------------------------------------------------------
## sample_1_bootstrap <- bowl_sample_1 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "prop")
## sample_1_bootstrap


## ----calculate_prop, echo=FALSE------------------------------------------
# Note this takes a few minutes to run
if(!file.exists("rds/sample_1_bootstrap.rds")){
  sample_1_bootstrap <- bowl_sample_1_generate %>% 
    calculate(stat = "prop")
  write_rds(sample_1_bootstrap, "rds/sample_1_bootstrap.rds")
} else {
  sample_1_bootstrap <- read_rds("rds/sample_1_bootstrap.rds")
}
sample_1_bootstrap


## ------------------------------------------------------------------------
percentile_ci_1 <- sample_1_bootstrap %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci_1


## ----eval=FALSE----------------------------------------------------------
## sample_1_bootstrap %>%
##   visualize(bins = 15) +
##   shade_confidence_interval(endpoints = percentile_ci_1) +
##   geom_vline(xintercept = 0.375, linetype = "dashed")



## ------------------------------------------------------------------------
bowl_sample_2 <- bowl %>% 
  rep_sample_n(size = 50)
bowl_sample_2


## ----eval=FALSE----------------------------------------------------------
## sample_2_bootstrap <- bowl_sample_2 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "prop")
## sample_2_bootstrap


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/sample_2_bootstrap.rds")){
  sample_2_bootstrap <- bowl_sample_2 %>% 
    specify(response = color, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "prop")
  write_rds(sample_2_bootstrap, "rds/sample_2_bootstrap.rds")
} else {
  sample_2_bootstrap <- read_rds("rds/sample_2_bootstrap.rds")
}
sample_2_bootstrap


## ------------------------------------------------------------------------
percentile_ci_2 <- sample_2_bootstrap %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci_2


## ----reliable-percentile, fig.cap="100 percentile-based 95 percent confidence intervals for $p$.",echo=FALSE----
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
  geom_segment(aes(
    y = replicate, yend = replicate, x = `2.5%`, xend = `97.5%`, 
    alpha = factor(captured, levels = c("TRUE", "FALSE"))
  )) +
  # Removed point estimates since it doesn't necessarily act as center for 
  # percentile-based CI's
  # geom_point(aes(x = sample_prop, y = replicate, color = captured)) +
  labs(x = expression("Proportion of red balls"), y = "Confidence interval number", 
       alpha = "Captured") +
  geom_vline(xintercept = p_red, color = "red") + 
  coord_cartesian(xlim = c(0.1, 0.7)) + 
  theme_light() + 
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank())


## ----reliable-se, fig.cap="100 SE-based 80 percent confidence intervals for $p$ with point estimate center marked with dots.",echo=FALSE----
if(!file.exists("rds/balls_se_cis.rds")){
  # Set random number generator seed value.
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
    # Compute 80% se CI's for each nested element
    mutate(se_ci = map(bootstraps, get_ci, type = "se", level = 0.80,
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
  geom_segment(aes(
    y = replicate, yend = replicate, x = lower, xend = upper, 
    alpha = factor(captured, levels = c("TRUE", "FALSE"))
  )) +
  geom_point(
    aes(
      x = sample_prop, y = replicate,
      alpha = factor(captured, levels = c("TRUE", "FALSE"))
    ), 
    show.legend = FALSE, size = 1) +
  labs(x = expression("Proportion of red balls"), y = "Confidence interval number", 
       alpha = "Captured") +
  geom_vline(xintercept = p_red, color = "red") + 
  coord_cartesian(xlim = c(0.1, 0.7)) + 
  theme_light() + 
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank())


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


## ----perc-cis-level-print, eval=FALSE, echo=FALSE------------------------
## percentile_cis_by_level %>%
##   sample_n(10) %>%
##   kable(
##     digits = 3,
##     caption = "10 randomly sampled confidence intervals for p for varying confidence levels",
##     booktabs = TRUE,
##     longtable = TRUE
##   ) %>%
##   kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
##                 latex_options = c("hold_position", "repeat_header"))


## ----reliable-percentile-80-95-99, fig.cap="Ten 80, 95, and 99 percent confidence intervals for $p$ based on $n = 50$.", echo=FALSE----
sample_of_cis <- percentile_cis_by_level %>% 
  group_by(confidence_level) %>% 
  mutate(sample_row = 1:10)

ggplot(sample_of_cis) +
  # Doesn't make sense to show point_estimate center for percentile confidence 
  # intervals:
  # geom_point(aes(x = point_estimate, y = sample_row)) +
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
    caption = "Average width of 80, 95, and 99 percent confidence intervals.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position", "repeat_header"))


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


## ----reliable-percentile-n-25-50-100, fig.cap="Ten 95 percent confidence intervals for $p$ based on n = 25, 50, and 100.", echo=FALSE----
sample_of_cis <- percentile_cis_by_n %>% 
  group_by(sample_size) %>% 
  mutate(sample_row = 1:10)

ggplot(sample_of_cis) +
  # Doesn't make sense to show point_estimate center for percentile confidence 
  # intervals:
  # geom_point(aes(x = point_estimate, y = sample_row)) +
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
    caption = "Average width of 95 percent confidence intervals based on n = 25, 50, and 100.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position", "repeat_header"))


## ------------------------------------------------------------------------
mythbusters_yawn


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  group_by(group, yawn) %>% 
  summarize(count = n())


## ----table-ch8-c, echo=FALSE, message=FALSE------------------------------
# The following Google Doc is published to CSV and loaded using read_csv():
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

if(!file.exists("rds/sampling_scenarios.rds")){
  sampling_scenarios <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
    read_csv(na = "")
  write_rds(table_ch3, "rds/sampling_scenarios.rds")
} else {
  sampling_scenarios <- read_rds("rds/sampling_scenarios.rds")
}

sampling_scenarios %>% 
  # Only first two scenarios
  filter(Scenario <= 3) %>% 
  kable(
    caption = "Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position")) %>%
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


## ----eval=FALSE----------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap")




## ---- eval=FALSE---------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props")


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution_yawning <- mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props", order = c("seed", "control"))
## bootstrap_distribution_yawning


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/bootstrap_distribution_yawning.rds")){
  bootstrap_distribution_yawning <- mythbusters_yawn %>% 
    specify(formula = yawn ~ group, success = "yes") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "diff in props", order = c("seed", "control"))
  write_rds(bootstrap_distribution_yawning,
            "rds/bootstrap_distribution_yawning.rds")
} else {
  bootstrap_distribution_yawning <- read_rds(
    "rds/bootstrap_distribution_yawning.rds")
}
bootstrap_distribution_yawning


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution_yawning) +
##   geom_vline(xintercept = 0)



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
sampling_distribution %>% 
  summarize(se = sd(prop_red))

## ---- echo=FALSE---------------------------------------------------------
se_samp <- sampling_distribution %>% 
  summarize(se = sd(prop_red)) %>% 
  pull(se)


## ----echo=FALSE----------------------------------------------------------
set.seed(76)


## ----eval=FALSE----------------------------------------------------------
## # Compute the bootstrap distribution using infer workflow:
## bootstrap_distribution <- bowl_sample_1 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "prop")


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/bootstrap_distribution_balls.rds")){
  bootstrap_distribution <- bowl_sample_1 %>% 
    specify(response = color, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "prop")
  write_rds(bootstrap_distribution, 
            "rds/bootstrap_distribution_balls.rds")
} else {
  bootstrap_distribution <- read_rds("rds/bootstrap_distribution_balls.rds")
}




## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  summarize(se = sd(stat))

## ---- echo=FALSE---------------------------------------------------------
se_boot <- bootstrap_distribution %>% 
  summarize(se = sd(stat)) %>% 
  pull(se)


## ----side-by-side, fig.height=7.5, fig.cap="Comparing the sampling and bootstrap distributions of $\\widehat{p}$", echo=FALSE----
p_samp <- ggplot(sampling_distribution, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, fill = "salmon", 
                 color = "white") +
  labs(x = "", title = "Sampling distribution") +
  geom_vline(xintercept = p_red, size = 1) +
  scale_x_continuous(limits = c(0.15, 0.65), 
                     breaks = seq(from = 0.15, to = 0.65, by = 0.1)) + 
  scale_y_continuous(limits = c(0, 350), 
                     breaks = seq(from = 0, to = 400, by = 100))
p_boot <- ggplot(bootstrap_distribution, aes(x = stat)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, fill = "blue", 
                 color = "white") + 
  labs(x = "Proportion of 50 balls that were red", 
       title = 
         "Bootstrap distribution: similar shape & spread but different center"
       ) +
  geom_vline(xintercept = 0.42, size = 1, linetype = "dashed") +
  scale_x_continuous(limits = c(0.15, 0.65), 
                     breaks = seq(from = 0.15, to = 0.65, by = 0.1)) + 
  scale_y_continuous(limits = c(0, 350), breaks = seq(from = 0, 
                                                      to = 400, by = 100))
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
                latex_options = c("hold_position", "repeat_header"))


## ----comparing-se-2, echo=FALSE, message=FALSE---------------------------
tibble(
  `Distribution type` = c("Sampling distribution", "Bootstrap distribution", 
                          "Formula approximation"),
  `Standard error` = c(se_samp, se_boot, 0.0698)
) %>% 
  kable(
    caption = "Comparing standard errors", 
    digits = 3, 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position", "repeat_header"))


## ---- message=FALSE, warning=FALSE---------------------------------------
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


## ----tactile-conf-int, echo=FALSE, message=FALSE, warning=FALSE, fig.cap= "33 95 percent confidence intervals based on 33 tactile samples of size n = 50.", fig.height=6----
conf_ints <- conf_ints %>% 
  mutate(
    y = 1:n(),
    p = 900 / 2400,
    captured = lower_ci <= p & p <= upper_ci
  )
groups <- conf_ints$group

ggplot(conf_ints) +
  geom_point(
    aes(
      x = p_hat, y = y, 
      alpha = factor(captured, levels = c("TRUE", "FALSE"))
    ),
    show.legend = FALSE
  ) +
  geom_vline(xintercept = 900 / 2400, col = "red") +
  geom_segment(aes(
    y = y, yend = y, x = lower_ci, xend = upper_ci, 
    alpha = factor(captured, levels = c("TRUE", "FALSE"))
  )) +
  scale_y_continuous(breaks = 1:33, labels = groups) +
  labs(x = expression("Proportion of red balls"), y = "Confidence interval number", 
       alpha = "Captured") + 
  theme_light() + 
  theme(panel.grid.major.y = element_blank(), panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank())


## ----eval=FALSE----------------------------------------------------------
## # First: Take 100 virtual samples of n=50 balls
## virtual_samples <- bowl %>%
##   rep_sample_n(size = 50, reps = 100)
## 
## # Second: For each virtual sample compute the proportion red
## virtual_prop_red <- virtual_samples %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 50)
## 
## # Third: Compute the 95% confidence interval as before
## virtual_prop_red <- virtual_prop_red %>%
##   rename(p_hat = prop_red) %>%
##   mutate(
##     n = 50,
##     SE = sqrt(p_hat*(1-p_hat)/n),
##     MoE = 1.96 * SE,
##     lower_ci = p_hat - MoE,
##     upper_ci = p_hat + MoE
##   )


## ----virtual-conf-int, eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE, fig.height=6, fig.cap="100 confidence intervals based on 100 virtual samples of size n = 50."----
## set.seed(79)
## 
## virtual_samples <- bowl %>%
##   rep_sample_n(size = 50, reps = 100)
## 
## # Second: For each virtual sample compute the proportion red
## virtual_prop_red <- virtual_samples %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 50)
## 
## # Third: Compute the 95% confidence interval as before
## virtual_prop_red <- virtual_prop_red %>%
##   rename(p_hat = prop_red) %>%
##   mutate(
##     n = 50,
##     SE = sqrt(p_hat * (1 - p_hat) / n),
##     MoE = 1.96 * SE,
##     lower_ci = p_hat - MoE,
##     upper_ci = p_hat + MoE
##   ) %>%
##   mutate(
##     y = seq_len(n()),
##     p = 900 / 2400,
##     captured = lower_ci <= p & p <= upper_ci
##   )
## 
## ggplot(virtual_prop_red) +
##   geom_point(aes(x = p_hat, y = y, color = captured)) +
##   geom_segment(aes(y = y, yend = y, x = lower_ci, xend = upper_ci,
##                    color = captured)) +
##   labs(
##     x = expression("Proportion red"),
##     y = "Replicate ID",
##     title = expression(paste("95% confidence intervals for ", p, sep = ""))
##   ) +
##   geom_vline(xintercept = 900 / 2400, color = "red")

