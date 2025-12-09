## ----hypothesis-testing-load-packages, message=FALSE--------------------------
library(tidyverse)
library(moderndive)
library(infer)
library(nycflights23)
library(ggplot2movies)




## ----hypothesis-testing-alt2--------------------------------------------------
almonds_sample_100


## ----hypothesis-testing-mean-and-sd-------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight),
            sample_sd = sd(weight))


## ----hypothesis-testing-mean-sd, eval=FALSE-----------------------------------
# almonds_sample_100 |>
#   summarize(x_bar = mean(weight),
#             s = sd(weight),
#             n = length(weight),
#             t = (x_bar - 3.6)/(s/sqrt(n)))






## ----hypothesis-testing-demo-code, eval = FALSE-------------------------------
# 2 * pt(q = -2.26, df = 100 - 1)




## ----hypothesis-testing-null-dist---------------------------------------------
null_dist <- almonds_sample_100 |>
  specify(response = weight) |>
  hypothesize(null = "point", mu = 3.6) |>
  generate(reps = 1000, type = "bootstrap") |>
  calculate(stat = "mean")


## ----hypothesis-testing-create-x_bar_almonds, echo=TRUE-----------------------
x_bar_almonds <- almonds_sample_100 |>
  summarize(sample_mean = mean(weight)) |>
  select(sample_mean)
null_dist |>
  get_p_value(obs_stat = x_bar_almonds, direction = "two-sided")


## ----hypothesis-testing-create-p_val_almonds, echo=FALSE----------------------
p_val_almonds <- null_dist |>
  get_p_value(obs_stat = x_bar_almonds, direction = "two-sided") 




## ----hypothesis-testing-mean-sd-v2-dup1---------------------------------------
almonds_sample_100 |>
  summarize(lower_bound = mean(weight) - 1.98*sd(weight)/sqrt(length(weight)),
            upper_bound = mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))


## ----hypothesis-testing-bootstrap, eval=FALSE---------------------------------
# bootstrap_means <- almonds_sample_100 |>
#   specify(response = weight) |>
#   generate(reps = 1000, type = "bootstrap") |>
#   calculate(stat = "mean")




## ----hypothesis-testing-conf-interval-----------------------------------------
bootstrap_means |> 
  get_confidence_interval(level = 0.95, type = "percentile")




## ----hypothesis-testing-v17, echo=FALSE---------------------------------------
set.seed(2)


## ----hypothesis-testing-create-spotify_metal_deep, eval=FALSE-----------------
# spotify_metal_deephouse <- spotify_by_genre |>
#   filter(track_genre %in% c("metal", "deep-house")) |>
#   select(track_genre, artists, track_name, popularity, popular_or_not)
# spotify_metal_deephouse |>
#   group_by(track_genre, popular_or_not) |>
#   sample_n(size = 3)


## ----twelve-spotify, echo=FALSE-----------------------------------------------
spotify_metal_deephouse <- spotify_by_genre |> 
  filter(track_genre %in% c("metal", "deep-house")) |> 
  select(track_id, track_genre, artists, track_name, popularity, popular_or_not) 
sampled_spotify_metal_deephouse <- spotify_metal_deephouse |>
  group_by(track_genre, popular_or_not) |> 
  sample_n(size = 3) |> 
  arrange(track_id) |> 
  ungroup() |> 
  select(-track_id)
sampled_spotify_metal_deephouse |> 
  kbl(
    caption = "Sample of twelve songs from the Spotify data frame.",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  ) |> 
  column_spec(3, width = "1.5in")  # Adjust the column number/width as needed


## ----hypothesis-testing-bar, eval=FALSE---------------------------------------
# ggplot(spotify_metal_deephouse, aes(x = track_genre, fill = popular_or_not)) +
#   geom_bar() +
#   labs(x = "Genre of track")




## ----hypothesis-testing-grouped-summary---------------------------------------
spotify_metal_deephouse |> 
  group_by(track_genre, popular_or_not) |>
  tally() # Same as summarize(n = n())






