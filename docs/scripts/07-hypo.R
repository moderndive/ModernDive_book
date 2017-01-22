## ----setup_hypo, include=FALSE-------------------------------------------
chap <- 7
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**
knitr::opts_chunk$set(tidy = FALSE, out.width = '\\textwidth')

## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(mosaic)
library(knitr)
library(nycflights13)

## ------------------------------------------------------------------------
library(nycflights13)
data(flights)
bos_sfo <- flights %>% na.omit() %>% 
  filter(dest %in% c("BOS", "SFO")) %>% 
  group_by(dest) %>% 
  sample_n(100)

## ------------------------------------------------------------------------
library(dplyr)
bos_sfo_summary <- bos_sfo %>% group_by(dest) %>% 
  summarize(mean_time = mean(air_time),
            sd_time = sd(air_time))
kable(bos_sfo_summary)

## ----lc6-2b, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ------------------------------------------------------------------------
library(ggplot2)
ggplot(data = bos_sfo, mapping = aes(x = dest, y = air_time)) +
  geom_boxplot()

## ----htdowney, echo=FALSE, fig.cap="Hypothesis Testing Framework"--------
knitr::include_graphics("images/ht.png")

## ---- echo=FALSE, fig.cap="Type I and Type II errors"--------------------
knitr::include_graphics("images/errors.png")

## ----lc7-0, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----lc7-1, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----htdowney2, echo=FALSE, fig.cap="Hypothesis Testing Framework"-------
knitr::include_graphics("images/ht.png")

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
library(ggplot2)
ggplot(data = simGuesses, aes(x = factor(heads))) +
  geom_bar()

## ------------------------------------------------------------------------
pvalue_tea <- simGuesses %>%
  filter(heads >= 9) %>%
  nrow() / nrow(simGuesses)

## ----fig.cap="Barplot of heads with p-value highlighted"-----------------
library(ggplot2)
  ggplot(data = simGuesses, aes(x = factor(heads), fill = (heads >= 9))) +
  geom_bar() +
  labs(x = "heads")

## ----lc6-2, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2movies)
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

## ----lc7-2, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----fig.cap="Rating vs genre in the population"-------------------------
library(ggplot2)
ggplot(data = movies_trimmed, aes(x = genre, y = rating)) +
  geom_boxplot()

## ----movie-hist, warning=FALSE, fig.cap="Faceted histogram of genre vs rating"----
ggplot(data = movies_trimmed, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white", fill = "dodgerblue") +
  facet_grid(genre ~ .)

## ----lc7-3a, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ------------------------------------------------------------------------
library(dplyr)
library(mosaic)
set.seed(2016)
movies_genre_sample <- movies_trimmed %>% 
  group_by(genre) %>%
  sample_n(34)

## ----fig.cap="Genre vs rating for our sample"----------------------------
ggplot(data = movies_genre_sample, aes(x = genre, y = rating)) +
  geom_boxplot()

## ----warning=FALSE, fig.cap="Genre vs rating for our sample as faceted histogram"----
ggplot(data = movies_genre_sample, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white", fill = "dodgerblue") +
  facet_grid(genre ~ .)

## ----lc7-3b1, type='learncheck', engine="block"--------------------------
**_Learning check_**

## ------------------------------------------------------------------------
summary_ratings <- movies_genre_sample %>% 
  group_by(genre) %>%
  summarize(mean = mean(rating),
            std_dev = sd(rating),
            n = n())
summary_ratings %>% kable()

## ----lc7-3b2, type='learncheck', engine="block"--------------------------
**_Learning check_**

## ----lc7-3b3, type='learncheck', engine="block"--------------------------
**_Learning check_**

## ------------------------------------------------------------------------
mean_ratings <- movies_genre_sample %>% group_by(genre) %>%
  summarize(mean = mean(rating))
obs_diff <- diff(mean_ratings$mean)

## ----message=FALSE, warning=FALSE----------------------------------------
library(mosaic)
shuffled_ratings <- movies_trimmed %>%
     mutate(rating = shuffle(rating)) %>% 
     group_by(genre) %>%
     summarize(mean = mean(rating))
diff(shuffled_ratings$mean)

## ----lc7-3b4, type='learncheck', engine="block"--------------------------
**_Learning check_**

## ----cache=TRUE----------------------------------------------------------
set.seed(2016)
many_shuffles <- do(10000) * 
  (movies_trimmed %>%
     mutate(rating = shuffle(rating)) %>% 
     group_by(genre) %>%
     summarize(mean = mean(rating))
   )

## ------------------------------------------------------------------------
rand_distn <- many_shuffles %>%
  group_by(.index) %>%
  summarize(diffmean = diff(mean))

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

## ----lc7-3b, type='learncheck', engine="block"---------------------------
**_Learning check_**

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
  mutate(t_stat = diffmean / denom_T * 10)
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

## ----include=FALSE, eval=FALSE-------------------------------------------
## knitr::purl("07-hypo.Rmd", "docs/scripts/07-hypo.R")

