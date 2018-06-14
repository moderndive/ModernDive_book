## ---- message=FALSE, warning=FALSE---------------------------------------
library(dplyr)
library(ggplot2)
library(infer)

# Clean data
mtcars <- mtcars %>%
  as_tibble() %>% 
  mutate(am = factor(am))

# Observed test statistic
obs_stat <- mtcars %>% 
  group_by(am) %>%
  summarize(mean = mean(mpg)) %>%
  summarize(obs_stat = diff(mean)) %>%
  pull(obs_stat)

# Simulate null distribution of two-sample difference in means:
null_distribution <- mtcars %>%
  specify(mpg ~ am) %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>% 
  calculate(stat = "diff in means", order = c("1", "0"))

# Visualize:
plot <- null_distribution %>% 
  visualize()
plot +
  geom_vline(xintercept = obs_stat, col = "red", size = 1)

## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(mosaic)
library(knitr)
library(nycflights13)
library(ggplot2movies)
library(broom)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.

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
kable(bos_sfo_summary)

## ------------------------------------------------------------------------
ggplot(data = bos_sfo, mapping = aes(x = dest, y = air_time)) +
  geom_boxplot()

## ----echo=FALSE----------------------------------------------------------
choice <- c(rep("Correct", 3), "Incorrect", rep("Correct", 6))
kable(choice)

## ----sample-table, echo=FALSE--------------------------------------------
set.seed(2017)
sim1 <- resample(x = c("Correct", "Incorrect"), size = 10, prob = c(0.5, 0.5))
sim2 <- resample(x = c("Correct", "Incorrect"), size = 10, prob = c(0.5, 0.5))
sim3 <- resample(x = c("Correct", "Incorrect"), size = 10, prob = c(0.5, 0.5))
sims <- data.frame(sample1 = sim1, sample2 = sim2, sample3 = sim3)
kable(sims, row.names = TRUE, caption = 'A table of three sets of 10 coin flips')

## ----echo=FALSE----------------------------------------------------------
t1 <- sum(sim1 == "Correct")
t2 <- sum(sim2 == "Correct")
t3 <- sum(sim3 == "Correct")

## ------------------------------------------------------------------------
simGuesses <- do(5000) * rflip(10)
ggplot(data = simGuesses, aes(x = factor(heads))) +
  geom_bar()

## ------------------------------------------------------------------------
pvalue_tea <- simGuesses %>%
  filter(heads >= 9) %>%
  nrow() / nrow(simGuesses)

## ----fig.cap="Barplot of heads with p-value highlighted"-----------------
ggplot(data = simGuesses, aes(x = factor(heads), fill = (heads >= 9))) +
  geom_bar() +
  labs(x = "heads")

## ----message=FALSE, warning=FALSE----------------------------------------
(movies_trimmed <- movies %>% select(title, year, rating, Action, Romance))

## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  filter(!(Action == 1 & Romance == 1))

## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  mutate(genre = ifelse(Action == 1, "Action",
                        ifelse(Romance == 1, "Romance",
                               "Neither"))) %>%
  filter(genre != "Neither") %>%
  select(-Action, -Romance)

## ----fig.cap="Rating vs genre in the population"-------------------------
ggplot(data = movies_trimmed, aes(x = genre, y = rating)) +
  geom_boxplot()

