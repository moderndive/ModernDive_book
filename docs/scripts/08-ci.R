## ----setup_ci, include=FALSE---------------------------------------------
chap <- 8
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**
knitr::opts_chunk$set(tidy = FALSE, out.width='\\textwidth')

## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(mosaic)
library(knitr)

## ------------------------------------------------------------------------
library(ggplot2movies)
data(movies, package = "ggplot2movies")

## ----fig.cap="Population ratings histogram"------------------------------
movies %>% ggplot(aes(x = rating)) +
  geom_histogram(color = "white", bins = 20)

## ----lc7-3, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ------------------------------------------------------------------------
set.seed(2017)
library(mosaic)
library(dplyr)
movies_sample <- movies %>% resample(size = 50, replace = FALSE)

## ----fig.cap="Sample ratings histogram"----------------------------------
movies_sample %>% ggplot(aes(x = rating)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
(movies_sample_mean <- movies_sample %>% summarize(mean = mean(rating)))

## ------------------------------------------------------------------------
boot1 <- resample(movies_sample) %>%
  arrange(orig.id)

## ----lc6-3, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ------------------------------------------------------------------------
(movies_boot1_mean <- boot1 %>% summarize(mean = mean(rating)))

## ------------------------------------------------------------------------
do(10) * 
  (resample(movies_sample) %>% 
     summarize(mean = mean(rating)))

## ----cache=TRUE, fig.cap="Bootstrapped means histogram"------------------
trials <- do(10000) * summarize(resample(movies_sample), 
                                mean = mean(rating))
ggplot(data = trials, mapping = aes(x = mean)) +
  geom_histogram(bins = 30, color = "white")

## ------------------------------------------------------------------------
(ciq_mean_rating <- confint(trials, level = 0.95, method = "quantile"))

## ----ci-coverage, echo=FALSE, fig.cap="Confidence interval coverage plot from OpenIntro"----
knitr::include_graphics("images/cis.png")

## ------------------------------------------------------------------------
movies %>% summarize(mean_rating = mean(rating))

## ----warning=FALSE, message=FALSE----------------------------------------
(cise_mean_rating <- confint(trials, level = 0.95, method = "stderr"))

## ----lc7-4, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----bootstrapimg, echo=FALSE, fig.cap="Bootstrapping diagram from Lock5 textbook"----
knitr::include_graphics("images/bootstrap.png")

## ----fig.cap="Simulated shuffled sample means histogram"-----------------
library(ggplot2)
library(dplyr)
ggplot(data = rand_distn, mapping = aes(x = diffmean)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
(std_err <- rand_distn %>% summarize(se = sd(diffmean)))

## ------------------------------------------------------------------------
(lower <- obs_diff - (2 * std_err))
(upper <- obs_diff + (2 * std_err))

## ----lc8-1, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ------------------------------------------------------------------------
df1 <- data_frame(samp1 = rexp(50))
df2 <- data_frame(samp2 = rnorm(100))
df3 <- data_frame(samp3 = rbeta(20,5,5))

## ----include=FALSE, eval=FALSE-------------------------------------------
## knitr::purl("08-ci.Rmd", "docs/scripts/08-ci.R")

