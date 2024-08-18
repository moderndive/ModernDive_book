## ----include=FALSE------------------------------------------------------------
# remotes::install_github("moderndive/moderndive", ref = "add-more-data")


## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(infer)
library(moderndive)
library(nycflights23)
library(ggplot2movies)






## ----echo=FALSE---------------------------------------------------------------
set.seed(2)


## ----eval=FALSE---------------------------------------------------------------
## spotify_metal_deephouse <- spotify_by_genre |>
##   filter(track_genre %in% c("metal", "deep-house")) |>
##   select(track_id, track_genre, artists, track_name, popularity, popular_or_not)
## spotify_metal_deephouse |>
##   group_by(track_genre, popular_or_not) |>
##   sample_n(size = 3) |>
##   arrange(track_id)


## ----echo=FALSE---------------------------------------------------------------
spotify_metal_deephouse <- spotify_by_genre |> 
  filter(track_genre %in% c("metal", "deep-house")) |> 
  select(track_id, track_genre, artists, track_name, popularity, popular_or_not) 
sampled_spotify_metal_deephouse <- spotify_metal_deephouse |>
  group_by(track_genre, popular_or_not) |> 
  sample_n(size = 3) |> 
  arrange(track_id) |> 
  ungroup()
sampled_spotify_metal_deephouse


## ----eval=FALSE---------------------------------------------------------------
## ggplot(spotify_metal_deephouse, aes(x = track_genre, fill = popular_or_not)) +
##   geom_bar() +
##   labs(x = "Genre of track")




## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  group_by(track_genre, popular_or_not) |>
  tally() # Same as summarize(n = n())






## -----------------------------------------------------------------------------
spotify_52_original


## -----------------------------------------------------------------------------
spotify_52_shuffled






## ----eval=FALSE---------------------------------------------------------------
## ggplot(spotify_52_shuffled,
##        aes(x = track_genre, fill = popular_or_not)) +
##   geom_bar() +
##   labs(x = "Genre of track")



## -----------------------------------------------------------------------------
spotify_52_shuffled |> 
  group_by(track_genre, popular_or_not) |> 
  tally()











## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular")


## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular") |> 
  hypothesize(null = "independence")




## ----eval=FALSE---------------------------------------------------------------
## spotify_generate <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute")
## nrow(spotify_generate)




## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in props", order = c("metal", "deep-house"))
## null_distribution




## -----------------------------------------------------------------------------
obs_diff_prop <- spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular") |> 
  calculate(stat = "diff in props", order = c("metal", "deep-house"))
obs_diff_prop


## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  observe(formula = popular_or_not ~ track_genre, 
          success = "popular", 
          stat = "diff in props", 
          order = c("metal", "deep-house"))


## ----null-distribution-infer, fig.show="hold", fig.cap="Null distribution.", fig.height=1.8----
visualize(null_distribution, bins = 25)


## ----null-distribution-infer-2, fig.cap="Shaded histogram to show $p$-value."----
visualize(null_distribution, bins = 25) + 
  shade_p_value(obs_stat = obs_diff_prop, direction = "right")


## -----------------------------------------------------------------------------
null_distribution |> 
  get_p_value(obs_stat = obs_diff_prop, direction = "right")



## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in props", order = c("metal", "deep-house"))


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   # Change 1 - Remove hypothesize():
##   # hypothesize(null = "independence") |>
##   # Change 2 - Switch type from "permute" to "bootstrap":
##   generate(reps = 1000, type = "bootstrap") |>
##   calculate(stat = "diff in props", order = c("metal", "deep-house"))




## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution |> 
  get_confidence_interval(level = 0.90, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = percentile_ci)



## ----eval=FALSE---------------------------------------------------------------
## se_ci <- bootstrap_distribution |>
##   get_confidence_interval(level = 0.95, type = "se",
##                           point_estimate = obs_diff_prop)
## se_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = se_ci)





## ----eval=FALSE---------------------------------------------------------------
## library(moderndive)
## library(infer)
## null_distribution_mean <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in means", order = c("metal", "deep-house"))






















