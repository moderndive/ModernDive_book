## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)




## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/almonds_sample_100.rds")) {
  set.seed(20)
  almonds_sample_100 <- almonds_bowl |>
    rep_slice_sample(n = 100, replace = TRUE, reps = 1)
  write_rds(almonds_sample_100, "rds/almonds_sample_100.rds")
} else {
  almonds_sample_100 <- read_rds("rds/almonds_sample_100.rds")
}
almonds_sample_100


## ----echo=FALSE---------------------------------------------------------------
num_almonds <- nrow(almonds_bowl)
almonds_sample <- read_rds("rds/almonds_sample.rds")




## -----------------------------------------------------------------------------
almonds_sample_100 |>
    summarize(sample_mean = mean(weight))


## ----echo=F-------------------------------------------------------------------
xbar <- mean(almonds_sample_100$weight)


## ----echo=FALSE---------------------------------------------------------------
num_almonds <- nrow(almonds_bowl)
almonds_sample <- read_rds("rds/almonds_sample.rds")


## ----echo=-1------------------------------------------------------------------
pop_sd <- function(x) sqrt(mean(x^2) - mean(x)^2)


## -----------------------------------------------------------------------------
almonds_bowl |> 
  summarize(population_mean = mean(weight), 
            population_sd = pop_sd(weight))


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/almonds_sample_100.rds")) {
  set.seed(20)
  almonds_sample_100 <- almonds_bowl |>
    rep_slice_sample(n = 100, replace = TRUE, reps = 1)
  write_rds(almonds_sample_100, "rds/almonds_sample_100.rds")
} else {
  almonds_sample_100 <- read_rds("rds/almonds_sample_100.rds")
}


## -----------------------------------------------------------------------------
almonds_sample_100


## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  summarize(mean_weight = mean(weight), 
            sd_weight = sd(weight), 
            sample_size = n())






## ----normal-curve-shaded-1a, echo=FALSE, fig.height=2, fig.width=3------------
 ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1)) +
    geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1, 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-1,1))


## ----normal-curve-shaded-2a, echo=FALSE, fig.height=2, fig.width=3------------
 ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -2)) +
    geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-2, 2)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(2, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-2,2))


## -----------------------------------------------------------------------------
pnorm(1)


## ----normal-curve-shaded-1----------------------------------------------------
 ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey50", xlim = c(-4, 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = 1)


## ----normal-curve-shaded-2----------------------------------------------------
 ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1)) +
    geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1, 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-1,1))


## -----------------------------------------------------------------------------
pnorm(1) - pnorm(-1)


## -----------------------------------------------------------------------------
pnorm(2) - pnorm(-2)


## -----------------------------------------------------------------------------
qnorm(0.84)


## ----normal-curve-shaded-3----------------------------------------------------
 ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -2)) +
    geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-2, 2)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(2, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = NULL) + 
  annotate(geom="text", x=2, y=-0.01, label="q",
              color="blue")


## -----------------------------------------------------------------------------
q <- qnorm(0.975)
q


## -----------------------------------------------------------------------------
qnorm(0.99)




## -----------------------------------------------------------------------------
almonds_sample_100 |>
    summarize(sample_mean = mean(weight),
              lower_bound = mean(weight) - 1.96*0.323/sqrt(length(weight)),
              upper_bound = mean(weight) + 1.96*0.323/sqrt(length(weight)))


## ----echo=F-------------------------------------------------------------------
xbar <- 3.578 
se_xbar <- 0.323/sqrt(100)
lower_bound <- xbar - 1.96 *  se_xbar
upper_bound <- xbar + 1.96 *  se_xbar
c(lower_bound, upper_bound)





## -----------------------------------------------------------------------------
almonds_sample_100 |>
    summarize(sample_mean = mean(weight),
              sample_sd = sd(weight))


## -----------------------------------------------------------------------------
almonds_sample_100 |>
    summarize(sample_mean = mean(weight),
              sample_sd = sd(weight),
              lower_bound = mean(weight) - 1.98*sd(weight)/sqrt(length(weight)),
              upper_bound = mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))


## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  summarize(mean_weight = mean(weight),
            sd_weight = sd(weight),
            sample_size = n())


## -----------------------------------------------------------------------------
qt(0.975, df = 100 - 1)


## -----------------------------------------------------------------------------
xbar <- 3.682 
se_xbar <- 0.362/sqrt(100)
lower_bound <- xbar - 1.98 *  se_xbar
upper_bound <- xbar + 1.98 *  se_xbar
c(lower_bound, upper_bound)




## ----normal-curve-shaded-3a, echo=FALSE, fig.height=2, fig.width=3------------
 ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1.96)) +
    geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1.96, 1.96)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1.96, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +scale_x_continuous(breaks = NULL) + 
  geom_point(aes(x=0, y=0), color="red") +
  geom_point(aes(x=-1.96, y=0), color="red") +
  geom_point(aes(x=1.96, y=0), color="red") +
  annotate(geom="text", x=-1.96, y=-0.03, label=bquote("-q"),
              color="red") +
  annotate(geom="text", x=1.96, y=-0.03, label=bquote("q"),
              color="red") +
  annotate(geom="text", x=0, y=-0.04, label=bquote("0"),
              color="red")



