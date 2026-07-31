## ----visualization-load-packages, message=FALSE-------------------------------
library(nycflights23)
library(ggplot2)
library(moderndive)
library(tibble)


















## ----visualization-filter-envoy, echo=FALSE-----------------------------------
envoy_flights <- flights |> 
  filter(carrier == "MQ")


## ----visualization-scatter-delays, eval=FALSE---------------------------------
# ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
#   geom_point()




## ----nolayers, fig.cap="A plot with no layers.", fig.height=ifelse(knitr::is_latex_output(), 2, 4)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay))






## ----alpha, fig.cap="Arrival vs. departure delays scatterplot with alpha = 0.2.", fig.height=ifelse(knitr::is_latex_output(), 3.8, 4)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)




## ----jitter, fig.cap="Arrival versus departure delays jittered scatterplot.", fig.height=ifelse(knitr::is_latex_output(), 4.7, 5)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)










## ----hourlytemp, fig.cap="Hourly wind speed in Newark for January 1-15, 2023."----
ggplot(data = early_january_2023_weather, 
       mapping = aes(x = time_hour, y = wind_speed)) +
  geom_line()






## ----windspeed-on-line, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 0.8, 4), fig.cap="Plot of hourly wind speed recordings from NYC in 2023."----
ggplot(data = weather, mapping = aes(x = wind_speed, y = factor("A"))) +
  geom_point() +
  theme(
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank()
  )




## ----weather-histogram, warning=TRUE, fig.cap="Histogram of hourly wind speeds at three NYC airports.", fig.height=ifelse(knitr::is_latex_output(), 2.3, 4), warning=FALSE, message=FALSE----
ggplot(data = weather, mapping = aes(x = wind_speed)) +
  geom_histogram()


## ----weather-histogram-2, message=FALSE, fig.cap="Histogram of hourly wind speeds at three NYC airports with white borders.", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
ggplot(data = weather, mapping = aes(x = wind_speed)) +
  geom_histogram(color = "white")


## ----visualization-hist-wind, eval=FALSE--------------------------------------
# ggplot(data = weather, mapping = aes(x = wind_speed)) +
#   geom_histogram(color = "white", fill = "steelblue")


## ----visualization-hist-white-border-v2, eval=FALSE---------------------------
# ggplot(data = weather, mapping = aes(x = wind_speed)) +
#   geom_histogram(bins = 20, color = "white")


## ----visualization-hist-white-border-v2-dup1, eval=FALSE----------------------
# ggplot(data = weather, mapping = aes(x = wind_speed)) +
#   geom_histogram(binwidth = 5, color = "white")








## ----visualization-facet-hist-wind, eval=FALSE--------------------------------
# ggplot(data = weather, mapping = aes(x = wind_speed)) +
#   geom_histogram(binwidth = 5, color = "white") +
#   facet_wrap(~ month)




## ----visualization-facet-with-nrow, eval=FALSE--------------------------------
# ggplot(data = weather, mapping = aes(x = wind_speed)) +
#   geom_histogram(binwidth = 5, color = "white") +
#   facet_wrap(~ month, nrow = 4)


















## ----badbox, fig.cap="Invalid boxplot specification.", fig.height=ifelse(knitr::is_latex_output(), 1.9, 4)----
ggplot(data = weather, mapping = aes(x = month, y = wind_speed)) +
  geom_boxplot()


## ----monthtempbox, fig.cap="Side-by-side boxplot of wind speed split by month.", fig.height=ifelse(knitr::is_latex_output(), 4, 4)----
ggplot(data = weather, mapping = aes(x = factor(month), y = wind_speed)) +
  geom_boxplot()






## ----visualization-create-fruits----------------------------------------------
fruits <- tibble(fruit = c("apple", "apple", "orange", "apple", "orange"))
fruits_counted <- tibble(
  fruit = c("apple", "orange"),
  number = c(3, 2))






## ----geombar, fig.cap="Barplot when counts are not pre-counted.", fig.height=ifelse(knitr::is_latex_output(), 1.3, 4)----
ggplot(data = fruits, mapping = aes(x = fruit)) +
  geom_bar()


## ----geomcol, fig.cap="Barplot when counts are pre-counted.", fig.height=ifelse(knitr::is_latex_output(), 1.3, 4)----
ggplot(data = fruits_counted, mapping = aes(x = fruit, y = number)) +
  geom_col()


## ----flightsbar, fig.cap="(ref:geombar)", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()














## ----visualization-bar-simple, eval=FALSE-------------------------------------
# ggplot(data = flights, mapping = aes(x = carrier)) +
#   geom_bar()


## ----visualization-bar-filled, eval=FALSE-------------------------------------
# ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
#   geom_bar()




## ----visualization-bar-simple-v2, eval=FALSE----------------------------------
# ggplot(data = flights, mapping = aes(x = carrier, color = origin)) +
#   geom_bar()




## ----visualization-bar-filled-v2, eval=FALSE----------------------------------
# ggplot(data = flights, mapping = aes(x = carrier), fill = origin) +
#   geom_bar()


## ----visualization-bar-filled-v2-dup1, eval=FALSE-----------------------------
# ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
#   geom_bar(position = "dodge")




## ----visualization-facet-bar, eval=FALSE--------------------------------------
# ggplot(data = flights, mapping = aes(x = carrier)) +
#   geom_bar() +
#   facet_wrap(~ origin, ncol = 1)










## ----visualization-bar-simple-v2-dup1, eval=FALSE-----------------------------
# # Segment 1:
# ggplot(data = flights, mapping = aes(x = carrier)) +
#   geom_bar()
# 
# # Segment 2:
# ggplot(flights, aes(x = carrier)) +
#   geom_bar()










## ----visualization-load-dplyr, eval=FALSE-------------------------------------
# library(dplyr)
# 
# envoy_flights <- flights |>
#   filter(carrier == "MQ")
# 
# ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
#   geom_point()


## ----visualization-filter-month1, eval=FALSE----------------------------------
# early_january_2023_weather <- weather |>
#   filter(origin == "EWR" & month == 1 & day <= 15)
# 
# ggplot(data = early_january_2023_weather, mapping = aes(x = time_hour, y = temp)) +
#   geom_line()

