## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(moderndive)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(patchwork)
set.seed(79)

## ---- eval=FALSE---------------------------------------------------------
## tactile_prop_red
## View(tactile_prop_red)

## ----tactile-prop-red, echo=FALSE, message=FALSE, warning=FALSE----------
tactile_prop_red %>% 
  kable(
    digits = 2,
    caption = "33 sample proportions based on 33 tactile samples with n = 50", 
    booktabs = TRUE
  )

## ----eval=FALSE----------------------------------------------------------
## ggplot(tactile_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, color = "white") +
##   labs(x = "Sample proportion red based on n = 50", title = "Sampling distribution of p-hat")

## ----samplingdistribution-tactile, echo=FALSE, fig.cap="Sampling distribution of 33 sample proportions based on 33 tactile samples with n=50"----
tactile_histogram <- ggplot(tactile_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, color = "white")
tactile_histogram + 
    labs(
      x = expression(paste("Sample proportion red ", hat(p), " based on n = 50")), 
      title = expression(paste("Sampling distribution of ", hat(p)))
      )

## ---- eval=FALSE---------------------------------------------------------
## tactile_prop_red %>%
##   summarize(mean = mean(prop_red), sd = sd(prop_red))

## ---- echo=FALSE---------------------------------------------------------
summary_stats <- tactile_prop_red %>% 
  summarize(mean = mean(prop_red), sd = sd(prop_red))
summary_stats %>% 
  kable(digits = 3)

## ------------------------------------------------------------------------
bowl

## ---- eval=FALSE---------------------------------------------------------
## virtual_shovel <- bowl %>%
##   rep_sample_n(size = 50)
## View(virtual_shovel)

## ---- echo=FALSE---------------------------------------------------------
virtual_shovel <- bowl %>% 
  rep_sample_n(size = 50)
virtual_shovel %>% 
  slice(1:10) %>%
  knitr::kable(
    align = c("r", "r"),
    digits = 3,
    caption = "First 10 sampled balls of 50 in virtual sample",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## virtual_shovel %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 50)

## ---- echo=FALSE---------------------------------------------------------
virtual_shovel %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50) %>% 
  knitr::kable(
    digits = 3,
    caption = "Count and proportion red in single virtual sample of size n = 50",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## virtual_samples <- bowl %>%
##   rep_sample_n(size = 50, reps = 33)
## View(virtual_samples)

## ---- echo=FALSE---------------------------------------------------------
virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 33)

## ---- eval=FALSE---------------------------------------------------------
## virtual_prop_red <- virtual_samples %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 50)
## View(virtual_prop_red)

## ----virtual-prop-red, echo=FALSE----------------------------------------
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)
virtual_prop_red %>% 
  kable(
    digits = 2,
    caption = "33 sample proportions red based on 33 virtual samples with n=50", 
    booktabs = TRUE
  )

## ---- eval = FALSE-------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, color = "white") +
##   labs(x = "Sample proportion red based on n = 50", title = "Sampling distribution of p-hat")

## ----samplingdistribution-virtual, echo=FALSE, fig.cap="Sampling distribution of 33 sample proportions based on 33 virtual samples with n=50"----
virtual_histogram <- ggplot(virtual_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, color = "white")
virtual_histogram +
    labs(
      x = expression(paste("Sample proportion red ", hat(p), " based on n = 50")), 
      title = expression(paste("Sampling distribution of ", hat(p)))
      )

## ----tactile-vs-virtual, echo=FALSE, fig.cap="Comparison of sampling distributions based on 33 tactile & virtual samples with n=50"----
tactile_histogram <- tactile_histogram +
  labs(
    x = expression(paste("Sample proportion red ", hat(p), " based on n = 50")), 
    title = "Sampling distribution: Tactile"
    )
virtual_histogram <- virtual_histogram +
  labs(
    x = expression(paste("Sample proportion red ", hat(p), " based on n = 50")), 
    title = "Sampling distribution: Virtual"
    )
# using patchwork package for ggplot compositions
tactile_histogram + virtual_histogram

## ---- eval=FALSE---------------------------------------------------------
## virtual_samples <- bowl %>%
##   rep_sample_n(size = 50, reps = 1000)
## View(virtual_samples)

## ---- echo=FALSE---------------------------------------------------------
virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 1000)

## ---- eval=FALSE---------------------------------------------------------
## virtual_prop_red <- virtual_samples %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 50)
## View(virtual_prop_red)

## ---- echo=FALSE---------------------------------------------------------
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

## ---- eval=FALSE---------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, color = "white") +
##   labs(x = "Sample proportion red based on n = 50", title = "Sampling distribution of p-hat")

## ----samplingdistribution-virtual-1000, echo=FALSE, fig.cap="Sampling distribution of 1000 sample proportions based on 1000 tactile samples with n=50"----
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

ggplot(virtual_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, color = "white") +
    labs(
      x = expression(paste("Sample proportion red ", hat(p), " based on n = 50")), 
      title = expression(paste("Sampling distribution of ", hat(p)))
      )

## ------------------------------------------------------------------------
virtual_prop_red %>% 
  summarize(SE = sd(prop_red))

## ------------------------------------------------------------------------
virtual_samples_50 <- bowl %>% 
  rep_sample_n(size = 50, reps = 1000)

## ------------------------------------------------------------------------
virtual_prop_red_50 <- virtual_samples_50 %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

## ------------------------------------------------------------------------
virtual_prop_red_50 %>% 
  summarize(SE = sd(prop_red))

## ------------------------------------------------------------------------
virtual_samples_25 <- bowl %>% 
  rep_sample_n(size = 25, reps = 1000)

## ------------------------------------------------------------------------
virtual_prop_red_25 <- virtual_samples_25 %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 25)

## ------------------------------------------------------------------------
virtual_prop_red_25 %>% 
  summarize(SE = sd(prop_red))

## ------------------------------------------------------------------------
virtual_samples_100 <- bowl %>% 
  rep_sample_n(size = 100, reps = 1000)

## ------------------------------------------------------------------------
virtual_prop_red_100 <- virtual_samples_100 %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 100)

## ------------------------------------------------------------------------
virtual_prop_red_100 %>% 
  summarize(SE = sd(prop_red))

## ----comparing-n, echo = FALSE-------------------------------------------
virtual_prop_red_25 <- virtual_prop_red_25 %>% 
  mutate(n = 25)
virtual_prop_red_50 <- virtual_prop_red_50 %>% 
  mutate(n = 50)
virtual_prop_red_100 <- virtual_prop_red_100 %>% 
  mutate(n = 100)

virtual_prop <- virtual_prop_red_25 %>% 
  bind_rows(virtual_prop_red_50) %>% 
  bind_rows(virtual_prop_red_100)

virtual_prop %>% 
  group_by(n) %>% 
  summarize(SE = sd(prop_red)) %>% 
  kable(
    digits = 4,
    caption = "Comparing the SE for different n", 
    booktabs = TRUE
  )

## ----comparing-sampling-distributions, echo = FALSE, fig.cap="Comparing sampling distributions of p-hat for different sample sizes n"----
ggplot(virtual_prop, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, color = "white") +
  labs(x = "Sample proportion red", title = "Comparing sampling distributions of p-hat for different sample sizes n") +
  facet_wrap(~n)

