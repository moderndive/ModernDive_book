## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(infer)
library(nycflights13)
library(ggplot2movies)
library(broom)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)

## ------------------------------------------------------------------------
bos_sfo <- flights %>% 
  na.omit() %>% 
  filter(dest %in% c("BOS", "SFO")) %>% 
  group_by(dest) %>% 
  sample_n(100)

## ------------------------------------------------------------------------
bos_sfo_summary <- bos_sfo %>% group_by(dest) %>% 
  summarize(mean_time = mean(air_time),
            sd_time = sd(air_time))
bos_sfo_summary

## ------------------------------------------------------------------------
ggplot(data = bos_sfo, mapping = aes(x = dest, y = air_time)) +
  geom_boxplot()

## ----message=FALSE, warning=FALSE----------------------------------------
movies_trimmed <- movies %>% 
  select(title, year, rating, Action, Romance)

## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  filter(!(Action == 1 & Romance == 1))

## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  mutate(genre = case_when(Action == 1 ~ "Action",
                           Romance == 1 ~ "Romance",
                           TRUE ~ "Neither")) %>%
  filter(genre != "Neither") %>%
  select(-Action, -Romance)

## ----fig.cap="Rating vs genre in the population"-------------------------
ggplot(data = movies_trimmed, aes(x = genre, y = rating)) +
  geom_boxplot()

## ----movie-hist, warning=FALSE, fig.cap="Faceted histogram of genre vs rating"----
ggplot(data = movies_trimmed, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white") +
  facet_grid(genre ~ .)

## ------------------------------------------------------------------------
set.seed(2017)
movies_genre_sample <- movies_trimmed %>% 
  group_by(genre) %>%
  sample_n(34) %>% 
  ungroup()

## ----fig.cap="Genre vs rating for our sample"----------------------------
ggplot(data = movies_genre_sample, aes(x = genre, y = rating)) +
  geom_boxplot()

## ----warning=FALSE, fig.cap="Genre vs rating for our sample as faceted histogram"----
ggplot(data = movies_genre_sample, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white") +
  facet_grid(genre ~ .)

## ------------------------------------------------------------------------
summary_ratings <- movies_genre_sample %>% 
  group_by(genre) %>%
  summarize(mean = mean(rating),
            std_dev = sd(rating),
            n = n())
summary_ratings

## ------------------------------------------------------------------------
obs_diff <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action"))
obs_diff

## ----include=FALSE-------------------------------------------------------
set.seed(2018)

## ----message=FALSE, warning=FALSE----------------------------------------
shuffled_ratings_old <- #movies_trimmed %>%
  movies_genre_sample %>% 
     mutate(genre = mosaic::shuffle(genre)) %>% 
     group_by(genre) %>%
     summarize(mean = mean(rating))
diff(shuffled_ratings_old$mean)

permuted_ratings <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
  generate(reps = 1)

## ----include=FALSE-------------------------------------------------------
if(!file.exists("rds/generated_samples.rds")){
  generated_samples <- movies_genre_sample %>% 
    specify(formula = rating ~ genre) %>% 
    hypothesize(null = "independence") %>% 
    generate(reps = 5000)
   saveRDS(object = generated_samples, 
           "rds/generated_samples.rds")
} else {
   generated_samples <- readRDS("rds/generated_samples.rds")
}

## ----eval=FALSE----------------------------------------------------------
## generated_samples <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000)

## ----include=FALSE-------------------------------------------------------
null_distribution_two_means <- generated_samples %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action"))

## ----fig.cap="Simulated differences in means histogram"------------------
null_distribution_two_means %>% visualize()

## ----fig.cap="Shaded histogram to show p-value"--------------------------
null_distribution_two_means %>% 
  visualize(obs_stat = obs_diff, direction = "both")

## ----fig.cap="Histogram with vertical lines corresponding to observed statistic"----
null_distribution_two_means %>% 
  visualize(bins = 100, obs_stat = obs_diff, direction = "both")

## ------------------------------------------------------------------------
pvalue <- null_distribution_two_means %>% 
  get_pvalue(obs_stat = obs_diff, direction = "both")
pvalue

## ----eval=FALSE----------------------------------------------------------
## null_distribution_two_means <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000) %>%
##   calculate(stat = "diff in means", order = c("Romance", "Action"))

## ------------------------------------------------------------------------
percentile_ci_two_means <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
#  hypothesize(null = "independence") %>% 
  generate(reps = 5000) %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action")) %>% 
  get_ci()
percentile_ci_two_means

## ----echo=FALSE----------------------------------------------------------
ggplot(data.frame(x = c(-4, 4)), aes(x)) + stat_function(fun = dnorm)

## ----fig.cap="Simulated differences in means histogram"------------------
ggplot(data = null_distribution_two_means, aes(x = stat)) +
  geom_histogram(color = "white", bins = 20)

## ----eval=FALSE----------------------------------------------------------
## generated_samples <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000)

## ------------------------------------------------------------------------
null_distribution_t <- generated_samples %>% 
  calculate(stat = "t", order = c("Romance", "Action"))
null_distribution_t %>% visualize()

## ------------------------------------------------------------------------
null_distribution_t %>% 
  visualize(method = "both")

## ------------------------------------------------------------------------
obs_t <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "t", order = c("Romance", "Action"))

## ------------------------------------------------------------------------
null_distribution_t %>% 
  visualize(method = "both", obs_stat = obs_t, direction = "both")

