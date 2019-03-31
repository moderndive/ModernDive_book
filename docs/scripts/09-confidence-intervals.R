## ----message=FALSE, warning=FALSE----------------------------------------
library(tidyverse)
library(moderndive)
library(infer)
library(janitor)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in the text
library(knitr)
library(kableExtra)
library(patchwork)
# Ensure pennies_sample_2 is loaded (might not be needed)
data("pennies_sample_2")








## ------------------------------------------------------------------------
pennies_sample_2


## ------------------------------------------------------------------------
ggplot(pennies_sample_2, aes(x = year)) +
  geom_histogram(binwidth = 10, color = "white")


## ------------------------------------------------------------------------
x_bar <- pennies_sample_2 %>% 
  summarize(stat = mean(year))


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/pennies_resample.rds")){
  pennies_resample <- pennies_sample_2 %>% 
    rep_sample_n(size = 50, replace = TRUE, reps = 1) %>% 
    ungroup() %>% 
    select(-replicate)
  write_rds(pennies_resample, "rds/pennies_resample.rds")
} else {
  pennies_resample <- read_rds("rds/pennies_resample.rds")
}

pennies_resample





## ----eval=FALSE----------------------------------------------------------
## ggplot(pennies_sample_2, aes(x = year)) +
##   geom_histogram(binwidth = 10, color = "white") +
##   labs(title = "50 US pennies labelled")
## ggplot(pennies_resample, aes(x = year)) +
##   geom_histogram(binwidth = 10, color = "white") +
##   labs(title = "50 resampled US pennies labelled")




## ------------------------------------------------------------------------
resample_mean <- pennies_resample %>% 
  summarize(stat = mean(year))




## ----echo=FALSE----------------------------------------------------------
# Remove this after the activity is done
# Maybe switch `friend` to be `group`?
tactile_resample_means <- virtual_resample_means %>% 
  rownames_to_column(var = "friend") %>% 
  select(friend, replicate, stat)


## ---- eval=FALSE---------------------------------------------------------
## tactile_resample_means
## View(tactile_resample_means)


## ----tactile-resample-means, echo=FALSE----------------------------------
tactile_resample_means %>% 
  slice(1:10) %>% 
  kable(
    digits = 3,
    caption = "\\label{tab:tactile-resample-means}First 10 out of 33 friends' mean age of 50 resampled pennies.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ----eval=FALSE----------------------------------------------------------
## ggplot(tactile_resample_means, mapping = aes(x = stat)) +
##   geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
##   scale_x_continuous(breaks = seq(1990, 2000, 2))

## ----resamplingdistribution-tactile, echo=FALSE, fig.cap="Distribution of 33 means based on 33 resamples of size 50"----
tactile_histogram <- ggplot(tactile_resample_means, 
                            mapping = aes(x = stat)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
  scale_x_continuous(breaks = seq(1990, 2000, 2))
tactile_histogram + 
  labs(x = "Mean age of pennies", 
       title = "Distribution of means from 33 resamples")


## ----eval=FALSE----------------------------------------------------------
## virtual_resample <- pennies_sample_2 %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1)


## ----eval=FALSE----------------------------------------------------------
## View(virtual_resample)


## ----virtual-resample, echo=FALSE----------------------------------------
virtual_resample <- pennies_sample_2 %>% 
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


## ----eval=FALSE----------------------------------------------------------
## virtual_resamples <- pennies_sample_2 %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 33)
## View(virtual_resamples)


## ----echo=FALSE----------------------------------------------------------
virtual_resamples <- pennies_sample_2 %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 33)


## ---- eval=FALSE---------------------------------------------------------
## virtual_resample_means <- virtual_resamples %>%
##   group_by(replicate) %>%
##   summarize(stat = mean(year))
## View(virtual_resample_means)


## ----virtual-resample-means, echo=FALSE----------------------------------
virtual_resample_means <- virtual_resamples %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(year))