## -----------------------------------------------------------------------------
qnorm(0.025)


## -----------------------------------------------------------------------------
qnorm(0.975)


## -----------------------------------------------------------------------------
qnorm(0.99)


## -----------------------------------------------------------------------------
almonds_sample_100 |>
    summarize(sample_mean = mean(weight),
              lower_bound = mean(weight) - qnorm(0.99)*0.323/sqrt(length(weight)),
              upper_bound = mean(weight) + qnorm(0.99)*0.323/sqrt(length(weight)))


## -----------------------------------------------------------------------------
qnorm(0.9)


## -----------------------------------------------------------------------------
almonds_sample_100






## -----------------------------------------------------------------------------
almonds_sample_100 <- almonds_sample_100 |> 
  ungroup() |> 
  select(-replicate)
almonds_sample_100


## ----echo=-1------------------------------------------------------------------
set.seed(20)
boot_sample <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1)


## -----------------------------------------------------------------------------
boot_sample


## -----------------------------------------------------------------------------
boot_sample |> 
  summarize(mean_weight = mean(weight))



## ----eval=FALSE---------------------------------------------------------------
## ggplot(boot_sample, aes(x = weight)) +
##   geom_histogram(binwidth = 0.1, color = "white") +
##   labs(title = "Resample of 100 weights")
## ggplot(almonds_sample_100, aes(x = weight)) +
##   geom_histogram(binwidth = 0.1, color = "white") +
##   labs(title = "Original sample of 100 weights")




## ----echo= -1-----------------------------------------------------------------
set.seed(20)
bootstrap_samples_35 <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 35)
bootstrap_samples_35


## -----------------------------------------------------------------------------
boot_means <- bootstrap_samples_35 |> 
  summarize(mean_weight = mean(weight))
boot_means


## ----resampling-35, fig.cap="Distribution of 35 sample means from 35 bootrap samples"----
ggplot(boot_means, aes(x = mean_weight)) +
  geom_histogram(binwidth = 0.01, color = "white") +
  labs(x = "sample mean weight in grams")


## -----------------------------------------------------------------------------
# Obtain 1000 bootstrap samples
bootstrap_samples <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1000)

# Compute sample means from the bootstrap samples
boot_means <- bootstrap_samples |> 
  summarize(mean_weight = mean(weight))


## ----echo=-1------------------------------------------------------------------
set.seed(20)
boot_means <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1000) |> 
  summarize(mean_weight = mean(weight))
boot_means


## ----one-thousand-sample-means, message=FALSE, fig.cap="Histogram of 1000 bootstrap sample mean weights of almonds."----
ggplot(boot_means, aes(x = mean_weight)) +
  geom_histogram(binwidth = 0.01, color = "white") +
  labs(x = "sample mean weight in grams")


## -----------------------------------------------------------------------------
boot_means |> 
  summarize(mean_of_means = mean(mean_weight),
            sd_of_means = sd(mean_weight))







## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   rep_sample_n(size = 100, replace = TRUE, reps = 1000)


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   rep_sample_n(size = 100, replace = TRUE, reps = 1000) |>
##   summarize(mean_weight = mean(weight))


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   summarize(stat = mean(weight))


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   specify(response = weight) |>
##   calculate(stat = "mean")




## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  specify(response = weight)


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   specify(formula = weight ~ NULL)




## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   specify(response = weight) |>
##   generate(reps = 1000, type = "bootstrap")








## ----eval=FALSE---------------------------------------------------------------
## bootstrap_means <- almonds_sample_100 |>
##   specify(response = weight) |>
##   generate(reps = 1000) |>
##   calculate(stat = "mean")
## bootstrap_means








## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means)








## -----------------------------------------------------------------------------
bootstrap_means


## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_means |> 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means) +
##   shade_confidence_interval(endpoints = percentile_ci)




## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means) +
##   shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")


## -----------------------------------------------------------------------------
SE_boot <- bootstrap_means |>
  summarize(SE = sd(stat)) |>
  pull(SE)
SE_boot


## -----------------------------------------------------------------------------
almonds_sample_100 |>
    summarize(lower_bound = mean(weight) - 1.96*SE_boot,
              upper_bound = mean(weight) + 1.96*SE_boot)


## -----------------------------------------------------------------------------
x_bar <- almonds_sample_100 |> 
  specify(response = weight) |> 
  calculate(stat = "mean")
x_bar


## -----------------------------------------------------------------------------
standard_error_ci <- bootstrap_means |> 
  get_confidence_interval(type = "se", point_estimate = x_bar)
standard_error_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means) +
##   shade_confidence_interval(endpoints = standard_error_ci)








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

