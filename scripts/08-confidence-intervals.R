## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)




## ----echo=FALSE---------------------------------------------------------------
almonds_sample_100 <- moderndive::almonds_sample_100


## -----------------------------------------------------------------------------
almonds_sample_100




## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight))


## ----echo=FALSE---------------------------------------------------------------
xbar <- mean(almonds_sample_100$weight)






## ----echo=FALSE---------------------------------------------------------------
num_almonds <- nrow(almonds_bowl)
mu <- mean(almonds_bowl$weight)
sigma <- pop_sd(almonds_bowl$weight)


## -----------------------------------------------------------------------------
almonds_bowl |> 
  summarize(population_mean = mean(weight), 
            population_sd = pop_sd(weight))


## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  summarize(mean_weight = mean(weight), 
            sd_weight = sd(weight), 
            sample_size = n())








## ----normal-curve-shaded-1a, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 1.5, 4), fig.width=3, fig.cap="Normal area within one standard deviation."----
ggplot(data = data.frame(x = c(-4, 4)), aes(x)) +
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1, 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-1,1)) 


## ----normal-curve-shaded-2a, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 1.5, 4), fig.width=3, fig.cap="Normal area within two standard deviations."----
ggplot(data = data.frame(x = c(-4, 4)), aes(x)) +
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -2)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-2, 2)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(2, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-2,2))








## ----echo=FALSE---------------------------------------------------------------
se_xbar <- sigma / sqrt(num_almonds_sample)




## ----echo=FALSE---------------------------------------------------------------
sample_mean <- mean(almonds_sample_100$weight)
deviance <- sample_mean - mu
z_almond <- deviance / se_xbar


## ----echo=FALSE---------------------------------------------------------------
lower_bound <- sample_mean - 1.96 * sigma / sqrt(100)
upper_bound <- sample_mean + 1.96 * sigma / sqrt(100)


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(
    sample_mean = mean(weight),
    lower_bound = mean(weight) - 1.96 * sigma / sqrt(length(weight)),
    upper_bound = mean(weight) + 1.96 * sigma / sqrt(length(weight))
  )












## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight), sample_sd = sd(weight))


## ----echo=FALSE---------------------------------------------------------------
sample_s <- sd(almonds_sample_100$weight)
lower_bound_t <- with(almonds_sample,
                     mean(weight) - 1.98*sd(weight)/sqrt(length(weight)))
upper_bound_t <- with(almonds_sample,
                     mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight), sample_sd = sd(weight),
            lower_bound = mean(weight) - 1.98*sd(weight)/sqrt(length(weight)),
            upper_bound = mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))








## ----normal-curve-shaded-3a, echo=FALSE, fig.cap="Normal curve with the shaded middle area being 0.95", fig.height=ifelse(knitr::is_latex_output(), 2, 4), fig.width=3----
ggplot(data = data.frame(x = c(-4, 4)), aes(x)) +
  stat_function(fun = dnorm, args = list(mean = 0, sd = 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1.96)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1.96, 1.96)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1.96, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +scale_x_continuous(breaks = NULL) + 
  geom_point(aes(x=0, y=0), color="red") +
  geom_point(aes(x=-1.96, y=0), color="red") +
  geom_point(aes(x=1.96, y=0), color="red") +
  annotate(geom="text", x=-1.96, y=-0.03, label = bquote("-q"),
           color="red") +
  annotate(geom="text", x=1.96, y=-0.03, label = bquote("q"),
           color="red") +
  annotate(geom="text", x=0, y=-0.04, label = bquote("0"),
           color="red")


## -----------------------------------------------------------------------------
qnorm(0.025)


## -----------------------------------------------------------------------------
qnorm(0.975)


## ----results='hide'-----------------------------------------------------------
qnorm(0.95)




## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight),
            lower_bound = mean(weight) - qnorm(0.95)*sigma/sqrt(length(weight)),
            upper_bound = mean(weight) + qnorm(0.95)*sigma/sqrt(length(weight)))


## ----results='hide'-----------------------------------------------------------
qnorm(0.9)




## -----------------------------------------------------------------------------
almonds_sample_100






## -----------------------------------------------------------------------------
almonds_sample_100 <- almonds_sample_100 |> 
  ungroup() |> 
  select(-replicate)
almonds_sample_100


## ----echo=-1------------------------------------------------------------------
set.seed(202)
boot_sample <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1)


## -----------------------------------------------------------------------------
boot_sample


## -----------------------------------------------------------------------------
boot_sample |> 
  summarize(mean_weight = mean(weight))



## ----echo=TRUE, fig.show='hide'-----------------------------------------------
ggplot(boot_sample, aes(x = weight)) +
  geom_histogram(binwidth = 0.1, color = "white") +
  labs(title = "Resample of 100 weights")
ggplot(almonds_sample_100, aes(x = weight)) +
  geom_histogram(binwidth = 0.1, color = "white") +
  labs(title = "Original sample of 100 weights")




## ----echo= -1-----------------------------------------------------------------
set.seed(20)
bootstrap_samples_35 <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 35)
bootstrap_samples_35