virtual_resample_means %>% 
  slice(1:10) %>% 
  kable(
 #   digits = 3,
    caption = "First 10 out of 33 means from virtual resamples", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ------------------------------------------------------------------------
ggplot(virtual_resample_means, aes(x = stat)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
  scale_x_continuous(breaks = seq(1990, 2000, 2))




## ------------------------------------------------------------------------
virtual_resample_means <- pennies_sample_2 %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(year))


## ----one-thousand-sample-means, echo=FALSE, message=FALSE, fig.cap="Bootstrap resampling distribution based on 1000 resamples."----
# To get it to look nice I needed to make some tweaks
ggplot(virtual_resample_means, aes(x = stat)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  scale_x_continuous(breaks = seq(1988, 2006, 2))


## ----eval=FALSE----------------------------------------------------------
## virtual_resample_means %>%
##   summarize(mean_of_means = mean(stat))


## ----echo=FALSE----------------------------------------------------------
mean_of_means <- virtual_resample_means %>% 
  summarize(mean(stat)) %>% 
  pull()


## ----echo=FALSE----------------------------------------------------------
percentile_ci <- virtual_resample_means %>% 
  get_ci(level = 0.95, type = "percentile")
ggplot(virtual_resample_means, aes(x = stat)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = percentile_ci[[1, 1]], color = "green", size = 2) +
  geom_vline(xintercept = percentile_ci[[1, 2]], color = "green", size = 2)


## ----eval=FALSE----------------------------------------------------------
## standard_error_ci <- bootstrap_distribution %>%
##   get_ci(type = "se", point_estimate = x_bar)
## standard_error_ci


## ----echo=FALSE----------------------------------------------------------
standard_error_ci <- virtual_resample_means %>% 
  get_ci(type = "se", point_estimate = x_bar)
ggplot(virtual_resample_means, aes(x = stat)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = standard_error_ci[[1, 1]], color = "green", size = 2) +
  geom_vline(xintercept = standard_error_ci[[1, 2]], color = "green", size = 2)


## ----eval=FALSE----------------------------------------------------------
## pennies_sample_2 %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000)


## ----eval=FALSE----------------------------------------------------------
##  pennies_sample_2 %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>%
##   group_by(replicate)


## ----eval=FALSE----------------------------------------------------------
##  bootstrap_distribution <- pennies_sample_2 %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>%
##   group_by(replicate) %>%
##   summarize(stat = mean(year))


## ----echo=FALSE----------------------------------------------------------
bootstrap_distribution <- virtual_resample_means


## ----fig.align='center', echo=FALSE, out.width='30%'---------------------
knitr::include_graphics("images/flowcharts/infer/specify.png")


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  specify(response = year)


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  specify(formula = year ~ NULL)


## ----fig.align='center', echo=FALSE, out.width='70%'---------------------
knitr::include_graphics("images/flowcharts/infer/generate.png")


## ------------------------------------------------------------------------
thousand_bootstrap_samples <- pennies_sample_2 %>% 
  specify(response = year) %>% 
  generate(reps = 1000, type = "bootstrap")


## ------------------------------------------------------------------------
thousand_bootstrap_samples %>% 
  count(replicate)


## ----eval=FALSE----------------------------------------------------------
## # With infer pipeline             # Without infer pipeline
## pennies_sample_2 %>%              pennies_sample_2 %>%
##   specify(response = year) %>%      rep_sample_n(size = 50,
##    generate(reps = 1000)                         replace = TRUE,
##                                                  reps = 1000)


## ----fig.align='center', echo=FALSE, out.width='70%'---------------------
knitr::include_graphics("images/flowcharts/infer/calculate.png")


## ------------------------------------------------------------------------
bootstrap_distribution <- pennies_sample_2 %>% 
  specify(response = year) %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "mean")
bootstrap_distribution


## ----eval=FALSE----------------------------------------------------------
## # With infer pipeline             # Without infer pipeline
## pennies_sample_2 %>%              pennies_sample_2 %>%
##   specify(response = year) %>%      rep_sample_n(size = 50, replace = TRUE,
##   generate(reps = 1000) %>%                      reps = 1000) %>%
##   calculate(stat = "mean")          group_by(replicate) %>%
##                                     summarize(stat = mean(year))


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  summarize(stat = mean(year))


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  specify(response = year) %>% 
  calculate(stat = "mean")


## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/visualize.png")


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution %>% visualize()
## # or
## visualize(bootstrap_distribution)


## ----echo=FALSE----------------------------------------------------------
bootstrap_distribution %>% visualize() +
  ggtitle("Simulation-Based Bootstrap Distribution")




## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  get_ci(level = 0.95, type = "percentile")


## ------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_ci()
percentile_ci


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_ci(endpoints = percentile_ci)


## ----echo=FALSE----------------------------------------------------------
# Will need to make a tweak to the {infer} package
# so that it doesn't always display "Null" here
visualize(bootstrap_distribution) + 
  ggtitle("Simulation-Based Bootstrap Distribution") +
  shade_ci(endpoints = percentile_ci)


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_ci(endpoints = percentile_ci,
##            color = "brown",
##            fill = "khaki")


## ----echo=FALSE----------------------------------------------------------
# Will need to make a tweak to the {infer} package
# so that it doesn't always display "Null" here
visualize(bootstrap_distribution) + 
  ggtitle("Simulation-Based Bootstrap Distribution") +
  shade_ci(endpoints = percentile_ci,
           color = "brown",
           fill = "khaki")


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_ci(endpoints = percentile_ci,
##            color = "hotpink",
##            fill = NULL)


## ----echo=FALSE----------------------------------------------------------
# Will need to make a tweak to the {infer} package
# so that it doesn't always display "Null" here
visualize(bootstrap_distribution) + 
  ggtitle("Simulation-Based Bootstrap Distribution") +
  shade_ci(endpoints = percentile_ci,
           color = "hotpink",
           fill = NULL)


## ------------------------------------------------------------------------
standard_error_ci <- bootstrap_distribution %>% 
  get_ci(type = "se", point_estimate = x_bar)
standard_error_ci


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_ci(endpoints = standard_error_ci)


## ----echo=FALSE----------------------------------------------------------
visualize(bootstrap_distribution) + 
  ggtitle("Simulation-Based Bootstrap Distribution") +
  shade_ci(endpoints = standard_error_ci)


## ----include=FALSE-------------------------------------------------------
color <- c(rep("red", 21), rep("white", 50 - 21)) %>% 
  sample()
tactile_shovel_1 <- tibble::tibble(color)


## ------------------------------------------------------------------------
tactile_shovel_1


## ------------------------------------------------------------------------
p_hat <- tactile_shovel_1 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  calculate(stat = "prop")
p_hat


## ----eval=FALSE----------------------------------------------------------
## tactile_shovel_1 %>%
##   specify(formula = color ~ NULL, success = "red") %>%
##   generate(reps = 10000, type = "bootstrap")


## ----echo=FALSE----------------------------------------------------------
set.seed(2000)
gen <- tactile_shovel_1 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  generate(reps = 10000, type = "bootstrap")


## ----eval=FALSE----------------------------------------------------------
## bootstrap_props <- tactile_shovel_1 %>%
##   specify(formula = color ~ NULL, success = "red") %>%
##   generate(reps = 10000, type = "bootstrap") %>%
##   calculate(stat = "prop")


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/bootstrap_props.rds")){
  bootstrap_props <- gen %>% 
    calculate(stat = "prop")
  write_rds(bootstrap_props, "rds/bootstrap_props.rds")
}
if(file.exists("rds/bootstrap_props.rds")){
  bootstrap_props <- read_rds("rds/bootstrap_props.rds")
}


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_props, bins = 20)


## ----echo=FALSE----------------------------------------------------------
# Will need to make a tweak to the {infer} package
# so that it doesn't always display "Null" here
visualize(bootstrap_props, bins = 20) + 
  ggtitle("Simulation-Based Bootstrap Distribution")


## ------------------------------------------------------------------------
standard_error_ci <- bootstrap_props %>% 
  get_ci(type = "se", level = 0.95, point_estimate = p_hat)
standard_error_ci


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_props, bins = 25) +
##   shade_ci(endpoints = standard_error_ci)


