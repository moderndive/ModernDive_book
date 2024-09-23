## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)










## -----------------------------------------------------------------------------
pennies_sample


## ----pennies-sample-histogram, fig.cap="Distribution of year on 50 US pennies."----
ggplot(pennies_sample, aes(x = year)) +
  geom_histogram(binwidth = 10, color = "white")


## -----------------------------------------------------------------------------
x_bar <- pennies_sample %>% 
  summarize(mean_year = mean(year))
x_bar












## -----------------------------------------------------------------------------
pennies_resample <- tibble(
  year = c(1976, 1962, 1976, 1983, 2017, 2015, 2015, 1962, 2016, 1976, 
           2006, 1997, 1988, 2015, 2015, 1988, 2016, 1978, 1979, 1997, 
           1974, 2013, 1978, 2015, 2008, 1982, 1986, 1979, 1981, 2004, 
           2000, 1995, 1999, 2006, 1979, 2015, 1979, 1998, 1981, 2015, 
           2000, 1999, 1988, 2017, 1992, 1997, 1990, 1988, 2006, 2000)
)




## ----eval=FALSE---------------------------------------------------------------
## ggplot(pennies_resample, aes(x = year)) +
##   geom_histogram(binwidth = 10, color = "white") +
##   labs(title = "Resample of 50 pennies")
## ggplot(pennies_sample, aes(x = year)) +
##   geom_histogram(binwidth = 10, color = "white") +
##   labs(title = "Original sample of 50 pennies")




## -----------------------------------------------------------------------------
pennies_resample %>% 
  summarize(mean_year = mean(year))







## -----------------------------------------------------------------------------
pennies_resamples


## -----------------------------------------------------------------------------
resampled_means <- pennies_resamples %>% 
  group_by(name) %>% 
  summarize(mean_year = mean(year))
resampled_means




## ----eval=FALSE---------------------------------------------------------------
## virtual_shovel <- bowl %>%
##   rep_sample_n(size = 50)


## -----------------------------------------------------------------------------
virtual_resample <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE)


## -----------------------------------------------------------------------------
virtual_resample


## -----------------------------------------------------------------------------
virtual_resample %>% 
  summarize(resample_mean = mean(year))


## -----------------------------------------------------------------------------
virtual_resamples <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 35)
virtual_resamples


## -----------------------------------------------------------------------------
virtual_resampled_means <- virtual_resamples %>% 
  group_by(replicate) %>% 
  summarize(mean_year = mean(year))
virtual_resampled_means


## ----tactile-resampling-7, fig.cap="Distribution of 35 sample means from 35 resamples."----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
  labs(x = "Resample mean year")




## -----------------------------------------------------------------------------
# Repeat resampling 1000 times
virtual_resamples <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1000)

# Compute 1000 sample means
virtual_resampled_means <- virtual_resamples %>% 
  group_by(replicate) %>% 
  summarize(mean_year = mean(year))


## -----------------------------------------------------------------------------
virtual_resampled_means <- pennies_sample %>% 
  rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>% 
  group_by(replicate) %>% 
  summarize(mean_year = mean(year))
virtual_resampled_means


## ----one-thousand-sample-means, message=FALSE, fig.cap="Bootstrap resampling distribution based on 1000 resamples."----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1990) +
  labs(x = "sample mean")


## -----------------------------------------------------------------------------
virtual_resampled_means %>% 
  summarize(mean_of_means = mean(mean_year))











## ----percentile-method, echo=FALSE, message=FALSE, fig.cap="(ref:perc-method)", fig.height=3.4----
ggplot(virtual_resampled_means, aes(x = mean_year)) +
  geom_histogram(binwidth = 1, color = "white", boundary = 1988) +
  labs(x = "Resample sample mean") +
  scale_x_continuous(breaks = seq(1988, 2006, 2)) +
  geom_vline(xintercept = percentile_ci[[1, 1]], size = 1) +
  geom_vline(xintercept = percentile_ci[[1, 2]], size = 1)




## -----------------------------------------------------------------------------
virtual_resampled_means %>% 
  summarize(SE = sd(mean_year))




## ----eval=FALSE---------------------------------------------------------------
## standard_error_ci <- bootstrap_distribution %>%
##   get_ci(type = "se", point_estimate = x_bar)
## standard_error_ci






## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000)


## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>%
##   group_by(replicate)


## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   rep_sample_n(size = 50, replace = TRUE, reps = 1000) %>%
##   group_by(replicate) %>%
##   summarize(mean_year = mean(year))


## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   summarize(stat = mean(year))


## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   specify(response = year) %>%
##   calculate(stat = "mean")




## -----------------------------------------------------------------------------
pennies_sample %>% 
  specify(response = year)


## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   specify(formula = year ~ NULL)




