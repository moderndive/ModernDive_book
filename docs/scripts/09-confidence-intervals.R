## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(janitor)
library(moderndive)
library(infer)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in the text
library(knitr)
library(kableExtra)
library(stringr)
library(patchwork)
library(tibble)
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
pennies_resample <- pennies_sample_2 %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1) %>% 
  ungroup() %>% 
  select(-replicate)
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
    caption = "First 10 out of 33 friends' mean age of 50 resampled pennies.", 
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


## ------------------------------------------------------------------------
virtual_resample %>% 
  summarize(resample_mean = mean(year)) %>% 
  pull()


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
    digits = 3,
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


## ----echo=FALSE, message=FALSE-------------------------------------------
# To get it to look nice I needed to make some tweaks
ggplot(virtual_resample_means, aes(x = stat)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  scale_x_continuous(breaks = seq(1988, 2006, 2))


## ------------------------------------------------------------------------
bootstrap_sample1 <- pennies_sample_2 %>% 
  rep_sample_n(size = 40, replace = TRUE, reps = 1)
bootstrap_sample1


## ------------------------------------------------------------------------
ggplot(bootstrap_sample1, aes(x = year)) +
  geom_histogram(bins = 10, color = "white")


## ------------------------------------------------------------------------
bootstrap_sample1 %>% 
  summarize(stat = mean(year))


## ------------------------------------------------------------------------
six_bootstrap_samples <- pennies_sample_2 %>% 
  rep_sample_n(size = 40, replace = TRUE, reps = 6)


## ------------------------------------------------------------------------
ggplot(six_bootstrap_samples, aes(x = year)) +
  geom_histogram(bins = 10, color = "white") +
  facet_wrap(~ replicate)


## ------------------------------------------------------------------------
six_bootstrap_samples %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(year))


## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/specify.png")


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  specify(response = year)


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  specify(formula = year ~ NULL)


## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/generate.png")


## ------------------------------------------------------------------------
thousand_bootstrap_samples <- pennies_sample_2 %>% 
  specify(response = year) %>% 
  generate(reps = 1000)


## ------------------------------------------------------------------------
thousand_bootstrap_samples %>% 
  count(replicate)


## ----fig.align='center', echo=FALSE--------------------------------------
knitr::include_graphics("images/flowcharts/infer/calculate.png")


## ------------------------------------------------------------------------
bootstrap_distribution <- pennies_sample_2 %>% 
  specify(response = year) %>% 
  generate(reps = 1000) %>% 
  calculate(stat = "mean")
bootstrap_distribution


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  summarize(stat = mean(year))


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  specify(response = year) %>% 
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
ggplot(pennies, aes(x = year)) +
  geom_histogram(bins = 10, color = "white")


## ------------------------------------------------------------------------
pennies %>% 
  summarize(mean_age = mean(year),
            median_age = median(year))


## ------------------------------------------------------------------------
ggplot(pennies_sample_2, aes(x = year)) +
  geom_histogram(bins = 10, color = "white")


## ------------------------------------------------------------------------
pennies_sample_2 %>% 
  summarize(mean_age = mean(year), median_age = median(year))


## ------------------------------------------------------------------------
thousand_samples <- pennies %>% 
  rep_sample_n(size = 40, reps = 1000, replace = FALSE)


## ------------------------------------------------------------------------
sampling_distribution <- thousand_samples %>% 
  group_by(replicate) %>% 
  summarize(stat = mean(year))


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
  summarize(overall_mean = mean(year))


## ----include=FALSE-------------------------------------------------------
pennies_mu <- pennies %>% 
  summarize(overall_mean = mean(year)) %>% 
  pull()


## ------------------------------------------------------------------------
pennies_sample_2 <- pennies %>% 
  sample_n(size = 40)


## ------------------------------------------------------------------------
percentile_ci2 <- pennies_sample_2 %>% 
  specify(formula = year ~ NULL) %>% 
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
    specify(formula = year ~ NULL) %>% 
    generate(reps = 1000) %>% 
    calculate(stat = "mean") %>% 
    get_ci()
}

if(!file.exists("rds/pennies_cis.rds")){
  pennies_cis <- nested_pennies %>% 
    mutate(percentile_ci = purrr::map(data, infer_pipeline)) %>% 
    mutate(point_estimate = purrr::map_dbl(data, ~mean(.x$year)))
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
  mutate(sample_mean = purrr::map_dbl(data, ~mean(.x$year)))

bootstrap_pipeline <- function(entry){
  entry %>% 
    specify(formula = year ~ NULL) %>% 
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