## ----echo=FALSE----------------------------------------------------------
visualize(bootstrap_props, bins = 25) + 
  shade_ci(endpoints = standard_error_ci) +
  ggtitle("Simulation-Based Bootstrap Distribution")


## ------------------------------------------------------------------------
bowl %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  calculate(stat = "prop")


## ------------------------------------------------------------------------
bowl %>% 
  summarize(stat = mean(color == "red"))


## ----echo=FALSE----------------------------------------------------------
p_red <- mean(bowl$color == "red")


## ------------------------------------------------------------------------
bowl_sample_2 <- bowl %>% 
  sample_n(size = 50)


## ------------------------------------------------------------------------
prop_red_2 <- bowl_sample_2 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  calculate(stat = "prop")
standard_error_ci_2 <- bowl_sample_2 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "prop") %>% 
  get_ci(type = "se", point_estimate = prop_red_2)
standard_error_ci_2 


## ----reliable-se, fig.cap="Reliability of 95 percent confidence intervals",echo=FALSE----
set.seed(201)

ball_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 100, replace = FALSE)
nested_balls <- ball_samples %>% 
  group_by(replicate) %>% 
  tidyr::nest() %>% 
  mutate(sample_prop = purrr::map_dbl(data, ~mean(.x$color == "red")))
bootstrap_pipeline <- function(entry){
  entry %>% 
    specify(formula = color ~ NULL, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "prop")
}
if(!file.exists("rds/balls_se_cis.rds")){
  balls_se_cis <- nested_balls %>% 
    mutate(bootstraps = purrr::map(data, bootstrap_pipeline)) %>% 
    group_by(replicate) %>% 
    mutate(se_ci = purrr::map(bootstraps, get_ci, type = "se",
                              level = 0.95,
                              point_estimate = sample_prop))
  saveRDS(object = balls_se_cis, "rds/balls_se_cis.rds")
} else {
  balls_se_cis <- readRDS("rds/balls_se_cis.rds")
}
se_cis <- balls_se_cis %>% 
  tidyr::unnest(se_ci) %>% 
  mutate(captured = lower <= p_red & p_red <= upper)
