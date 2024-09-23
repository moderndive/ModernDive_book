## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(infer)
library(moderndive)
library(nycflights13)
library(ggplot2movies)






## ----echo=FALSE---------------------------------------------------------------
set.seed(2102)


## -----------------------------------------------------------------------------
promotions %>% 
  sample_n(size = 6) %>% 
  arrange(id)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(promotions, aes(x = gender, fill = decision)) +
##   geom_bar() +
##   labs(x = "Gender of name on résumé")




## -----------------------------------------------------------------------------
promotions %>% 
  group_by(gender, decision) %>% 
  tally()












## ----eval=FALSE---------------------------------------------------------------
## ggplot(promotions_shuffled,
##        aes(x = gender, fill = decision)) +
##   geom_bar() +
##   labs(x = "Gender of résumé name")



## -----------------------------------------------------------------------------
promotions_shuffled %>% 
  group_by(gender, decision) %>% 
  tally() # Same as summarize(n = n())











## ----eval=FALSE---------------------------------------------------------------
## obs_diff_prop <- promotions %>%
##   specify(decision ~ gender, success = "promoted") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## obs_diff_prop


## ----echo=FALSE, eval=FALSE---------------------------------------------------
## set.seed(2019)
## tactile_permutes <- promotions %>%
##   specify(decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 33, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## ggplot(data = tactile_permutes, aes(x = stat)) +
##   geom_histogram(binwidth = 0.05, boundary = -0.2, color = "white") +
##   geom_vline(xintercept = pull(obs_diff_prop), color = "blue", size = 2) +
##   scale_y_continuous(breaks = 0:10)














## -----------------------------------------------------------------------------
promotions %>% 
  specify(formula = decision ~ gender, success = "promoted") 


## -----------------------------------------------------------------------------
promotions %>% 
  specify(formula = decision ~ gender, success = "promoted") %>% 
  hypothesize(null = "independence")




## ----eval=FALSE---------------------------------------------------------------
## promotions_generate <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute")
## nrow(promotions_generate)




## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## null_distribution




## -----------------------------------------------------------------------------
obs_diff_prop <- promotions %>% 
  specify(decision ~ gender, success = "promoted") %>% 
  calculate(stat = "diff in props", order = c("male", "female"))
obs_diff_prop


## ----null-distribution-infer, fig.show="hold", fig.cap="Null distribution.", fig.height=1.8----
visualize(null_distribution, bins = 10)


## ----null-distribution-infer-2, fig.cap="Shaded histogram to show $p$-value."----
visualize(null_distribution, bins = 10) + 
  shade_p_value(obs_stat = obs_diff_prop, direction = "right")


## -----------------------------------------------------------------------------
null_distribution %>% 
  get_p_value(obs_stat = obs_diff_prop, direction = "right")



## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   # Change 1 - Remove hypothesize():
##   # hypothesize(null = "independence") %>%
##   # Change 2 - Switch type from "permute" to "bootstrap":
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))




## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = percentile_ci)



## -----------------------------------------------------------------------------
se_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "se", 
                          point_estimate = obs_diff_prop)
se_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = se_ci)





## ----eval=FALSE---------------------------------------------------------------
## library(moderndive)
## library(infer)
## null_distribution_mean <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in means", order = c("male", "female"))






















## -----------------------------------------------------------------------------
movies




## -----------------------------------------------------------------------------
movies_sample


## ----action-romance-boxplot, fig.cap="Boxplot of IMDb rating vs. genre.", fig.height=2.7----
ggplot(data = movies_sample, aes(x = genre, y = rating)) +
  geom_boxplot() +
  labs(y = "IMDb rating")


## -----------------------------------------------------------------------------
movies_sample %>% 
  group_by(genre) %>% 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))





## -----------------------------------------------------------------------------
movies_sample %>% 
  specify(formula = rating ~ genre)


## -----------------------------------------------------------------------------
movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  hypothesize(null = "independence")


## ----eval=FALSE---------------------------------------------------------------
## movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   View()




## ----eval=FALSE---------------------------------------------------------------
## null_distribution_movies <- movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## null_distribution_movies




## -----------------------------------------------------------------------------
obs_diff_means <- movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "diff in means", order = c("Action", "Romance"))
obs_diff_means


## ----eval=FALSE---------------------------------------------------------------
## visualize(null_distribution_movies, bins = 10) +
##   shade_p_value(obs_stat = obs_diff_means, direction = "both")




## -----------------------------------------------------------------------------
null_distribution_movies %>% 
  get_p_value(obs_stat = obs_diff_means, direction = "both")

## ----echo=FALSE---------------------------------------------------------------
p_value_movies <- null_distribution_movies %>%
  get_p_value(obs_stat = obs_diff_means, direction = "both") %>%
  mutate(p_value = round(p_value, 3))










## -----------------------------------------------------------------------------
movies_sample %>% 
  group_by(genre) %>% 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))



## ----eval=FALSE---------------------------------------------------------------
## # Construct null distribution of xbar_a - xbar_r:
## null_distribution_movies <- movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## visualize(null_distribution_movies, bins = 10)


## ----eval=FALSE---------------------------------------------------------------
## # Construct null distribution of t:
## null_distribution_movies_t <- movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   # Notice we switched stat from "diff in means" to "t"
##   calculate(stat = "t", order = c("Action", "Romance"))
## visualize(null_distribution_movies_t, bins = 10)






## ----t-stat-3, fig.cap="Null distribution using t-statistic and t-distribution.", fig.height=2.2----
visualize(null_distribution_movies_t, bins = 10, method = "both")


## -----------------------------------------------------------------------------
obs_two_sample_t <- movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "t", order = c("Action", "Romance"))
obs_two_sample_t


## ----t-stat-4, fig.cap="Null distribution using t-statistic and t-distribution with $p$-value shaded.", warning=TRUE, fig.height=1.7----
visualize(null_distribution_movies_t, method = "both") +
  shade_p_value(obs_stat = obs_two_sample_t, direction = "both")


## -----------------------------------------------------------------------------
null_distribution_movies_t %>% 
  get_p_value(obs_stat = obs_two_sample_t, direction = "both")


## -----------------------------------------------------------------------------
flights_sample <- flights %>% 
  filter(carrier %in% c("HA", "AS"))


## ----ha-as-flights-boxplot, fig.cap="Air time for Hawaiian and Alaska Airlines flights departing NYC in 2013.", fig.height=2.8----
ggplot(data = flights_sample, mapping = aes(x = carrier, y = air_time)) +
  geom_boxplot() +
  labs(x = "Carrier", y = "Air Time")


## -----------------------------------------------------------------------------
flights_sample %>% 
  group_by(carrier, dest) %>% 
  summarize(n = n(), mean_time = mean(air_time, na.rm = TRUE))








## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals)
## 
## # Get regression table:
## get_regression_table(score_model)