## ----hypothesis-testing-select-vars, eval=FALSE-------------------------------
# spotify_52_original |>
#   select(-track_id) |>
#   head(10)


## ----spotify-52-sample, echo=FALSE--------------------------------------------
spotify_52_original |> 
  select(-track_id) |> 
  head(10) |> 
  kbl(caption = "Representative sample of metal and deep-house songs", 
      booktabs = TRUE,
      linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  ) |> 
  column_spec(3, width = "1.5in")  # Adjust the column number and width as needed


## ----hypothesis-testing-select-vars-alt, eval=FALSE---------------------------
# spotify_52_shuffled |>
#   select(-track_id) |>
#   head(10)


## ----spotify-shuffled-52-sample, echo=FALSE-----------------------------------
spotify_52_shuffled |> 
  select(-track_id) |> 
  head(10) |> 
  kbl(caption = "(ref:spotify-shuffled-52)", 
      booktabs = TRUE,
      linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  ) |> 
  column_spec(3, width = "1.5in")






## ----hypothesis-testing-bar-filled, eval=FALSE--------------------------------
# ggplot(spotify_52_shuffled, aes(x = track_genre, fill = popular_or_not)) +
#   geom_bar() +
#   labs(x = "Genre of track")



## ----hypothesis-testing-v26---------------------------------------------------
spotify_52_shuffled |> 
  group_by(track_genre, popular_or_not) |> 
  tally()











## ----hypothesis-testing-specify-----------------------------------------------
spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular")


## ----hypothesis-testing-null-dist-sized---------------------------------------
spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular") |> 
  hypothesize(null = "independence")




## ----hypothesis-testing-null-dist-alt2, eval=FALSE----------------------------
# spotify_generate <- spotify_metal_deephouse |>
#   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute")
# nrow(spotify_generate)




## ----hypothesis-testing-null-dist-v5, eval=FALSE------------------------------
# null_distribution <- spotify_metal_deephouse |>
#   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   calculate(stat = "diff in props", order = c("metal", "deep-house"))
# null_distribution




## ----hypothesis-testing-specify-alt-------------------------------------------
obs_diff_prop <- spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular") |> 
  calculate(stat = "diff in props", order = c("metal", "deep-house"))
obs_diff_prop


## ----hypothesis-testing-v37---------------------------------------------------
spotify_metal_deephouse |> 
  observe(formula = popular_or_not ~ track_genre, 
          success = "popular", 
          stat = "diff in props", 
          order = c("metal", "deep-house"))


## ----null-distribution-infer, fig.show="hold", fig.cap="Null distribution.", fig.height=ifelse(knitr::is_latex_output(), 1.8, 4)----
visualize(null_distribution, bins = 25)


## ----null-distribution-infer-2, fig.cap="Shaded histogram to show $p$-value."----
visualize(null_distribution, bins = 25) + 
  shade_p_value(obs_stat = obs_diff_prop, direction = "right")


## ----hypothesis-testing-v38---------------------------------------------------
null_distribution |> 
  get_p_value(obs_stat = obs_diff_prop, direction = "right")



## ----hypothesis-testing-null-dist-v6, eval=FALSE------------------------------
# null_distribution <- spotify_metal_deephouse |>
#   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   calculate(stat = "diff in props", order = c("metal", "deep-house"))


## ----hypothesis-testing-null-dist-v7, eval=FALSE------------------------------
# bootstrap_distribution <- spotify_metal_deephouse |>
#   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
#   # Change 1 - Remove hypothesize():
#   # hypothesize(null = "independence") |>
#   # Change 2 - Switch type from "permute" to "bootstrap":
#   generate(reps = 1000, type = "bootstrap") |>
#   calculate(stat = "diff in props", order = c("metal", "deep-house"))




## ----hypothesis-testing-assign-percentile_ci----------------------------------
percentile_ci <- bootstrap_distribution |> 
  get_confidence_interval(level = 0.90, type = "percentile")
percentile_ci


## ----hypothesis-testing-viz-dist, eval=FALSE----------------------------------
# visualize(bootstrap_distribution) +
#   shade_confidence_interval(endpoints = percentile_ci)