ggplot(se_cis) +
  geom_point(aes(x = sample_prop, y = replicate, color = captured)) +
  geom_segment(aes(y = replicate, yend = replicate, x = lower, xend = upper, 
                   color = captured)) +
  labs(
    x = expression("Proportion of red balls"),
    y = "Replicate ID",
    title = expression(paste(
      "95% standard error-based confidence intervals for ", p, sep = "")
      )
  ) +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = p_red, color = "red") 


## ----reliable-perc, fig.cap="Reliability of 90 percent confidence intervals", echo=FALSE----
set.seed(201)
balls_samples2 <- bowl %>% 
  rep_sample_n(size = 50, reps = 100, replace = FALSE)
nested_balls2 <- balls_samples2 %>% 
  group_by(replicate) %>% 
  tidyr::nest()
infer_pipeline <- function(entry){
  entry %>% 
    specify(formula = color ~ NULL, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "prop") %>% 
    get_ci(level = 0.9)
}
if(!file.exists("rds/balls_perc_cis.rds")){
  balls_perc_cis <- nested_balls2 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis, "rds/balls_perc_cis.rds")
} else {
  balls_perc_cis <- read_rds("rds/balls_perc_cis.rds")
}
perc_cis <- balls_perc_cis %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `5%`, upper = `95%`) %>% 
  mutate(captured = lower <= p_red & p_red <= upper)
ggplot(perc_cis) +
  geom_point(aes(x = point_estimate, y = replicate, color = captured)) +
  geom_segment(aes(y = replicate, yend = replicate, x = lower, xend = upper, 
                   color = captured)) +
  labs(
    x = expression("Proportion of red balls"),
    y = "Replicate ID",
    title = expression(paste("90% percentile-based confidence intervals for ", 
                             p, sep = ""))
  ) +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = p_red, color = "red") 


## ----perc-sizes, echo=FALSE----------------------------------------------
balls_samples2 <- bowl %>% 
  rep_sample_n(size = 50, reps = 100, replace = FALSE)
nested_balls2 <- balls_samples2 %>% 
  group_by(replicate) %>% 
  tidyr::nest()
infer_pipeline <- function(entry, ci_level){
  entry %>% 
    specify(formula = color ~ NULL, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "prop") %>% 
    get_ci(level = ci_level)
}
if(!file.exists("rds/balls_perc_cis_80.rds")){
  balls_perc_cis_80 <- nested_balls2 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline, ci_level = 0.8)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis_80, "rds/balls_perc_cis_80.rds")
} else {
  balls_perc_cis_80 <- read_rds("rds/balls_perc_cis_80.rds")
}
perc_cis_80 <- balls_perc_cis_80 %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `10%`, upper = `90%`) %>% 
  select(-data) %>% 
  mutate(confidence_level = 80)

if(!file.exists("rds/balls_perc_cis_95.rds")){
  balls_perc_cis_95 <- nested_balls2 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline, ci_level = 0.95)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis_95, "rds/balls_perc_cis_95.rds")
} else {
  balls_perc_cis_95 <- read_rds("rds/balls_perc_cis_95.rds")
}
perc_cis_95 <- balls_perc_cis_95 %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `2.5%`, upper = `97.5%`) %>% 
  select(-data) %>% 
  mutate(confidence_level = 95)