## ----movie-hist, warning=FALSE, fig.cap="Faceted histogram of genre vs rating"----
ggplot(data = movies_trimmed, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white", fill = "dodgerblue") +
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
  geom_histogram(binwidth = 1, color = "white", fill = "dodgerblue") +
  facet_grid(genre ~ .)

## ------------------------------------------------------------------------
summary_ratings <- movies_genre_sample %>% 
  group_by(genre) %>%
  summarize(mean = mean(rating),
            std_dev = sd(rating),
            n = n())
summary_ratings %>% kable()

## ------------------------------------------------------------------------
mean_ratings <- movies_genre_sample %>% 
  group_by(genre) %>%
  summarize(mean = mean(rating))
obs_diff <- diff(mean_ratings$mean)

## ----message=FALSE, warning=FALSE----------------------------------------
shuffled_ratings <- #movies_trimmed %>%
  movies_genre_sample %>% 
     mutate(genre = shuffle(genre)) %>% 
     group_by(genre) %>%
     summarize(mean = mean(rating))
diff(shuffled_ratings$mean)

## ----include=FALSE-------------------------------------------------------
set.seed(2017)
if(!file.exists("rds/many_shuffles.rds")){
  many_shuffles <- do(5000) * 
    (movies_genre_sample %>% 
     mutate(genre = shuffle(genre)) %>% 
      group_by(genre) %>%
      summarize(mean = mean(rating))
    )
   saveRDS(object = many_shuffles, "rds/many_shuffles.rds")
} else {
   many_shuffles <- readRDS("rds/many_shuffles.rds")
}

## ----eval=FALSE----------------------------------------------------------
## set.seed(2017)
## many_shuffles <- do(5000) *
##   (movies_genre_sample %>%
##      mutate(genre = shuffle(genre)) %>%
##      group_by(genre) %>%
##      summarize(mean = mean(rating))
##    )

## ------------------------------------------------------------------------
rand_distn <- many_shuffles %>%
  group_by(.index) %>%
  summarize(diffmean = diff(mean))
head(rand_distn, 10)

## ----fig.cap="Simulated differences in means histogram"------------------
ggplot(data = rand_distn, aes(x = diffmean)) +
  geom_histogram(color = "white", bins = 20)

## ----fig.cap="Shaded histogram to show p-value"--------------------------
ggplot(data = rand_distn, aes(x = diffmean, fill = (abs(diffmean) >= obs_diff))) +
  geom_histogram(color = "white", bins = 20)

## ----fig.cap="Histogram with vertical lines corresponding to observed statistic"----
ggplot(data = rand_distn, aes(x = diffmean)) +
  geom_histogram(color = "white", bins = 100) +
  geom_vline(xintercept = obs_diff, color = "red") +
  geom_vline(xintercept = -obs_diff, color = "red")

## ------------------------------------------------------------------------
(pvalue_movies <- rand_distn %>%
  filter(abs(diffmean) >= obs_diff) %>%
  nrow() / nrow(rand_distn))

## ----echo=FALSE----------------------------------------------------------
ggplot(data.frame(x = c(-4, 4)), aes(x)) + stat_function(fun = dnorm)

## ----fig.cap="Simulated differences in means histogram"------------------
ggplot(data = rand_distn, aes(x = diffmean)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
kable(summary_ratings)

## ------------------------------------------------------------------------
s1 <- summary_ratings$std_dev[2]
s2 <- summary_ratings$std_dev[1]
n1 <- summary_ratings$n[2]
n2 <- summary_ratings$n[1]

## ------------------------------------------------------------------------
(denom_T <- sqrt( (s1^2 / n1) + (s2^2 / n2) ))

## ---- fig.cap="Simulated T statistics histogram"-------------------------
rand_distn <- rand_distn %>% 
  mutate(t_stat = diffmean / denom_T)
ggplot(data = rand_distn, aes(x = t_stat)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
ggplot(data = rand_distn, mapping = aes(x = t_stat)) +
  geom_histogram(aes(y = ..density..), color = "white", binwidth = 0.3) +
  stat_function(fun = dt,
    args = list(df = min(n1 - 1, n2 - 1)), 
    color = "royalblue", size = 2)

## ------------------------------------------------------------------------
(t_obs <- obs_diff / denom_T)

## ------------------------------------------------------------------------
ggplot(data = rand_distn, mapping = aes(x = t_stat)) +
  stat_function(fun = dt,
    args = list(df = min(n1 - 1, n2 - 1)), 
    color = "royalblue", size = 2) +
  geom_vline(xintercept = t_obs, color = "red") +
  geom_vline(xintercept = -t_obs, color = "red")

## ------------------------------------------------------------------------
pt(t_obs, df = min(n1 - 1, n2 - 1), lower.tail = FALSE) +
  pt(-t_obs, df = min(n1 - 1, n2 - 1), lower.tail = TRUE)

## ----warning=FALSE-------------------------------------------------------
# To ensure the random sample of 50 flights is the same for
# anyone using this code
set.seed(2017)

# Load Alaska data, deleting rows that have missing departure delay
# or arrival delay data
alaska_flights <- flights %>% 
  filter(carrier == "AS") %>% 
  filter(!is.na(dep_delay) & !is.na(arr_delay)) %>% 
  # Select 50 flights that don't have missing delay data
  sample_n(50)

## ---- echo=FALSE---------------------------------------------------------
# USED INTERNALLY: Least squares line values, used for in-text output
delay_fit <- lm(formula = arr_delay ~ dep_delay, data = alaska_flights)
intercept <- tidy(delay_fit, conf.int=TRUE)$estimate[1] %>% round(3)
slope <- tidy(delay_fit, conf.int=TRUE)$estimate[2] %>% round(3)
CI_intercept <- c(tidy(delay_fit, conf.int=TRUE)$conf.low[1], tidy(delay_fit, conf.int=TRUE)$conf.high[1]) %>% round(3)
CI_slope <- c(tidy(delay_fit, conf.int=TRUE)$conf.low[2], tidy(delay_fit, conf.int=TRUE)$conf.high[2]) %>% round(3)

## ------------------------------------------------------------------------
delay_fit <- lm(formula = arr_delay ~ dep_delay, data = alaska_flights)
(b1_obs <- tidy(delay_fit)$estimate[2])

## ---- include=FALSE------------------------------------------------------
if(!file.exists("rds/rand_slope_distn.rds")){
  rand_slope_distn <- do(5000) *
  (lm(formula = arr_delay ~ shuffle(dep_delay), data = alaska_flights) %>%
     coef())
  saveRDS(object = rand_slope_distn, "rds/rand_slope_distn.rds")
} else {
  rand_slope_distn <- readRDS("rds/rand_slope_distn.rds")
}

## ----many_shuffles_reg, eval=FALSE---------------------------------------
## rand_slope_distn <- do(5000) *
##   (lm(formula = arr_delay ~ shuffle(dep_delay), data = alaska_flights) %>%
##      coef())

## ------------------------------------------------------------------------
names(rand_slope_distn)

## ------------------------------------------------------------------------
ggplot(data = rand_slope_distn, mapping = aes(x = dep_delay)) +
  geom_histogram(color = "white", bins = 20)

## ----fig.cap="Shaded histogram to show p-value"--------------------------
ggplot(data = rand_slope_distn, aes(x = dep_delay, fill = (dep_delay >= b1_obs))) +
  geom_histogram(color = "white", bins = 20)

## ---- echo=FALSE---------------------------------------------------------
delay_fit <- lm(formula = arr_delay ~ dep_delay, data = alaska_flights)
tidy(delay_fit) %>% 
  kable()

## ----echo=FALSE----------------------------------------------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  annotate("point", x = 44, y = 7, color = "blue", size = 3) +
  annotate("segment", x = 44, xend = 44, y = 7, yend = -14.155 + 1.218 * 44,
  color = "blue", arrow = arrow(length = unit(0.03, "npc")))

## ------------------------------------------------------------------------
regression_points <- augment(delay_fit) %>% 
  select(arr_delay, dep_delay, .fitted, .resid)
regression_points %>% 
  head() %>% 
  kable()

## ----resid-histogram-----------------------------------------------------
ggplot(data = regression_points, mapping = aes(x = .resid)) +
  geom_histogram(binwidth = 10, color = "white") +
  geom_vline(xintercept = 0, color = "blue")

## ----resid-plot, fig.cap="Fitted versus Residuals plot"------------------
ggplot(data = regression_points, mapping = aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 0, color = "blue")

## ----qqplot1, fig.cap="QQ Plot of residuals"-----------------------------
ggplot(data = regression_points, mapping = aes(sample = .resid)) +
  stat_qq()