## ----hypothesis-testing-conf-interval-alt2, eval=FALSE------------------------
# se_ci <- bootstrap_distribution |>
# get_confidence_interval(level = 0.95, type = "se",
# point_estimate = obs_diff_prop)
# se_ci


## ----hypothesis-testing-viz-dist-alt, eval=FALSE------------------------------
# visualize(bootstrap_distribution) +
# shade_confidence_interval(endpoints = se_ci)





## ----hypothesis-testing-load-packages-sized, eval=FALSE-----------------------
# library(moderndive)
# library(infer)
# null_distribution_mean <- spotify_metal_deephouse |>
#   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   calculate(stat = "diff in means", order = c("metal", "deep-house"))






















## ----hypothesis-testing-v50---------------------------------------------------
movies




## ----hypothesis-testing-v52---------------------------------------------------
movies_sample


## ----action-romance-boxplot, fig.cap="Boxplot of IMDb rating vs. genre.", fig.height=ifelse(knitr::is_latex_output(), 4, 4)----
ggplot(data = movies_sample, aes(x = genre, y = rating)) +
  geom_boxplot() +
  labs(y = "IMDb rating")


## ----hypothesis-testing-mean-sd-v2-dup2---------------------------------------
movies_sample |> 
  group_by(genre) |> 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))





## ----hypothesis-testing-specify-alt2------------------------------------------
movies_sample |> 
  specify(formula = rating ~ genre)


## ----hypothesis-testing-null-dist-v9------------------------------------------
movies_sample |> 
  specify(formula = rating ~ genre) |> 
  hypothesize(null = "independence")


## ----hypothesis-testing-view, eval=FALSE--------------------------------------
# movies_sample |>
#   specify(formula = rating ~ genre) |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   View()




## ----hypothesis-testing-null-dist-v11, eval=FALSE-----------------------------
# null_distribution_movies <- movies_sample |>
#   specify(formula = rating ~ genre) |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   calculate(stat = "diff in means", order = c("Action", "Romance"))
# null_distribution_movies




## ----hypothesis-testing-specify-v4--------------------------------------------
obs_diff_means <- movies_sample |> 
  specify(formula = rating ~ genre) |> 
  calculate(stat = "diff in means", order = c("Action", "Romance"))
obs_diff_means


## ----hypothesis-testing-viz-pvalue, eval=FALSE--------------------------------
# visualize(null_distribution_movies, bins = 10) +
#   shade_p_value(obs_stat = obs_diff_means, direction = "both")




## ----hypothesis-testing-v63---------------------------------------------------
null_distribution_movies |> 
  get_p_value(obs_stat = obs_diff_means, direction = "both")

## ----hypothesis-testing-create-p_value_movies, echo=FALSE---------------------
p_value_movies <- null_distribution_movies |>
  get_p_value(obs_stat = obs_diff_means, direction = "both") |>
  mutate(p_value = round(p_value, 3))






## ----hypothesis-testing-mean-sd-v2-dup3---------------------------------------
movies_sample |> 
  group_by(genre) |> 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))



## ----hypothesis-testing-v67---------------------------------------------------
movies_sample |>
  t_test(formula = rating ~ genre, 
         order = c("Action", "Romance"), 
         alternative = "two-sided")




## ----hypothesis-testing-filter-alaska-----------------------------------------
flights_sample <- flights |> 
  filter(carrier %in% c("HA", "AS"))


## ----ha-as-flights-boxplot, fig.cap="Air time for Hawaiian and Alaska Airlines flights departing NYC in 2023.", fig.height=ifelse(knitr::is_latex_output(), 2.8, 4)----
ggplot(data = flights_sample, mapping = aes(x = carrier, y = air_time)) +
  geom_boxplot() +
  labs(x = "Carrier", y = "Air Time")


## ----hypothesis-testing-summary-by-carrier------------------------------------
flights_sample |> 
  group_by(carrier, dest) |> 
  summarize(n = n(), mean_time = mean(air_time, na.rm = TRUE), .groups = "keep")