## -----------------------------------------------------------------------------
boot_means <- bootstrap_samples_35 |> 
  summarize(mean_weight = mean(weight))
boot_means


## ----resampling-35, fig.cap="Distribution of 35 sample means from 35 bootrap samples."----
ggplot(boot_means, aes(x = mean_weight)) +
  geom_histogram(binwidth = 0.01, color = "white") +
  labs(x = "sample mean weight in grams")


## -----------------------------------------------------------------------------
# Retrieve 1000 bootstrap samples
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


## ----one-thousand-sample-means, message=FALSE, fig.cap="Histogram of 1000 bootstrap sample mean weights of almonds.", fig.height=ifelse(knitr::is_latex_output(), 3.85, 4)----
ggplot(boot_means, aes(x = mean_weight)) +
  geom_histogram(binwidth = 0.01, color = "white") +
  labs(x = "sample mean weight in grams")


## -----------------------------------------------------------------------------
boot_means |> 
  summarize(mean_of_means = mean(mean_weight),
            sd_of_means = sd(mean_weight))







## ----results='hide'-----------------------------------------------------------
almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1000)


## ----results='hide'-----------------------------------------------------------
almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1000) |> 
  summarize(mean_weight = mean(weight))


## ----results='hide'-----------------------------------------------------------
almonds_sample_100 |> 
  summarize(stat = mean(weight))


## ----results='hide'-----------------------------------------------------------
almonds_sample_100 |> 
  specify(response = weight) |> 
  calculate(stat = "mean")




## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  specify(response = weight)


## ----results='hide'-----------------------------------------------------------
almonds_sample_100 |> 
  specify(formula = weight ~ NULL)




## ----results='hide'-----------------------------------------------------------
almonds_sample_100 |> 
  specify(response = weight) |> 
  generate(reps = 1000, type = "bootstrap")








## ----results='hide'-----------------------------------------------------------
bootstrap_means <- almonds_sample_100 |> 
  specify(response = weight) |> 
  generate(reps = 1000) |> 
  calculate(stat = "mean")
bootstrap_means














## -----------------------------------------------------------------------------
bootstrap_means


## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_means |> 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----echo=TRUE, fig.show='hide'-----------------------------------------------
visualize(bootstrap_means) + 
  shade_confidence_interval(endpoints = percentile_ci)




## ----echo=TRUE, fig.show='hide'-----------------------------------------------
visualize(bootstrap_means) + 
  shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")


## -----------------------------------------------------------------------------
SE_boot <- bootstrap_means |>
  summarize(SE = sd(stat)) |>
  pull(SE)
SE_boot


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(lower_bound = mean(weight) - 1.96 * SE_boot,
            upper_bound = mean(weight) + 1.96 * SE_boot)


## -----------------------------------------------------------------------------
x_bar <- almonds_sample_100 |> 
  specify(response = weight) |> 
  calculate(stat = "mean")
x_bar


## -----------------------------------------------------------------------------
standard_error_ci <- bootstrap_means |> 
  get_confidence_interval(type = "se", point_estimate = x_bar, level = 0.95)
standard_error_ci


## ----echo=TRUE, fig.show='hide'-----------------------------------------------
visualize(bootstrap_means) + 
  shade_confidence_interval(endpoints = standard_error_ci)








## -----------------------------------------------------------------------------
mythbusters_yawn




## -----------------------------------------------------------------------------
mythbusters_yawn |> 
  group_by(group, yawn) |> 
  summarize(count = n(), .groups = "keep")




## -----------------------------------------------------------------------------
mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes")


## -----------------------------------------------------------------------------
first_six_rows <- head(mythbusters_yawn)
first_six_rows


## ----echo=FALSE---------------------------------------------------------------
set.seed(22)


## -----------------------------------------------------------------------------
first_six_rows |> 
  sample_n(size = 6, replace = TRUE)


## ----results='hide'-----------------------------------------------------------
mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes") |> 
  generate(reps = 1000, type = "bootstrap")




## ----results='hide'-----------------------------------------------------------
mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes") |> 
  generate(reps = 1000, type = "bootstrap") |> 
  calculate(stat = "diff in props")


## ----results='hide'-----------------------------------------------------------
bootstrap_distribution_yawning <- mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes") |> 
  generate(reps = 1000, type = "bootstrap") |> 
  calculate(stat = "diff in props", order = c("seed", "control"))
bootstrap_distribution_yawning






## -----------------------------------------------------------------------------
bootstrap_distribution_yawning |> 
  get_confidence_interval(type = "percentile", level = 0.95)



## -----------------------------------------------------------------------------
obs_diff_in_props <- mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes") |> 
  # generate(reps = 1000, type = "bootstrap") |> 
  calculate(stat = "diff in props", order = c("seed", "control"))
obs_diff_in_props


## -----------------------------------------------------------------------------
myth_ci_se <- bootstrap_distribution_yawning |> 
  get_confidence_interval(type = "se", point_estimate = obs_diff_in_props)
myth_ci_se