if(!file.exists("rds/balls_perc_cis_99.rds")){
  balls_perc_cis_99 <- nested_balls2 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline, ci_level = 0.99)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis_99, "rds/balls_perc_cis_99.rds")
} else {
  balls_perc_cis_99 <- read_rds("rds/balls_perc_cis_99.rds")
}
perc_cis_99 <- balls_perc_cis_99 %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `0.5%`, upper = `99.5%`) %>% 
  select(-data) %>% 
  mutate(confidence_level = 99)

percentile_cis_by_level <- bind_rows(perc_cis_80, 
                                     perc_cis_95, 
                                     perc_cis_99)


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


## ----echo=FALSE----------------------------------------------------------
sample_of_cis <- percentile_cis_by_level %>% 
  group_by(confidence_level) %>% 
  sample_n(10) %>% 
  mutate(sample_row = 1:10)
ggplot(sample_of_cis) +
  geom_point(aes(x = point_estimate, y = sample_row)) +
  geom_segment(aes(y = sample_row, yend = sample_row, x = lower, xend = upper)) +
  labs(
    x = expression("Proportion of red balls"),
    y = "Row of sample (out of 10)",
    title = expression(paste("90% percentile-based confidence intervals for ", 
                             p, " by level", sep = ""))
  ) +
  scale_y_continuous(breaks = 1:10) +
  facet_wrap(~ confidence_level)


## ------------------------------------------------------------------------
percentile_cis_by_level %>% 
  mutate(width = upper - lower) %>% 
  group_by(confidence_level) %>% 
  summarize(median_width = median(width),
            mean_width = mean(width))


## ----eval=FALSE----------------------------------------------------------
## virtual_samples_25 <- bowl %>%
##   rep_sample_n(size = 25, reps = 1000, replace = FALSE)
## balls_samples_50 <- bowl %>%
##   rep_sample_n(size = 50, reps = 1000, replace = FALSE)
## balls_samples_100 <- bowl %>%
##   rep_sample_n(size = 100, reps = 1000, replace = FALSE)


## ----echo=FALSE----------------------------------------------------------
virtual_samples_25 <- read_rds("rds/virtual_samples_25.rds")
virtual_samples_50 <- read_rds("rds/virtual_samples_50.rds")
virtual_samples_100 <- read_rds("rds/virtual_samples_100.rds")


## ----perc-sample-sizes, echo=FALSE---------------------------------------
nested_balls_25 <- virtual_samples_25 %>% 
  group_by(replicate) %>% 
  tidyr::nest()

nested_balls_50 <- virtual_samples_50 %>% 
  group_by(replicate) %>% 
  tidyr::nest()

nested_balls_100 <- virtual_samples_100 %>% 
  group_by(replicate) %>% 
  tidyr::nest()

infer_pipeline <- function(entry, ci_level){
  entry %>% 
    specify(formula = color ~ NULL, success = "red") %>% 
    generate(reps = 1000, type = "bootstrap") %>% 
    calculate(stat = "prop") %>% 
    get_ci(level = 0.9)
}
if(!file.exists("rds/balls_perc_cis_n_25.rds")){
  balls_perc_cis_n_25 <- nested_balls_25 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis_n_25, "rds/balls_perc_cis_n_25.rds")
} else {
  balls_perc_cis_n_25 <- read_rds("rds/balls_perc_cis_n_25.rds")
}
perc_cis_n_25 <- balls_perc_cis_n_25 %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `5%`, upper = `95%`) %>% 
  select(-data) %>%
  mutate(sample_size = 25)

if(!file.exists("rds/balls_perc_cis_n_50.rds")){
  balls_perc_cis_n_50 <- nested_balls_50 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis_n_50, "rds/balls_perc_cis_n_50.rds")
} else {
  balls_perc_cis_n_50 <- read_rds("rds/balls_perc_cis_n_50.rds")
}
perc_cis_n_50 <- balls_perc_cis_n_50 %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `5%`, upper = `95%`) %>% 
  select(-data) %>%
  mutate(sample_size = 50)

if(!file.exists("rds/balls_perc_cis_n_100.rds")){
  balls_perc_cis_n_100 <- nested_balls_100 %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$color == "red")))
  write_rds(balls_perc_cis_n_100, "rds/balls_perc_cis_n_100.rds")
} else {
  balls_perc_cis_n_100 <- read_rds("rds/balls_perc_cis_n_100.rds")
}
perc_cis_n_100 <- balls_perc_cis_n_100 %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `5%`, upper = `95%`) %>% 
  select(-data) %>%
  mutate(sample_size = 100)

