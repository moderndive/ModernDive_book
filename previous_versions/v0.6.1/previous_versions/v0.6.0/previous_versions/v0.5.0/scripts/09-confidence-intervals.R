## ----summarytable-prep, echo=FALSE, message=FALSE------------------------
library(dplyr)
library(readr)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)


## ----summarytable, echo=FALSE, message=FALSE-----------------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  kable(
    caption = "\\label{tab:summarytable}Scenarios of sampling for inference", 
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


## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(janitor)
library(moderndive)
library(infer)


## ----include=FALSE-------------------------------------------------------
set.seed(2018)
pennies_sample <- pennies %>% 
  sample_n(40)


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
thousand_bootstrap_samples %>% 
  count(replicate)


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
bootstrap_distribution %>% 
  visualize()




## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  visualize(obs_stat = x_bar)


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


## ----eval=FALSE----------------------------------------------------------
## standard_error_ci <- bootstrap_distribution %>%
##   get_ci(type = "se", point_estimate = x_bar)
## standard_error_ci


## ----echo=FALSE----------------------------------------------------------
standard_error_ci <- bootstrap_distribution %>% 
  get_ci(type = "se", point_estimate = x_bar)
round(standard_error_ci, 2)


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  visualize(endpoints = standard_error_ci, direction = "between")


## ------------------------------------------------------------------------
ggplot(pennies, aes(x = age_in_2011)) +
  geom_histogram(bins = 10, color = "white")


## ------------------------------------------------------------------------
pennies %>% 
  summarize(mean_age = mean(age_in_2011),
            median_age = median(age_in_2011))


## ------------------------------------------------------------------------
ggplot(pennies_sample, aes(x = age_in_2011)) +
  geom_histogram(bins = 10, color = "white")


## ------------------------------------------------------------------------
pennies_sample %>% 
  summarize(mean_age = mean(age_in_2011), median_age = median(age_in_2011))


## ------------------------------------------------------------------------
thousand_samples <- pennies %>% 
  rep_sample_n(size = 40, reps = 1000, replace = FALSE)


## ------------------------------------------------------------------------
sampling_distribution <- thousand_samples %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(age_in_2011))


## ---- fig.cap="Sampling distribution for n=40 samples of pennies"--------
ggplot(sampling_distribution, aes(x = stat)) +
  geom_histogram(bins = 10, fill = "salmon", color = "white")


## ------------------------------------------------------------------------
sampling_distribution %>% 
  summarize(se = sd(stat))


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  visualize(bins = 10, fill = "blue")


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  summarize(se = sd(stat))


## ------------------------------------------------------------------------
sampling_distribution %>% 
  summarize(mean_of_sampling_means = mean(stat))


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  summarize(mean_of_bootstrap_means = mean(stat))


## ------------------------------------------------------------------------
pennies %>% 
  summarize(overall_mean = mean(age_in_2011))


## ----include=FALSE-------------------------------------------------------
pennies_mu <- pennies %>% 
  summarize(overall_mean = mean(age_in_2011)) %>% 
  pull()


## ------------------------------------------------------------------------
pennies_sample2 <- pennies %>% 
  sample_n(size = 40)


## ------------------------------------------------------------------------
percentile_ci2 <- pennies_sample2 %>% 
  specify(formula = age_in_2011 ~ NULL) %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "mean") %>% 
  get_ci()
percentile_ci2


## ----echo=FALSE----------------------------------------------------------
set.seed(201)

pennies_samples <- pennies %>% 
  rep_sample_n(size = 40, reps = 100, replace = FALSE)

nested_pennies <- pennies_samples %>% 
  group_by(replicate) %>% 
  tidyr::nest()

infer_pipeline <- function(entry){
  entry %>% 
    specify(formula = age_in_2011 ~ NULL) %>% 
    generate(reps = 1000) %>% 
    calculate(stat = "mean") %>% 
    get_ci()
}

if(!file.exists("rds/pennies_cis.rds")){
  pennies_cis <- nested_pennies %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$age_in_2011)))
  saveRDS(object = pennies_cis, "rds/pennies_cis.rds")
} else {
  pennies_cis <- readRDS("rds/pennies_cis.rds")
}

perc_cis <- pennies_cis %>% 
  tidyr::unnest(percentile_ci) %>% 
  rename(lower = `2.5%`, upper = `97.5%`) %>% 
  mutate(captured = lower <= pennies_mu & pennies_mu <= upper)

ggplot(perc_cis) +
  geom_point(aes(x = point_estimate, y = replicate, color = captured)) +
  geom_segment(aes(y = replicate, yend = replicate, x = lower, xend = upper, 
                   color = captured)) +
  labs(
    x = expression("Age in 2011 (Years)"),
    y = "Replicate ID",
    title = expression(paste("95% percentile-based confidence intervals for ", 
                             mu, sep = ""))
  ) +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = pennies_mu, color = "red") 


