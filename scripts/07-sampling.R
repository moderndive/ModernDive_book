## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
















## -----------------------------------------------------------------------------
tactile_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(tactile_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red",
##        title = "Distribution of 33 proportions red")







## -----------------------------------------------------------------------------
bowl


## -----------------------------------------------------------------------------
fruit_basket <- tibble(
  fruit = c("Mango", "Tangerine", "Apricot", "Pamplemousse", "Lime")
)


## -----------------------------------------------------------------------------
virtual_shovel <- bowl %>% 
  rep_sample_n(size = 50)
virtual_shovel


## -----------------------------------------------------------------------------
virtual_shovel %>% 
  mutate(is_red = (color == "red"))


## -----------------------------------------------------------------------------
virtual_shovel %>% 
  mutate(is_red = (color == "red")) %>% 
  summarize(num_red = sum(is_red))



## -----------------------------------------------------------------------------
virtual_shovel %>% 
  mutate(is_red = color == "red") %>% 
  summarize(num_red = sum(is_red)) %>% 
  mutate(prop_red = num_red / 50)



## -----------------------------------------------------------------------------
virtual_shovel %>% 
  summarize(num_red = sum(color == "red")) %>% 
  mutate(prop_red = num_red / 50)


## -----------------------------------------------------------------------------
virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 33)
virtual_samples


## -----------------------------------------------------------------------------
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)
virtual_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red",
##        title = "Distribution of 33 proportions red")









## -----------------------------------------------------------------------------
virtual_samples <- bowl %>% 
  rep_sample_n(size = 50, reps = 1000)
virtual_samples


## -----------------------------------------------------------------------------
virtual_prop_red <- virtual_samples %>% 
  group_by(replicate) %>% 
  summarize(red = sum(color == "red")) %>% 
  mutate(prop_red = red / 50)
virtual_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red",
##        title = "Distribution of 1000 proportions red")









## ----eval=FALSE---------------------------------------------------------------
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




## ----eval=FALSE---------------------------------------------------------------
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








## -----------------------------------------------------------------------------
bowl


## -----------------------------------------------------------------------------
bowl %>% 
  summarize(red = sum(color == "red")) 


## ----eval = FALSE-------------------------------------------------------------
## virtual_shovel <- bowl %>%
##   rep_sample_n(size = 50)
## virtual_shovel

## ----echo = FALSE-------------------------------------------------------------
virtual_shovel


## -----------------------------------------------------------------------------
virtual_shovel %>% 
  summarize(num_red = sum(color == "red")) %>% 
  mutate(prop_red = num_red / 50)

