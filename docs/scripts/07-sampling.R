## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)






## -----------------------------------------------------------------------------
bowl


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = (color == "red"))


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = (color == "red")) |> 
  summarize(num_red = sum(is_red))


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = (color == "red")) |> 
  summarize(prop_red = mean(is_red))


## -----------------------------------------------------------------------------
bowl |> 
  summarize(prop_red = mean(color == "red"))












## -----------------------------------------------------------------------------
tactile_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(tactile_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of red balls in each sample",
##        title = "Histogram of 33 proportions")







## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_shovel <- bowl |> 
  rep_slice_sample(n = 50)
virtual_shovel


## ----echo=-c(1, 2)------------------------------------------------------------
# Neat way to remove from output particular code pieces!
prop_red_sample1 <- virtual_shovel |> 
  summarize(prop_red = mean(color == "red")) |> 
  pull(prop_red)
virtual_shovel |> 
 summarize(prop_red = mean(color == "red"))


## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_samples <- bowl |> 
  rep_slice_sample(n = 50, reps = 33)
virtual_samples


## -----------------------------------------------------------------------------
virtual_prop_red <- virtual_samples |> 
  group_by(replicate) |> 
  summarize(prop_red = mean(color == "red")) 
virtual_prop_red


## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_prop_red <- bowl |> 
  rep_slice_sample(n = 50, reps = 33) |>
  summarize(prop_red = mean(color == "red"))
virtual_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Sample proportion",
##        title = "Histogram of 33 sample proportions")









## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_prop_red <- bowl |> 
  rep_slice_sample(n = 50, reps = 1000) |> 
  summarize(prop_red = mean(color == "red"))
virtual_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.04, boundary = 0.4, color = "white") +
##   labs(x = "Sample proportion",
##        title = "Histogram of 1000 sample proportions")









## ----eval=FALSE---------------------------------------------------------------
## # Segment 1: sample size = 25 ------------------------------
## # 1.a) Compute sample proportions for 1000 samples, each sample of size 25
## virtual_prop_red_25 <- bowl |>
##   rep_slice_sample(n = 25, reps = 1000) |>
##   summarize(prop_red = mean(color == "red"))
## 
## # 1.b) Plot a histogram to represent the distribution of the sample proportions
## ggplot(virtual_prop_red_25, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 25 balls that were red", title = "25")
## 
## 
## # Segment 2: sample size = 50 ------------------------------
## # 2.a) Compute sample proportions for 1000 samples, each sample of size 50
## virtual_prop_red_50 <- bowl |>
##   rep_slice_sample(n = 50, reps = 1000) |>
##   summarize(prop_red = mean(color == "red"))
## 
## # 2.b) Plot a histogram to represent the distribution of the sample proportions
## ggplot(virtual_prop_red_50, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red", title = "50")
## 
## 
## # Segment 3: sample size = 100 ------------------------------
## # 2.a) Compute sample proportions for 1000 samples, each sample of size 100
## virtual_prop_red_100 <- bowl |>
##   rep_slice_sample(n = 100, reps = 1000) |>
##   summarize(prop_red = mean(color == "red"))
## 
## # 3.b) Plot a histogram to represent the distribution of the sample proportions
## ggplot(virtual_prop_red_100, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 100 balls that were red", title = "100")














## -----------------------------------------------------------------------------
virtual_prop_red_25
virtual_prop_red_25 |> 
  summarize(E_Xbar_25 = mean(prop_red))


## ----eval=FALSE---------------------------------------------------------------
## virtual_prop_red_50 |>
##   summarize(E_Xbar_50 = mean(prop_red))
## virtual_prop_red_100 |>
##   summarize(E_Xbar_100 = mean(prop_red))


## ----echo=FALSE---------------------------------------------------------------
e_xbar_50 <- virtual_prop_red_50 |> 
  summarize(E_Xbar_50 = mean(prop_red))
e_xbar_100 <- virtual_prop_red_100 |> 
  summarize(E_Xbar_100 = mean(prop_red))
e_xbar_50_pull <- e_xbar_50 |> pull(E_Xbar_50)
e_xbar_100_pull <- e_xbar_100 |> pull(E_Xbar_100)
e_xbar_50
e_xbar_100


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = color == "red") |> 
  summarize(p = mean(is_red), st_dev = sd(is_red))


## -----------------------------------------------------------------------------
p <- 0.375
sqrt(p * (1 - p))


## -----------------------------------------------------------------------------
bowl |>
  rep_slice_sample(n = 100, replace = TRUE, reps = 10000) |>
  summarize(prop_red = mean(color == "red")) |>
  summarize(p = mean(prop_red), SE_Xbar = sd(prop_red))


## -----------------------------------------------------------------------------
p = 0.375
sqrt(p*(1-p)/100)


## -----------------------------------------------------------------------------
virtual_prop_red_25 |> 
  summarize(SE_Xbar_50 = sd(prop_red))
virtual_prop_red_50 |> 
  summarize(SE_Xbar_100 = sd(prop_red))


## -----------------------------------------------------------------------------
sqrt(p * (1 - p) / 25)
sqrt(p * (1 - p) / 50)












