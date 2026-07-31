## ----setup-init, include=FALSE------------------------------------------------
library(knitr)
source("scripts/image_functions.R")




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




## ----fig-nolayers, fig.cap="A plot with no layers.", fig.height=ifelse(knitr::is_latex_output(), 2, 4)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay))


## ----fig-alpha, fig.cap="Arrival vs. departure delays scatterplot with alpha = 0.2.", fig.alt="The same scatterplot of departure delay versus arrival delay, but with semi-transparent points (alpha = 0.2). The dense central cluster now appears as a shaded gradient (darker where many points overlap, lighter at the periphery) making the relative density of points easier to see.", fig.height=ifelse(knitr::is_latex_output(), 3.8, 4)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
  geom_point(alpha = 0.2)




## ----fig-jitter, fig.cap="Arrival versus departure delays jittered scatterplot.", fig.alt="The same scatterplot with jittered points: each point is randomly nudged by up to 30 units in both directions to break overplotting. The cloud is now spread out rather than overlapping, while the overall positive linear pattern remains clear.", fig.height=ifelse(knitr::is_latex_output(), 4.7, 5)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
  geom_jitter(width = 30, height = 30)


## ----fig-hourlytemp, fig.cap="Hourly wind speed in Newark for January 1-15, 2023.", fig.alt="Line graph of hourly wind speed (mph) in Newark from January 1 to January 15, 2023. The line oscillates between roughly 0 and 35 mph with no clear trend over the two-week period; sharp short-term spikes are visible across multiple days."----
ggplot(data = early_january_2023_weather,
       mapping = aes(x = time_hour, y = wind_speed)) +
  geom_line()


## ----fig-windspeed-on-line, fig.alt="One-dimensional strip plot of hourly wind speed values from the weather data along a horizontal line. Most points cluster between 0 and 20 mph with heavy overplotting; a thin tail extends out toward 40 mph.", echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 0.8, 4), fig.cap="Plot of hourly wind speed recordings from NYC in 2023."----
ggplot(data = weather, mapping = aes(x = wind_speed, y = factor("A"))) +
  geom_point() +
  theme(
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank()
  )




## ----fig-weather-histogram, warning=TRUE, fig.cap="Histogram of hourly wind speeds at three NYC airports.", fig.alt="Histogram of hourly wind speeds (mph) across three NYC airports. The distribution is right-skewed, peaking near 8 mph and tapering off toward higher wind speeds; a notable bin near zero contains a number of observations.", fig.height=ifelse(knitr::is_latex_output(), 2.3, 4), warning=FALSE, message=FALSE----
ggplot(data = weather, mapping = aes(x = wind_speed)) +
  geom_histogram()


## ----fig-weather-histogram-2, fig.alt="Right-skewed histogram of hourly wind speeds in mph from the weather data, default 30 bins with white borders between bars making each bin clearly visible.", message=FALSE, fig.cap="Histogram of hourly wind speeds at three NYC airports with white borders.", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
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














## ----fig-badbox, fig.alt="A single uninformative wide boxplot pooled across all 12 months: the result of mapping the numeric `month` variable to x instead of treating it as categorical. ggplot also emits a warning about a continuous x aesthetic.", fig.cap="Invalid boxplot specification.", fig.height=ifelse(knitr::is_latex_output(), 1.9, 4)----
ggplot(data = weather, mapping = aes(x = month, y = wind_speed)) +
  geom_boxplot()


## ----fig-monthtempbox, fig.cap="Side-by-side boxplot of wind speed split by month.", fig.alt="Side-by-side boxplots of hourly wind speed (y-axis, mph) by month (x-axis, January through December). Median wind speeds are roughly similar across months but slightly higher in winter and spring; spread varies somewhat by month, with several high-wind outliers above 30 mph in most months.", fig.height=ifelse(knitr::is_latex_output(), 4, 4)----
ggplot(data = weather, mapping = aes(x = factor(month), y = wind_speed)) +
  geom_boxplot()


## ----visualization-create-fruits----------------------------------------------
fruits <- tibble(fruit = c("apple", "apple", "orange", "apple", "orange"))
fruits_counted <- tibble(
  fruit = c("apple", "orange"),
  number = c(3, 2))






## ----fig-geombar, fig.alt="Barplot built from the `fruits` data frame (one row per piece of fruit) using `geom_bar()`. Two bars: \"apple\" at height 3 and \"orange\" at height 2.", fig.cap="Barplot when counts are not pre-counted.", fig.height=ifelse(knitr::is_latex_output(), 1.3, 4)----
ggplot(data = fruits, mapping = aes(x = fruit)) +
  geom_bar()


## ----fig-geomcol, fig.alt="Visually identical barplot to the previous figure (apples 3, oranges 2), but built from the pre-counted `fruits_counted` data frame using `geom_col()` with `y = number`.", fig.cap="Barplot when counts are pre-counted.", fig.height=ifelse(knitr::is_latex_output(), 1.3, 4)----
ggplot(data = fruits_counted, mapping = aes(x = fruit, y = number)) +
  geom_col()


## ----fig-flightsbar, fig.cap="Number of flights departing NYC in 2023 by airline using `geom_bar()`.", fig.alt="Bar chart of the number of flights departing NYC in 2023 by airline carrier code (x-axis). UA (United) and B6 (JetBlue) have the tallest bars; many smaller carriers appear as much shorter bars on the right side of the plot.", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
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




## -----------------------------------------------------------------------------
#| label: ch2-exercises
#| results: asis
#| echo: false
#| message: false
source(if (file.exists("scripts/exercise_helpers.R")) "scripts/exercise_helpers.R" else "../scripts/exercise_helpers.R")
cat(render_chapter_exercises(2))




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