## ----eval=FALSE---------------------------------------------------------------
## pennies_sample %>%
##   specify(response = year) %>%
##   generate(reps = 1000, type = "bootstrap")








## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution <- pennies_sample %>%
##   specify(response = year) %>%
##   generate(reps = 1000) %>%
##   calculate(stat = "mean")
## bootstrap_distribution








## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution)








## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = percentile_ci)




## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")


## -----------------------------------------------------------------------------
standard_error_ci <- bootstrap_distribution %>% 
  get_confidence_interval(type = "se", point_estimate = x_bar)
standard_error_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = standard_error_ci)








## -----------------------------------------------------------------------------
bowl %>% 
  summarize(p_red = mean(color == "red"))



## -----------------------------------------------------------------------------
bowl_sample_1




## ----eval=FALSE---------------------------------------------------------------
## bowl_sample_1 %>%
##   specify(response = color)


## -----------------------------------------------------------------------------
bowl_sample_1 %>% 
  specify(response = color, success = "red")


## ----eval=FALSE---------------------------------------------------------------
## bowl_sample_1 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap")



## ----eval=FALSE---------------------------------------------------------------
## sample_1_bootstrap <- bowl_sample_1 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "prop")
## sample_1_bootstrap




## -----------------------------------------------------------------------------
percentile_ci_1 <- sample_1_bootstrap %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci_1


## ----eval=FALSE---------------------------------------------------------------
## sample_1_bootstrap %>%
##   visualize(bins = 15) +
##   shade_confidence_interval(endpoints = percentile_ci_1) +
##   geom_vline(xintercept = 0.42, linetype = "dashed")




## -----------------------------------------------------------------------------
bowl_sample_2 <- bowl %>% rep_sample_n(size = 50)
bowl_sample_2


## ----eval=FALSE---------------------------------------------------------------
## sample_2_bootstrap <- bowl_sample_2 %>%
##   specify(response = color,
##           success = "red") %>%
##   generate(reps = 1000,
##            type = "bootstrap") %>%
##   calculate(stat = "prop")
## sample_2_bootstrap




## -----------------------------------------------------------------------------
percentile_ci_2 <- sample_2_bootstrap %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci_2




















## -----------------------------------------------------------------------------
mythbusters_yawn




## -----------------------------------------------------------------------------
mythbusters_yawn %>% 
  group_by(group, yawn) %>% 
  summarize(count = n())




## ----eval=FALSE---------------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group)


## -----------------------------------------------------------------------------
mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes")


## -----------------------------------------------------------------------------
first_six_rows <- head(mythbusters_yawn)
first_six_rows


## -----------------------------------------------------------------------------
first_six_rows %>% 
  sample_n(size = 6, replace = TRUE)


## ----eval=FALSE---------------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap")




## ----eval=FALSE---------------------------------------------------------------
## mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props")


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution_yawning <- mythbusters_yawn %>%
##   specify(formula = yawn ~ group, success = "yes") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props", order = c("seed", "control"))
## bootstrap_distribution_yawning




## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution_yawning) +
##   geom_vline(xintercept = 0)



## -----------------------------------------------------------------------------
bootstrap_distribution_yawning %>% 
  get_confidence_interval(type = "percentile", level = 0.95)



## -----------------------------------------------------------------------------
obs_diff_in_props <- mythbusters_yawn %>% 
  specify(formula = yawn ~ group, success = "yes") %>% 
  # generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "diff in props", order = c("seed", "control"))
obs_diff_in_props


## -----------------------------------------------------------------------------
myth_ci_se <- bootstrap_distribution_yawning %>% 
  get_confidence_interval(type = "se", point_estimate = obs_diff_in_props)
myth_ci_se




## ----echo=FALSE---------------------------------------------------------------
set.seed(76)


## ----sampling-distribution-part-deux, fig.show="hold", fig.cap="Previously seen sampling distribution of sample proportion red for $n = 1000$.", fig.height=2----
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
  labs(x = "Proportion of 50 balls that were red", 
       title = "Sampling distribution")


## -----------------------------------------------------------------------------
sampling_distribution %>% summarize(se = sd(prop_red))



## ----echo=FALSE---------------------------------------------------------------
set.seed(76)


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution <- bowl_sample_1 %>%
##   specify(response = color, success = "red") %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "prop")






## -----------------------------------------------------------------------------
bootstrap_distribution %>% summarize(se = sd(stat))









## ----message=FALSE------------------------------------------------------------
conf_ints <- tactile_prop_red %>% 
  rename(p_hat = prop_red) %>% 
  mutate(
    n = 50,
    SE = sqrt(p_hat * (1 - p_hat) / n),
    MoE = 1.96 * SE,
    lower_ci = p_hat - MoE,
    upper_ci = p_hat + MoE
  )








## ----eval=FALSE---------------------------------------------------------------
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

