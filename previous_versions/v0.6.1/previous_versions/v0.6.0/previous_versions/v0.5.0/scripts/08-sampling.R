## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(moderndive)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)
library(patchwork)
library(readr)
library(stringr)














## ---- eval=FALSE---------------------------------------------------------
## tactile_prop_red
## View(tactile_prop_red)


## ----tactilered, echo=FALSE----------------------------------------------
tactile_prop_red %>% 
  slice(1:10) %>% 
  kable(
    digits = 3,
    caption = "First 10 out of 33 groups' proportion of 50 balls that are red.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ----eval=FALSE----------------------------------------------------------
## ggplot(tactile_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red",
##        title = "Distribution of 33 proportions red")

## ----samplingdistribution-tactile, echo=FALSE, fig.cap="Distribution of 33 proportions based on 33 samples of size 50"----
tactile_histogram <- ggplot(tactile_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white")
tactile_histogram + 
  labs(x = "Proportion of 50 balls that were red", 
       title = "Distribution of 33 proportions red")


## ------------------------------------------------------------------------
bowl


## ---- eval=FALSE---------------------------------------------------------
## virtual_shovel <- bowl %>%
##   rep_sample_n(size = 50)
## View(virtual_shovel)


## ----virtual-shovel, echo=FALSE------------------------------------------
virtual_shovel <- bowl %>% 
  rep_sample_n(size = 50)
virtual_shovel %>% 
  slice(1:10) %>%
  knitr::kable(
    align = c("r", "r"),
    digits = 3,
    caption = "First 10 sampled balls of 50 in virtual sample",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ------------------------------------------------------------------------
virtual_shovel %>% 
  mutate(is_red = (color == "red"))


## ------------------------------------------------------------------------
virtual_shovel %>% 
  mutate(is_red = (color == "red")) %>% 
  summarize(num_red = sum(is_red))  


## ------------------------------------------------------------------------
virtual_shovel %>% 
  mutate(is_red = color == "red") %>% 
  summarize(num_red = sum(is_red)) %>% 
  mutate(prop_red = num_red / 50)


## ------------------------------------------------------------------------
virtual_shovel %>% 
  summarize(num_red = sum(color == "red")) %>% 
  mutate(prop_red = num_red / 50)


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


## ----virtualred, echo=FALSE----------------------------------------------
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)

virtual_histogram <- ggplot(virtual_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white")

virtual_prop_red %>% 
  slice(1:10) %>% 
  kable(
    digits = 3,
    caption = "First 10 out of 33 virtual proportion of 50 balls that are red.", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ----eval=FALSE----------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red",
##        title = "Distribution of 33 proportions red")

## ----samplingdistribution-virtual, echo=FALSE, fig.cap="Distribution of 33 proportions based on 33 samples of size 50"----
virtual_histogram <- ggplot(virtual_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white")
virtual_histogram + 
  labs(x = "Proportion of 50 balls that were red", 
       title = "Distribution of 33 proportions red")


## ----tactile-vs-virtual, echo=FALSE, fig.cap="Comparing 33 virtual and 33 tactile proportions red."----
bind_rows(
  virtual_prop_red %>% 
    mutate(type = "Virtual sampling"), 
  tactile_prop_red %>% 
    select(replicate, red = red_balls, prop_red) %>% 
    mutate(type = "Tactile sampling")
) %>% 
  mutate(type = factor(type, levels = c("Virtual sampling", "Tactile sampling"))) %>% 
  ggplot(aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
  facet_wrap(~type) +
  labs(x = "Proportion of 50 balls that were red", 
         title = "Comparing distributions")


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


## ----eval=FALSE----------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red",
##        title = "Distribution of 1000 proportions red")

## ----samplingdistribution-virtual-1000, echo=FALSE, fig.cap="Distribution of 1000 proportions based on 33 samples of size 50"----
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)
virtual_histogram <- ggplot(virtual_prop_red, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white")
virtual_histogram + 
  labs(x = "Proportion of 50 balls that were red", 
       title = "Distribution of 1000 proportions red")


## ---- eval = FALSE-------------------------------------------------------
## # Segment 1: sample size = 25 ------------------------------
## # 1.a) Virtually use shovel 1000 times
## virtual_samples_25 <- bowl %>%
##   rep_sample_n(size = 25, reps = 1000)
## 
## # 1.b) Compute resulting 1000 replicates of proportion red
## virtual_prop_red_25 <- virtual_samples_25 %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 25)
## 
## # 1.c) Plot distribution via a histogram
## ggplot(virtual_prop_red_25, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 25 balls that were red", title = "25")
## 
## # Segment 2: sample size = 50 ------------------------------
## # 2.a) Virtually use shovel 1000 times
## virtual_samples_50 <- bowl %>%
##   rep_sample_n(size = 50, reps = 1000)
## 
## # 2.b) Compute resulting 1000 replicates of proportion red
## virtual_prop_red_50 <- virtual_samples_50 %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 50)
## 
## # 2.c) Plot distribution via a histogram
## ggplot(virtual_prop_red_50, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red", title = "50")
## 
## # Segment 3: sample size = 100 ------------------------------
## # 3.a) Virtually using shovel with 100 slots 1000 times
## virtual_samples_100 <- bowl %>%
##   rep_sample_n(size = 100, reps = 1000)
## 
## # 3.b) Compute resulting 1000 replicates of proportion red
## virtual_prop_red_100 <- virtual_samples_100 %>%
##   group_by(replicate) %>%
##   summarize(red = sum(color == "red")) %>%
##   mutate(prop_red = red / 100)
## 
## # 3.c) Plot distribution via a histogram
## ggplot(virtual_prop_red_100, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 100 balls that were red", title = "100")


## ----comparing-sampling-distributions, echo=FALSE, fig.cap="Comparing the distributions of proportion red for different sample sizes"----
# n = 25
virtual_samples_25 <- bowl %>% 
  rep_sample_n(size = 25, reps = 1000)
virtual_prop_red_25 <- virtual_samples_25 %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 25) %>% 
  mutate(n = 25)

# n = 50
virtual_samples_50 <- bowl %>% 
  rep_sample_n(size = 50, reps = 1000)
virtual_prop_red_50 <- virtual_samples_50 %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50) %>% 
  mutate(n = 50)

# n = 100
virtual_samples_100 <- bowl %>% 
  rep_sample_n(size = 100, reps = 1000)
virtual_prop_red_100 <- virtual_samples_100 %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 100) %>% 
  mutate(n = 100)

virtual_prop <- bind_rows(virtual_prop_red_25, virtual_prop_red_50, virtual_prop_red_100)

comparing_sampling_distributions <- ggplot(virtual_prop, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
  labs(x = "Proportion of shovel's balls that are red", title = "Comparing distributions of proportions red for 3 different shovels.") +
  facet_wrap(~n)
comparing_sampling_distributions


## ---- eval = FALSE-------------------------------------------------------
## # n = 25
## virtual_prop_red_25 %>%
##   summarize(sd = sd(prop_red))
## 
## # n = 50
## virtual_prop_red_50 %>%
##   summarize(sd = sd(prop_red))
## 
## # n = 100
## virtual_prop_red_100 %>%
##   summarize(sd = sd(prop_red))


## ----comparing-n, eval=TRUE, echo=FALSE----------------------------------
comparing_n_table <- virtual_prop %>% 
  group_by(n) %>% 
  summarize(sd = sd(prop_red)) %>% 
  rename(`Number of slots in shovel` = n, `Standard deviation of proportions red` = sd) 

comparing_n_table  %>% 
  kable(
    digits = 3,
      caption = "Comparing standard deviations of proportions red for 3 different shovels.", 
      booktabs = TRUE
) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----echo=FALSE----------------------------------------------------------
comparing_sampling_distributions


## ---- eval=TRUE, echo=FALSE----------------------------------------------
comparing_n_table  %>% 
  kable(digits = 3)


## ----comparing-sampling-distributions-2, echo=FALSE, fig.cap="Three sampling distributions of the sample proportion $\\widehat{p}$."----
virtual_prop %>% 
  mutate(
    n = str_c("n = ", n),
    n = factor(n, levels = c("n = 25", "n = 50", "n = 100"))
    ) %>% 
  ggplot( aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
  labs(x = expression(paste("Sample proportion ", hat(p))), 
       title = expression(paste("Sampling distributions of the sample proportion ", hat(p), " based on n = 25, 50, 100.")) ) +
  facet_wrap(~n)


## ----comparing-n-2, eval=TRUE, echo=FALSE--------------------------------
comparing_n_table <- virtual_prop %>% 
  group_by(n) %>% 
  summarize(sd = sd(prop_red)) %>% 
  mutate(
    n = str_c("n = ", n),
    n = factor(n, levels = c("n = 25", "n = 50", "n = 100"))
    ) %>% 
  rename(`Sample size` = n, `Standard error of $\\widehat{p}$` = sd) 

comparing_n_table  %>% 
  kable(
    digits = 3,
      caption = "Three standard errors of the sample proportion $\\widehat{p}$ based on n = 25, 50, 100. ", 
      booktabs = TRUE
) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ------------------------------------------------------------------------
bowl %>% 
  summarize(sum_red = sum(color == "red"), 
            sum_not_red = sum(color != "red"))


## ----comparing-sampling-distributions-3, echo=FALSE, fig.cap="Three sampling distributions with population proportion $p$ marked in red."----
p <- bowl %>% 
  summarize(p = mean(color == "red")) %>% 
  pull(p)
virtual_prop %>% 
  mutate(
    n = str_c("n = ", n),
    n = factor(n, levels = c("n = 25", "n = 50", "n = 100"))
    ) %>% 
  ggplot( aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
  labs(x = expression(paste("Sample proportion ", hat(p))), 
       title = expression(paste("Sampling distributions of the sample proportion ", hat(p), " based on n = 25, 50, 100.")) ) +
  facet_wrap(~n) +
  geom_vline(xintercept = p, col = "red", size = 1)




## ----summarytable-ch8, echo=FALSE, message=FALSE-------------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  kable(
    caption = "\\label{tab:summarytable-ch8}Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position")) %>%
  column_spec(1, width = "0.5in") %>% 
  column_spec(2, width = "0.7in") %>%
  column_spec(3, width = "1in") %>%
  column_spec(4, width = "1.1in") %>% 
  column_spec(5, width = "1in")

