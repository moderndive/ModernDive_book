## ----message=FALSE------------------------------------------------------------
library(nycflights13)
library(ggplot2)
library(moderndive)


















## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()




## ----nolayers, fig.cap="A plot with no layers.", fig.height=2.5---------------
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay))






## ----alpha, fig.cap="Arrival vs. departure delays scatterplot with alpha = 0.2.", fig.height=4.9----
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)




## ----jitter, fig.cap="Arrival versus departure delays jittered scatterplot.", fig.height=4.7----
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)










## ----hourlytemp, fig.cap="Hourly temperature in Newark for January 1-15, 2013."----
ggplot(data = early_january_weather, 
       mapping = aes(x = time_hour, y = temp)) +
  geom_line()






## ----temp-on-line, echo=FALSE, fig.height=0.8, fig.cap="Plot of hourly temperature recordings from NYC in 2013."----
ggplot(data = weather, mapping = aes(x = temp, y = factor("A"))) +
  geom_point() +
  theme(
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank()
  )
hist_title <- "Histogram of Hourly Temperature Recordings from NYC in 2013"




## ----weather-histogram, warning=TRUE, fig.cap="Histogram of hourly temperatures at three NYC airports.", fig.height=2.3----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram()


## ----weather-histogram-2, message=FALSE, fig.cap="Histogram of hourly temperatures at three NYC airports with white borders.", fig.height=3----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(color = "white")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(color = "white", fill = "steelblue")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(bins = 40, color = "white")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(binwidth = 10, color = "white")








## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   facet_wrap(~ month)




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   facet_wrap(~ month, nrow = 4)
















## ----badbox, fig.cap="Invalid boxplot specification.", fig.height=2.4---------
ggplot(data = weather, mapping = aes(x = month, y = temp)) +
  geom_boxplot()


## ----monthtempbox, fig.cap="Side-by-side boxplot of temperature split by month.", fig.height=4.2----
ggplot(data = weather, mapping = aes(x = factor(month), y = temp)) +
  geom_boxplot()






## -----------------------------------------------------------------------------
fruits <- tibble(
  fruit = c("apple", "apple", "orange", "apple", "orange")
)
fruits_counted <- tibble(
  fruit = c("apple", "orange"),
  number = c(3, 2)
)






## ----geombar, fig.cap="Barplot when counts are not pre-counted.", fig.height=1.8----
ggplot(data = fruits, mapping = aes(x = fruit)) +
  geom_bar()


## ----geomcol, fig.cap="Barplot when counts are pre-counted.", fig.height=2.5----
ggplot(data = fruits_counted, mapping = aes(x = fruit, y = number)) +
  geom_col()


## ----flightsbar, fig.cap="(ref:geombar)", fig.height=2.8----------------------
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()














## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar()


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar()




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, color = origin)) +
##   geom_bar()




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier), fill = origin) +
##   geom_bar()


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar(position = "dodge")




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar(position = position_dodge(preserve = "single"))




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar() +
##   facet_wrap(~ origin, ncol = 1)










## ----eval=FALSE---------------------------------------------------------------
## # Segment 1:
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar()
## 
## # Segment 2:
## ggplot(flights, aes(x = carrier)) +
##   geom_bar()










## ----eval=FALSE---------------------------------------------------------------
## library(dplyr)
## 
## alaska_flights <- flights %>%
##   filter(carrier == "AS")
## 
## ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()


## ----eval=FALSE---------------------------------------------------------------
## early_january_weather <- weather %>%
##   filter(origin == "EWR" & month == 1 & day <= 15)
## 
## ggplot(data = early_january_weather, mapping = aes(x = time_hour, y = temp)) +
##   geom_line()