percentile_cis_by_n <- bind_rows(perc_cis_n_25, perc_cis_n_50, perc_cis_n_100)


## ----echo=FALSE----------------------------------------------------------
sample_of_cis <- percentile_cis_by_n %>% 
  group_by(sample_size) %>% 
  sample_n(10) %>% 
  mutate(sample_row = 1:10)
ggplot(sample_of_cis) +
  geom_point(aes(x = point_estimate, y = sample_row)) +
  geom_segment(aes(y = sample_row, yend = sample_row, x = lower, xend = upper)) +
  labs(
    x = expression("Proportion of red balls"),
    y = "Row of sample (out of 10)",
    title = expression(paste("90% percentile-based confidence intervals for ", 
                             p, " by sample size", sep = ""))
  ) +
  scale_y_continuous(breaks = 1:10) +
  facet_wrap(~ sample_size)


## ------------------------------------------------------------------------
percentile_cis_by_n %>% 
  mutate(width = upper - lower) %>% 
  group_by(sample_size) %>% 
  summarize(median_width = median(width),
            mean_width = mean(width))


## ------------------------------------------------------------------------
mythbusters_yawn


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  tabyl(group, yawn) %>% 
  adorn_percentages() %>% 
  adorn_pct_formatting() %>% 
  # To show original counts
  adorn_ns()


## ----eval=FALSE----------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group)


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes")


## ----eval=FALSE----------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   calculate(stat = "diff in props")


## ------------------------------------------------------------------------
obs_diff <- mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))
obs_diff


## ------------------------------------------------------------------------
head(mythbusters_yawn)


## ------------------------------------------------------------------------
head(mythbusters_yawn) %>% 
  sample_n(size = 6, replace = TRUE)


## ------------------------------------------------------------------------
bootstrap_distribution <- mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))


## ----eval=FALSE----------------------------------------------------------
## bootstrap_distribution %>%
##   visualize(bins = 20)


## ----echo=FALSE----------------------------------------------------------
bootstrap_distribution %>% 
  visualize(bins = 20) +
  ggtitle("Simulation-Based Bootstrap Distribution")


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  get_ci(type = "percentile", level = 0.95)


## ----include=FALSE-------------------------------------------------------
myth_ci <- bootstrap_distribution %>% 
  get_ci(type = "percentile", level = 0.95)


## ------------------------------------------------------------------------
thousand_samples <- bowl %>% 
  rep_sample_n(size = 200, reps = 1000, replace = FALSE)


## ------------------------------------------------------------------------
sampling_distribution <- thousand_samples %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(color == "red"))


## ---- fig.cap="Sampling distribution for proportion red for n=200 samples of balls"----
ggplot(sampling_distribution, aes(x = stat)) +
  geom_histogram(bins = 10, fill = "salmon", color = "white")


## ------------------------------------------------------------------------
sampling_distribution %>% 
  summarize(se = sd(stat))


## ------------------------------------------------------------------------
sample_200 <- bowl %>% 
  sample_n(200, replace = FALSE)


## ----eval=FALSE----------------------------------------------------------
## sample_200 %>%
##   specify(formula = color ~ NULL)


## ----eval=FALSE----------------------------------------------------------
## sample_200 %>%
##   specify(formula = color ~ NULL, success = "red")


## ----echo=FALSE----------------------------------------------------------
set.seed(2019)
spec_200 <- sample_200 %>% 
  specify(formula = color ~ NULL, success = "red")
spec_200


## ----eval=FALSE----------------------------------------------------------
## sample_200 %>%
##   specify(formula = color ~ NULL, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap")


## ----echo=FALSE----------------------------------------------------------
gen_200 <- sample_200 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap")
gen_200


## ------------------------------------------------------------------------
bootstrap_distribution_n_200 <- sample_200 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "prop")
bootstrap_distribution_n_200


## ----eval=FALSE----------------------------------------------------------
## visualize(bootstrap_distribution_n_200, bins = 10, fill = "blue")


## ----echo=FALSE----------------------------------------------------------
visualize(bootstrap_distribution_n_200, bins = 10, fill = "blue") +
  ggtitle("Simulation-Based Bootstrap Distribution")


