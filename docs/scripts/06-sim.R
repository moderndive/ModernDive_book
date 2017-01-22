## ----setup_infer, include=FALSE------------------------------------------
chap <- 6
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**
knitr::opts_chunk$set(tidy = FALSE, out.width='\\textwidth')#, fig.align = "center")

## ----message=FALSE, warning=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(okcupiddata)
library(mosaic)
library(knitr)

## ----soupimg, echo=FALSE, fig.cap="A bowl of Indian chicken and vegetable soup"----
knitr::include_graphics("images/soup.jpg")

## ----lc6-0a, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ----lc6-0b, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ----loadprofiles--------------------------------------------------------
library(okcupiddata)
data(profiles)

## ----height-hist, warning=FALSE------------------------------------------
library(ggplot2)
ggplot(data = profiles, mapping = aes(x = height)) +
  geom_histogram(bins = 20, color = "white")

## ----lc6-0c, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ----filter-profiles-----------------------------------------------------
library(dplyr)
profiles_subset <- profiles %>% filter(between(height, 55, 85))

## ----height-hist2, warning=FALSE-----------------------------------------
ggplot(data = profiles_subset, mapping = aes(x = height)) +
  geom_histogram(bins = 20, color = "white")

## ----sample-profiles-----------------------------------------------------
library(mosaic)
set.seed(2017)
profiles_sample1 <- profiles_subset %>% resample(size = 100, replace = FALSE)

## ----plot-sample1--------------------------------------------------------
ggplot(data = profiles_sample1, mapping = aes(x = height)) +
  geom_histogram(bins = 20, color = "white", fill = "red") +
  coord_cartesian(xlim = c(55, 85))

## ----lc6-0d, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ----sample-profiles2----------------------------------------------------
profiles_sample2 <- profiles_subset %>% resample(size = 100, replace = FALSE)
ggplot(data = profiles_sample2, mapping = aes(x = height)) +
  geom_histogram(bins = 20, color = "black", fill = "yellow") +
  coord_cartesian(xlim = c(55, 85))

## ----sample-profiles3----------------------------------------------------
profiles_sample3 <- profiles_subset %>% filter(height >= 72)
ggplot(data = profiles_sample3, mapping = aes(x = height)) +
  geom_histogram(bins = 20, color = "white", fill = "blue") +
  coord_cartesian(xlim = c(55, 85))

## ----mean1---------------------------------------------------------------
profiles_sample1 %>% summarize(mean(height))

## ----mean2---------------------------------------------------------------
profiles_sample2 %>% summarize(mean(height))

## ----mean3---------------------------------------------------------------
profiles_sample3 %>% summarize(mean(height))

## ----shiny, echo=FALSE, out.width="100%", fig.cap=ifelse(knitr:::is_html_output(), "Sampling distribution app at http://ismay.shinyapps.io/okcupidheights/.", "Sampling distribution app"), screenshot.opts=list(delay=20), dev='png', cache=TRUE----
library(knitr)
if(knitr:::is_html_output()){
  include_app("http://ismay.shinyapps.io/okcupidheights/", height = "1300px")
} else{
  include_graphics("images/shinyapp.png")
}

## ----do-first, cache=TRUE------------------------------------------------
sample_means <- do(10000) *
  (profiles_subset %>% resample(size = 100, replace = FALSE) %>% 
  summarize(mean_height = mean(height)))
ggplot(data = sample_means, mapping = aes(x = mean_height)) +
  geom_histogram(color = "white", bins = 20)

## ----lc6-0e, type='learncheck', engine="block"---------------------------
**_Learning check_**

## ----lc6-1, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----message=FALSE-------------------------------------------------------
library(mosaic)
set.seed(2017)
do(1) * rflip(1)

## ------------------------------------------------------------------------
do(13) * rflip(10)

## ------------------------------------------------------------------------
library(dplyr)
simGuesses <- do(10000) * rflip(10)
simGuesses %>% 
  group_by(heads) %>%
  summarize(count = n())

## ----fig.cap="Histogram of number of heads in simulation - needs tweaking"----
library(ggplot2)
simGuesses %>% ggplot(aes(x = heads)) +
  geom_histogram(binwidth = 1, color = "white")

## ----fig.cap="Barplot of number of heads in simulation"------------------
library(ggplot2)
simGuesses %>% ggplot(aes(x = factor(heads))) +
  geom_bar()

## ----lc-mosaic, type='learncheck', engine="block"------------------------
**_Learning check_**

## ----include=FALSE, eval=FALSE-------------------------------------------
## knitr::purl("06-sim.Rmd", "docs/scripts/06-sim.R")