## -----------------------------------------------------------------------------
movies




## -----------------------------------------------------------------------------
movies_sample


## ----action-romance-boxplot, fig.cap="Boxplot of IMDb rating vs. genre.", fig.height=2.7----
ggplot(data = movies_sample, aes(x = genre, y = rating)) +
  geom_boxplot() +
  labs(y = "IMDb rating")


## -----------------------------------------------------------------------------
movies_sample |> 
  group_by(genre) |> 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))





## -----------------------------------------------------------------------------
movies_sample |> 
  specify(formula = rating ~ genre)


## -----------------------------------------------------------------------------
movies_sample |> 
  specify(formula = rating ~ genre) |> 
  hypothesize(null = "independence")


## ----eval=FALSE---------------------------------------------------------------
## movies_sample |>
##   specify(formula = rating ~ genre) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   View()




## ----eval=FALSE---------------------------------------------------------------
## null_distribution_movies <- movies_sample |>
##   specify(formula = rating ~ genre) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## null_distribution_movies




## -----------------------------------------------------------------------------
obs_diff_means <- movies_sample |> 
  specify(formula = rating ~ genre) |> 
  calculate(stat = "diff in means", order = c("Action", "Romance"))
obs_diff_means


## ----eval=FALSE---------------------------------------------------------------
## visualize(null_distribution_movies, bins = 10) +
##   shade_p_value(obs_stat = obs_diff_means, direction = "both")




## -----------------------------------------------------------------------------
null_distribution_movies |> 
  get_p_value(obs_stat = obs_diff_means, direction = "both")

## ----echo=FALSE---------------------------------------------------------------
p_value_movies <- null_distribution_movies |>
  get_p_value(obs_stat = obs_diff_means, direction = "both") |>
  mutate(p_value = round(p_value, 3))










## -----------------------------------------------------------------------------
movies_sample |> 
  group_by(genre) |> 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))



## ----eval=FALSE---------------------------------------------------------------
## # Construct null distribution of xbar_a - xbar_r:
## null_distribution_movies <- movies_sample |>
##   specify(formula = rating ~ genre) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## visualize(null_distribution_movies, bins = 10)


## ----eval=FALSE---------------------------------------------------------------
## # Construct null distribution of t:
## null_distribution_movies_t <- movies_sample |>
##   specify(formula = rating ~ genre) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   # Notice we switched stat from "diff in means" to "t"
##   calculate(stat = "t", order = c("Action", "Romance"))
## visualize(null_distribution_movies_t, bins = 10)






## ----t-stat-3, fig.cap="Null distribution using t-statistic and t-distribution.", fig.height=2.2----
visualize(null_distribution_movies_t, bins = 10, method = "both")


## -----------------------------------------------------------------------------
obs_two_sample_t <- movies_sample |> 
  specify(formula = rating ~ genre) |> 
  calculate(stat = "t", order = c("Action", "Romance"))
obs_two_sample_t


## ----t-stat-4, fig.cap="Null distribution using t-statistic and t-distribution with $p$-value shaded.", warning=TRUE, fig.height=1.7----
visualize(null_distribution_movies_t, method = "both") +
  shade_p_value(obs_stat = obs_two_sample_t, direction = "both")


## -----------------------------------------------------------------------------
null_distribution_movies_t |> 
  get_p_value(obs_stat = obs_two_sample_t, direction = "both")


## -----------------------------------------------------------------------------
flights_sample <- flights |> 
  filter(carrier %in% c("HA", "AS"))


## ----ha-as-flights-boxplot, fig.cap="Air time for Hawaiian and Alaska Airlines flights departing NYC in 2023.", fig.height=2.8----
ggplot(data = flights_sample, mapping = aes(x = carrier, y = air_time)) +
  geom_boxplot() +
  labs(x = "Carrier", y = "Air Time")


## -----------------------------------------------------------------------------
flights_sample |> 
  group_by(carrier, dest) |> 
  summarize(n = n(), mean_time = mean(air_time, na.rm = TRUE))








## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals)
## 
## # Get regression table:
## get_regression_table(score_model)

