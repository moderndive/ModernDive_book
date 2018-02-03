## ---- message=FALSE, warning=FALSE---------------------------------------
library(dplyr)
library(ggplot2)
library(infer)

# Clean data
mtcars <- mtcars %>%
  as_tibble() %>% 
  mutate(am = factor(am))

# Simulate sampling distribution of two-sample difference in means:
sampling_distribution <- mtcars %>%
  specify(mpg ~ am) %>%
  generate(reps = 1000, type = "bootstrap") %>%
  calculate(stat = "diff in means", order = c("1", "0")) 

# Compute 95% confidence interval:
conf_int <- sampling_distribution %>% 
  pull(stat) %>% 
  quantile(probs = c(0.025, 0.975))

# Visualize:
plot <- sampling_distribution %>% 
  visualize()
plot +
  geom_vline(xintercept = conf_int, col = "red", size = 1)

## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(infer)
library(mosaic)
library(knitr)
library(ggplot2movies)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.

## ----fig.cap="Population ratings histogram"------------------------------
movies %>% ggplot(aes(x = rating)) +
  geom_histogram(color = "white", bins = 20)

## **_Learning check_**

## ------------------------------------------------------------------------
set.seed(2017)
movies_sample <- movies %>% 
  sample_n(50)

## ----fig.cap="Sample ratings histogram"----------------------------------
ggplot(data = movies_sample, aes(x = rating)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
(movies_sample_mean <- movies_sample %>% 
   summarize(mean = mean(rating)))

## ------------------------------------------------------------------------
boot1 <- resample(movies_sample) %>%
  arrange(orig.id)

## ------------------------------------------------------------------------
(movies_boot1_mean <- boot1 %>% summarize(mean = mean(rating)))

## ------------------------------------------------------------------------
do(10) * 
  (resample(movies_sample) %>% 
     summarize(mean = mean(rating)))

## ---- include=FALSE------------------------------------------------------
if(!file.exists("rds/trials.rds")){
  trials <- do(5000) * summarize(resample(movies_sample), mean = mean(rating))
  saveRDS(object = trials, "rds/trials.rds")
} else {
  trials <- readRDS("rds/trials.rds")
}

## ---- eval=FALSE---------------------------------------------------------
## trials <- do(5000) * summarize(resample(movies_sample), mean = mean(rating))

## ---- fig.cap="Bootstrapped means histogram"-----------------------------
ggplot(data = trials, mapping = aes(x = mean)) +
  geom_histogram(bins = 30, color = "white")

## ------------------------------------------------------------------------
(ciq_mean_rating <- confint(trials, level = 0.95, method = "quantile"))

## ------------------------------------------------------------------------
movies %>% summarize(mean_rating = mean(rating))

## ----warning=FALSE, message=FALSE----------------------------------------
(cise_mean_rating <- confint(trials, level = 0.95, method = "stderr"))

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

## ------------------------------------------------------------------------
set.seed(2017)
movies_genre_sample <- movies_trimmed %>% 
  group_by(genre) %>%
  sample_n(34) %>% 
  ungroup()

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

## ----fig.cap="Simulated shuffled sample means histogram"-----------------
ggplot(data = rand_distn, mapping = aes(x = diffmean)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
(std_err <- rand_distn %>% summarize(se = sd(diffmean)))

## ------------------------------------------------------------------------
(lower <- obs_diff - (2 * std_err))
(upper <- obs_diff + (2 * std_err))

## ------------------------------------------------------------------------
df1 <- data_frame(samp1 = rexp(50))
df2 <- data_frame(samp2 = rnorm(100))
df3 <- data_frame(samp3 = rbeta(20, 5, 5))