## ----fig.cap="Comparing sampling and bootstrap distributions", echo=FALSE----
p_samp <- ggplot(sampling_distribution, aes(x = stat)) +
  geom_histogram(bins = 10, fill = "salmon", color = "white") +
  coord_cartesian(xlim = seq(0.25, 0.50, 0.05), ylim = seq(0, 300, 50)) +
  labs(title = "Sampling distribution for n = 200")
p_boot <- ggplot(bootstrap_distribution_n_200, aes(x = stat)) +
  geom_histogram(bins = 10, fill = "blue", color = "white") +
  coord_cartesian(xlim = seq(0.25, 0.50, 0.05), ylim = seq(0, 300, 50)) +
  labs(title = "Bootstrap distribution for n = 200")
p_samp + p_boot


## ------------------------------------------------------------------------
sampling_distribution %>% 
  summarize(se = sd(stat))


## ------------------------------------------------------------------------
bootstrap_distribution_n_200 %>% 
  summarize(se = sd(stat))


## ------------------------------------------------------------------------
sampling_distribution %>% 
  summarize(mean_of_sampling_means = mean(stat))


## ------------------------------------------------------------------------
bootstrap_distribution_n_200 %>% 
  summarize(mean_of_bootstrap_means = mean(stat))


## ---- eval=FALSE, message=FALSE, warning=FALSE---------------------------
## tactile_prop_red


## ---- eval=FALSE, message=FALSE, warning=FALSE---------------------------
## conf_ints <- tactile_prop_red %>%
##   rename(p_hat = prop_red) %>%
##   mutate(
##     n = 50,
##     SE = sqrt(p_hat * (1 - p_hat) / n),
##     MoE = 1.96 * SE,
##     lower_ci = p_hat - MoE,
##     upper_ci = p_hat + MoE
##   )
## conf_ints

## ---- echo=FALSE, message=FALSE, warning=FALSE---------------------------
conf_ints <- tactile_prop_red %>% 
  rename(p_hat = prop_red) %>% 
  select(-replicate) %>% 
  mutate(
    n = 50, 
    SE = sqrt(p_hat*(1-p_hat)/n),
    MoE = 1.96*SE,
    lower_ci = p_hat - MoE,
    upper_ci = p_hat + MoE,
    y = seq_len(n())
  )
conf_ints %>% 
  select(-y) %>% 
  kable(
    digits = 3,
    caption = "33 confidence intervals from 33 tactile samples of size n=50", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header", 
                                  "scale_down"))


## ----tactile-conf-int, echo=FALSE, message=FALSE, warning=FALSE, fig.cap= "33 confidence intervals based on 33 tactile samples of size n=50", fig.height=6----
groups <- conf_ints$group
conf_ints %>%
  mutate(p = 900 / 2400,
         captured = lower_ci <= p & p <= upper_ci) %>%
  ggplot() +
  geom_point(aes(x = p_hat, y = y, col = captured)) +
  geom_vline(xintercept = 900 / 2400, col = "red") +
  geom_segment(aes(
    y = y,
    yend = y,
    x = lower_ci,
    xend = upper_ci,
    col = captured
  )) +
  scale_y_continuous(breaks = 1:33, labels = groups) +
  labs(x = expression("Proportion red"),
       y = "",
       title = expression(paste("95% confidence intervals for ", p, 
                                sep = ""))) +
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


## ----std-normal-setup, echo=FALSE----------------------------------------
ggplot(data = data.frame(x = c(-3.5, 3.5)), aes(x)) +
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1)) + 
  scale_x_continuous(breaks = seq(-3.5, 3.5, 0.5)) +
  ylab("") +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())


## ----std-normal, echo=FALSE----------------------------------------------
ggplot(data = data.frame(x = c(-3.5, 3.5)), aes(x)) +
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1)) + 
  scale_x_continuous(breaks = seq(-3.5, 3.5, 0.5)) +
  ylab("") +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  geom_vline(xintercept = 1.96, color = "green", size = 2) +
  geom_vline(xintercept = -1.96, color = "green", size = 2)


## ------------------------------------------------------------------------
qnorm(p = 0.95)


## ------------------------------------------------------------------------
qnorm(p = 0.025)






## ----summarytable-ch9, echo=FALSE, message=FALSE-------------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  kable(
    caption = "\\label{tab:summarytable-ch9}Scenarios of sampling for inference", 
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

