## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(moderndive)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)

## ---- eval=FALSE---------------------------------------------------------
## bowl_samples

## ----students, echo=FALSE------------------------------------------------
bowl_samples %>% 
  knitr::kable(
    digits = 3,
    caption = "In real life: 10 samples of size 50",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## bowl_samples <- bowl_samples %>%
##   mutate(prop_red = red / n) %>%
##   select(group, prop_red)
## bowl_samples

## ----sample-prop-red, echo=FALSE-----------------------------------------
bowl_samples <- bowl_samples %>% 
  mutate(prop_red = red / n) %>% 
  select(group, prop_red)
bowl_samples %>%
  knitr::kable(
    digits = 3,
    caption = "In real life: 10 sample proportions red based on samples of size 50",
    booktabs = TRUE
  )

## ----samplingdistribution, echo=FALSE, fig.cap="In real life: 10 sample proportions red based on 10 samples of size 50"----
ggplot(bowl_samples, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, color = "white") +
  labs(x = "Sample proportion red in sample of size n=50", 
       y="Number of samples",
       title = "Sample proportion red in ten samples of size n=50") 

## ---- eval=FALSE---------------------------------------------------------
## bowl_samples %>%
##   summarize(mean = mean(prop_red), sd = sd(prop_red))

## ---- echo=FALSE---------------------------------------------------------
bowl_summaries <- bowl_samples %>% 
  summarize(mean = mean(prop_red), sd = sd(prop_red))
bowl_summaries %>% 
  kable(digits = 3)

## ---- eval=FALSE---------------------------------------------------------
## View(bowl)

## ---- echo=FALSE---------------------------------------------------------
bowl %>% 
  slice(1:10) %>%
  knitr::kable(
    align = c("r", "r"),
    digits = 3,
    caption = "First 10 balls in virtual sampling bowl",
    booktabs = TRUE
  )

## ---- echo=FALSE---------------------------------------------------------
set.seed(76)

## ---- eval=FALSE---------------------------------------------------------
## all_samples <- rep_sample_n(bowl, size = 50, reps = 10)
## View(all_samples)

## ---- echo=FALSE---------------------------------------------------------
all_samples <- rep_sample_n(bowl, size = 50, reps = 10)

## ---- eval=FALSE---------------------------------------------------------
## bowl_samples_virtual <- all_samples %>%
##   mutate(is_red = color == "red") %>%
##   group_by(replicate) %>%
##   summarize(prop_red = mean(is_red))
## bowl_samples_virtual

## ----sample-prop-red-virtual, echo=FALSE---------------------------------
bowl_samples_virtual <- all_samples %>% 
  mutate(is_red = color == "red") %>% 
  group_by(replicate) %>% 
  summarize(prop_red = mean(is_red))
bowl_samples_virtual %>%
  knitr::kable(
    digits = 3,
    caption = "Virtual simulation: 10 sample proportions red based on samples of size 50",
    booktabs = TRUE
  )

## ----sampling-distribution-virtual, echo=FALSE, fig.cap="Virtual simulation: 10 sample proportions red based on 10 samples of size 50"----
ggplot(bowl_samples_virtual, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.05, color = "white") +
  labs(x="Sample proportion red in sample of size n=50", y="Number of samples",
       title="Sample proportion red in ten samples of size n=50") 

## ---- eval=FALSE---------------------------------------------------------
## bowl_samples_virtual %>%
##   summarize(mean = mean(prop_red), sd = sd(prop_red))

## ---- echo=FALSE---------------------------------------------------------
bowl_summaries_virtual <- bowl_samples %>% 
  summarize(mean = mean(prop_red), sd = sd(prop_red))
bowl_summaries %>% 
  kable(digits = 3)

## ---- echo=FALSE---------------------------------------------------------
set.seed(76)

## ----sampling-distribution-virtual-2, echo=TRUE, fig.cap="Virtual simulation: Ten thousand sample proportions red based on ten thousand samples of size 50"----
# Draw ten thousand samples of size n = 50
all_samples <- rep_sample_n(bowl, size = 50, reps = 10000)

# For each sample, as marked by the variable `replicate`, compute the proportion red
bowl_samples_virtual <- all_samples %>% 
  mutate(is_red = (color == "red")) %>% 
  group_by(replicate) %>% 
  summarize(prop_red = mean(is_red))

# Plot the histogram
ggplot(bowl_samples_virtual, aes(x = prop_red)) +
  geom_histogram(binwidth = 0.02, color = "white") +
  labs(x = "Sample proportion red in sample of size n=50", y="Number of samples",
       title = "Sample proportion red in ten samples of size n=50") 

## ---- eval=FALSE---------------------------------------------------------
## bowl_samples_virtual %>%
##   summarize(mean = mean(prop_red), sd = sd(prop_red))

## ---- echo=FALSE---------------------------------------------------------
bowl_summaries_virtual <- bowl_samples %>% 
  summarize(mean = mean(prop_red), sd = sd(prop_red))
bowl_summaries %>% 
  kable(digits = 3)