## ----echo=1-------------------------------------------------------------------
almonds_bowl
num_pop_almonds <- length(almonds_bowl$weight)


## -----------------------------------------------------------------------------
almonds_bowl |> 
  summarize(mean_weight = mean(weight), 
            sd_weight = sd(weight), 
            length = n())


## ----almonds-bowl-histogram, fig.cap="Distribution of weights for the entire bowl of almonds."----
ggplot(almonds_bowl, aes(x = weight)) +
  geom_histogram(binwidth = 0.1, color = "white")






## ----echo=2:4, eval=FALSE-----------------------------------------------------
## set.seed(2024)
## almonds_sample <- almonds_bowl |>
##   rep_slice_sample(n = 25, reps = 1)
## almonds_sample


## ----echo=FALSE---------------------------------------------------------------
num_almonds <- length(almonds_sample$weight)


## ----almonds-sample-histogram, fig.cap="Distribution of weight on a sample of 25 almonds."----
ggplot(almonds_sample, aes(x = weight)) +
  geom_histogram(binwidth = 0.1, color = "white")


## -----------------------------------------------------------------------------
almonds_sample |>
  summarize(sample_mean_weight = mean(weight))


## -----------------------------------------------------------------------------
virtual_samples_almonds <- almonds_bowl |> 
  rep_slice_sample(n = 25, reps = 1000)
virtual_samples_almonds


## -----------------------------------------------------------------------------
virtual_mean_weight <- virtual_samples_almonds |> 
  summarize(mean_weight = mean(weight))
virtual_mean_weight


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_mean_weight, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.04, boundary = 3.5, color = "white") +
##   labs(x = "Sample mean",
##        title = "Histogram of 1000 sample means")




## -----------------------------------------------------------------------------
almonds_sample


## -----------------------------------------------------------------------------
almonds_sample |>
  summarize(sample_mean_weight = mean(weight))


## ----eval=FALSE---------------------------------------------------------------
## # Segment 1: sample size = 25 ------------------------------
## # 1.a) Obtaining the 1000 sample means, each from random samples of size 25
## virtual_mean_weight_25 <- almonds_bowl |>
##   rep_slice_sample(n = 25, reps = 1000)|>
##   summarize(mean_weight = mean(weight), n = n())
## 
## # 1.b) Plot distribution via a histogram
## ggplot(virtual_mean_weight_25, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.02, boundary = 3.6, color = "white") +
##   labs(x = "Sample mean weights for random samples of 25 almonds", title = "25")
## 
## 
## # Segment 2: sample size = 50 ------------------------------
## # 2.a) Obtaining the 1000 sample means, each from random samples of size 50
## virtual_mean_weight_50 <- almonds_bowl |>
##   rep_slice_sample(n = 50, reps = 1000)|>
##   summarize(mean_weight = mean(weight), n = n())
## 
## # 2.b) Plot distribution via a histogram
## ggplot(virtual_mean_weight_50, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.02, boundary = 3.6, color = "white") +
##   labs(x = "Sample mean weights for random samples of 50 almonds", title = "50")
## 
## # Segment 3: sample size = 100 ------------------------------
## # 3.a) Obtaining the 1000 sample means, each from random samples of size 100
## virtual_mean_weight_100 <- almonds_bowl |>
##   rep_slice_sample(n = 100, reps = 1000)|>
##   summarize(mean_weight = mean(weight), n = n())
## 
## # 3.b) Plot distribution via a histogram
## ggplot(virtual_mean_weight_100, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.02, boundary = 3.6, color = "white") +
##   labs(x = "Sample mean weights for random samples of 100 almonds", title = "100")




## -----------------------------------------------------------------------------
almonds_bowl |>
  summarize(mu = mean(weight), sigma = sd(weight))


## ----eval=FALSE---------------------------------------------------------------
## # n = 25
## virtual_mean_weight_25 |>
##   summarize(E_Xbar_25 = mean(mean_weight), sd = sd(mean_weight))
## 
## # n = 50
## virtual_mean_weight_50 |>
##   summarize(E_Xbar_50 = mean(mean_weight), sd = sd(mean_weight))
## 
## # n = 100
## virtual_mean_weight_100 |>
##   summarize(E_Xbar_100 = mean(mean_weight), sd = sd(mean_weight))








## ----echo=-1------------------------------------------------------------------
set.seed(76)
n1 <- 50
n2<- 60
virtual_prop_red <- bowl |> 
  rep_slice_sample(n = 50, reps = 1000) |> 
  summarize(prop_red = mean(color == "red"))
virtual_prop_almond <- almonds_bowl |>
  rep_slice_sample(n = 60, reps = 1000) |>
  summarise(prop_almond = mean(weight > 3.8))
prop_joined <- virtual_prop_red |>
  inner_join(virtual_prop_almond, by = "replicate") |>
  mutate(prop_diff = prop_red - prop_almond)


## -----------------------------------------------------------------------------
prop_joined


## ----eval=FALSE---------------------------------------------------------------
## ggplot(prop_joined, aes(x = prop_diff)) +
##   geom_histogram(binwidth = 0.04, boundary = 0, color = "white") +
##   labs(x = "Difference in sample proportions",
##        title = "Histogram of 1000 differences in sample proportions")

