## ----message=FALSE, warning=FALSE----------------------------------------
library(mosaic)
library(dplyr)
library(ggplot2)
library(knitr)
library(broom)
library(nycflights13)

## ----regplot1, warning=FALSE, fig.cap="Departure and Arrival Flight Delays for a sample of 50 Alaskan flights from NYC"----
library(nycflights13)
data(flights)
set.seed(2017)

# Load Alaska data, deleting rows that have missing departure delay
# or arrival delay data
alaska_flights <- flights %>% 
  filter(carrier == "AS") %>% 
  filter(!is.na(dep_delay) & !is.na(arr_delay)) %>% 
  resample(size = 50, replace = FALSE)

ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
   geom_point()

## ----corr-coefs, echo=FALSE, fig.cap="Different Correlation Coefficients"----
library(mvtnorm) 
correlation <- c(-0.9999, -0.9, -0.75, -0.3, 0, 0.3, 0.75, 0.9, 0.9999)
n_sim <- 100

values <- NULL
for(i in 1:length(correlation)){
  rho <- correlation[i]
  sigma <- matrix(c(5, rho * sqrt(50), rho * sqrt(50), 10), 2, 2) 
  sim <- rmvnorm(
    n = n_sim,
    mean = c(20,40),
    sigma = sigma
    ) %>%
    as_data_frame() %>% 
    mutate(correlation = round(rho,2))
  
  values <- bind_rows(values, sim)
}

ggplot(data = values, mapping = aes(V1, V2)) +
  geom_point() +
  facet_wrap(~ correlation, ncol = 3) +
  labs(x = "", y = "") + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank()
  )

## ---- warning=FALSE, echo=TRUE-------------------------------------------
alaska_flights %>% 
  summarize(correl = cor(dep_delay, arr_delay))

## ----with-reg, fig.cap="Regression line fit on delays"-------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red")

## ----echo=FALSE----------------------------------------------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  annotate("point", x = 44, y = 7, color = "blue", size = 3)

## ----echo=FALSE----------------------------------------------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  annotate("point", x = 44, y = 7, color = "blue", size = 3) +
  annotate("segment", x = 44, xend = 44, y = 7, yend = -14.155 + 1.218 * 44,
           color = "blue", arrow = arrow(length = unit(0.03, "npc")))

## ----echo=FALSE----------------------------------------------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  annotate("point", x = 44, y = 7, color = "blue", size = 3) +
  annotate("segment", x = 44, xend = 44, y = 7, yend = -14.155 + 1.218 * 44,
           color = "blue", arrow = arrow(length = unit(0.03, "npc"))) +
  annotate("point", x = 15, y = 34, color = "blue", size = 3) +
  annotate("segment", x = 15, xend = 15, y = 34, yend = -14.155 + 1.218 * 15,
           color = "blue", arrow = arrow(length = unit(0.03, "npc")))

## ----echo=FALSE----------------------------------------------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  annotate("point", x = 44, y = 7, color = "blue", size = 3) +
  annotate("segment", x = 44, xend = 44, y = 7, yend = -14.155 + 1.218 * 44,
           color = "blue", arrow = arrow(length = unit(0.03, "npc"))) +
  annotate("point", x = 15, y = 34, color = "blue", size = 3) +
  annotate("segment", x = 15, xend = 15, y = 34, yend = -14.155 + 1.218 * 15,
           color = "blue", arrow = arrow(length = unit(0.03, "npc"))) +
  annotate("point", x = 15, y = 34, color = "blue", size = 3) +
  annotate("segment", x = 15, xend = 15, y = 34, yend = -14.155 + 1.218 * 15,
           color = "blue", arrow = arrow(length = unit(0.03, "npc"))) +
  annotate("point", x = 7, y = -20, color = "blue", size = 3) +
  annotate("segment", x = 7, xend = 7, y = -20, yend = -14.155 + 1.218 * 7,
           color = "blue", arrow = arrow(length = unit(0.03, "npc")))  

## ----fit-----------------------------------------------------------------
delay_fit <- lm(formula = arr_delay ~ dep_delay, data = alaska_flights)
tidy(delay_fit) %>% kable()

## ------------------------------------------------------------------------
coef(delay_fit)

## ------------------------------------------------------------------------
delay_fit %>% augment(newdata = data_frame(dep_delay = 25))

## ---- echo=FALSE, warning=FALSE------------------------------------------
vals <- seq(-2, 2, length=20)
example <- data_frame(
  x = rep(vals, 3),
  y = c(0.01*vals, 1*vals, 3*vals),
  slope = factor(rep(c(0.01, 1, 3), each = length(vals)))
)
ggplot(example, aes(x = x, y = y, col = slope)) +
  geom_point(size = 2) +
  theme(legend.position = "none")

## ---- echo=FALSE, warning=FALSE------------------------------------------
ggplot(example, aes(x = x, y = y, col = slope)) +
  geom_point(size = 2) + 
  geom_smooth(method = "lm", se = FALSE)

## ------------------------------------------------------------------------
(b1_obs <- tidy(delay_fit)$estimate[2])

## ----many_shuffles_reg---------------------------------------------------
rand_slope_distn <- mosaic::do(5000) *
  (lm(formula = shuffle(arr_delay) ~ dep_delay, data = alaska_flights) %>%
     coef())
names(rand_slope_distn)

## ------------------------------------------------------------------------
ggplot(data = rand_slope_distn, mapping = aes(x = dep_delay)) +
  geom_histogram(color = "white", bins = 20)

## ----fig.cap="Shaded histogram to show p-value"--------------------------
ggplot(data = rand_slope_distn, aes(x = dep_delay, fill = (dep_delay >= b1_obs))) +
  geom_histogram(color = "white", bins = 20)

## ----echo=FALSE----------------------------------------------------------
ggplot(data = alaska_flights, 
       mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point() +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  annotate("point", x = 44, y = 7, color = "blue", size = 3) +
  annotate("segment", x = 44, xend = 44, y = 7, yend = -14.155 + 1.218 * 44,
  color = "blue", arrow = arrow(length = unit(0.03, "npc")))

## ----resid-plot----------------------------------------------------------
fits <- augment(delay_fit)
ggplot(data = fits, mapping = aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 0, color = "blue")

## ----qqplot1-------------------------------------------------------------
ggplot(data = fits, mapping = aes(sample = .resid)) +
  stat_qq()