## ----echo=FALSE----------------------------------------------------------
set.seed(2019)

pennies_samples2 <- pennies %>% 
  rep_sample_n(size = 40, reps = 100, replace = FALSE)

nested_pennies2 <- pennies_samples2 %>% 
  group_by(replicate) %>% 
  tidyr::nest() %>% 
  mutate(sample_mean = purrr::map_dbl(data, ~mean(.x$age_in_2011)))

bootstrap_pipeline <- function(entry){
  entry %>% 
    specify(formula = age_in_2011 ~ NULL) %>% 
    generate(reps = 1000) %>% 
    calculate(stat = "mean")
}

if(!file.exists("rds/pennies_se_cis.rds")){
  pennies_se_cis <- nested_pennies2 %>% 
    mutate(bootstraps = purrr::map(data, bootstrap_pipeline)) %>% 
    group_by(replicate) %>% 
    mutate(se_ci = purrr::map(bootstraps, get_ci, type = "se",
                              level = 0.9,
                              point_estimate = sample_mean))
  saveRDS(object = pennies_se_cis, "rds/pennies_se_cis.rds")
} else {
  pennies_se_cis <- readRDS("rds/pennies_se_cis.rds")
}

se_cis <- pennies_se_cis %>% 
  tidyr::unnest(se_ci) %>% 
  mutate(captured = lower <= pennies_mu & pennies_mu <= upper)

ggplot(se_cis) +
  geom_point(aes(x = sample_mean, y = replicate, color = captured)) +
  geom_segment(aes(y = replicate, yend = replicate, x = lower, xend = upper, 
                   color = captured)) +
  labs(
    x = expression("Age in 2011 (Years)"),
    y = "Replicate ID",
    title = expression(paste(
      "90% standard error-based confidence intervals for ", mu, sep = "")
      )
  ) +
  scale_color_manual(values = c("blue", "orange")) + 
  geom_vline(xintercept = pennies_mu, color = "red") 


## ----include=FALSE-------------------------------------------------------
color <- c(rep("red", 21), rep("white", 50 - 21)) %>% 
  sample()
tactile_shovel1 <- tibble::tibble(color)


## ------------------------------------------------------------------------
tactile_shovel1


## ------------------------------------------------------------------------
p_hat <- tactile_shovel1 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  calculate(stat = "prop")
p_hat


## ----eval=FALSE----------------------------------------------------------
## tactile_shovel1 %>%
##   specify(formula = color ~ NULL, success = "red") %>%
##   generate(reps = 10000)


## ----echo=FALSE----------------------------------------------------------
set.seed(2018)
gen <- tactile_shovel1 %>% 
  specify(formula = color ~ NULL, success = "red") %>% 
  generate(reps = 10000)


## ----eval=FALSE----------------------------------------------------------
## bootstrap_props <- tactile_shovel1 %>%
##   specify(formula = color ~ NULL, success = "red") %>%
##   generate(reps = 10000) %>%
##   calculate(stat = "prop")


## ----echo=FALSE----------------------------------------------------------
bootstrap_props <- gen %>% 
  calculate(stat = "prop")


## ------------------------------------------------------------------------
bootstrap_props %>% 
  visualize(bins = 25)


## ------------------------------------------------------------------------
standard_error_ci <- bootstrap_props %>% 
  get_ci(type = "se", level = 0.95, point_estimate = p_hat)
standard_error_ci


## ------------------------------------------------------------------------
bootstrap_props %>% 
  visualize(bins = 25, endpoints = standard_error_ci)


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


## ------------------------------------------------------------------------
mythbusters_yawn


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  tabyl(group, yawn) %>% 
  adorn_percentages() %>% 
  adorn_pct_formatting() %>% 
  # To show original counts
  adorn_ns()


## ----error=TRUE----------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group)


## ------------------------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes")


## ----error=TRUE----------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  calculate(stat = "diff in props")


## ----error=TRUE----------------------------------------------------------
obs_diff <- mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))
obs_diff


## ------------------------------------------------------------------------
head(mythbusters_yawn)


## ------------------------------------------------------------------------
set.seed(2019)


## ------------------------------------------------------------------------
head(mythbusters_yawn) %>% 
  sample_n(size = 6, replace = TRUE)


## ------------------------------------------------------------------------
bootstrap_distribution <- mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  visualize(bins = 20)


## ------------------------------------------------------------------------
bootstrap_distribution %>% 
  get_ci(type = "percentile", level = 0.95)


## ----include=FALSE-------------------------------------------------------
myth_ci <- bootstrap_distribution %>% 
  get_ci(type = "percentile", level = 0.95)

