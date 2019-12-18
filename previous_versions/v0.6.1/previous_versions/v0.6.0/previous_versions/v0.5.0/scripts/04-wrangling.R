## ---- eval=FALSE---------------------------------------------------------
## alaska_flights <- flights %>%
##   filter(carrier == "AS")
## 
## ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()


## ---- message=FALSE------------------------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights13)




## ---- eval = FALSE-------------------------------------------------------
## h(g(f(x)))


## ---- eval = FALSE-------------------------------------------------------
## x %>%
##   f() %>%
##   g() %>%
##   h()


## ---- eval=FALSE---------------------------------------------------------
## alaska_flights <- flights %>%
##   filter(carrier == "AS")




## ---- eval=FALSE---------------------------------------------------------
## portland_flights <- flights %>%
##   filter(dest == "PDX")
## View(portland_flights)


## ---- eval=FALSE---------------------------------------------------------
## btv_sea_flights_fall <- flights %>%
##   filter(origin == "JFK" & (dest == "BTV" | dest == "SEA") & month >= 10)
## View(btv_sea_flights_fall)


## ---- eval=FALSE---------------------------------------------------------
## btv_sea_flights_fall <- flights %>%
##   filter(origin == "JFK", (dest == "BTV" | dest == "SEA"), month >= 10)
## View(btv_sea_flights_fall)


## ---- eval=FALSE---------------------------------------------------------
## not_BTV_SEA <- flights %>%
##   filter(!(dest == "BTV" | dest == "SEA"))
## View(not_BTV_SEA)


## ---- eval=FALSE---------------------------------------------------------
## flights %>%
##   filter(!dest == "BTV" | dest == "SEA")


## ---- eval=FALSE---------------------------------------------------------
## many_airports <- flights %>%
##   filter(dest == "BTV" | dest == "SEA" | dest == "PDX" | dest == "SFO" | dest == "BDL")
## View(many_airports)


## ---- eval=FALSE---------------------------------------------------------
## many_airports <- flights %>%
##   filter(dest %in% c("BTV", "SEA", "PDX", "SFO", "BDL"))
## View(many_airports)










## ---- eval=TRUE----------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp), std_dev = sd(temp))
summary_temp

## ---- echo=FALSE, eval=FALSE---------------------------------------------
## options(knitr.kable.NA = '')
## summary_temp <- weather %>%
##   summarize(mean = mean(temp),
##             std_dev = sd(temp))
## kable(summary_temp) %>%
##   kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
##                 latex_options = c("HOLD_position"))


## ---- eval = TRUE--------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp, na.rm = TRUE), 
            std_dev = sd(temp, na.rm = TRUE))
summary_temp

## ---- echo=FALSE, eval=FALSE---------------------------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp, na.rm = TRUE),
##             std_dev = sd(temp, na.rm = TRUE))
## kable(summary_temp) %>%
##   kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
##                 latex_options = c("HOLD_position"))




## ----eval=FALSE----------------------------------------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp, na.rm = TRUE)) %>%
##   summarize(std_dev = sd(temp, na.rm = TRUE))






## ---- eval=FALSE---------------------------------------------------------
## summary_monthly_temp <- weather %>%
##   group_by(month) %>%
##   summarize(mean = mean(temp, na.rm = TRUE),
##             std_dev = sd(temp, na.rm = TRUE))
## summary_monthly_temp

## ---- echo=FALSE---------------------------------------------------------
summary_monthly_temp <- weather %>% 
  group_by(month) %>% 
  summarize(mean = mean(temp, na.rm = TRUE), 
            std_dev = sd(temp, na.rm = TRUE))
kable(summary_monthly_temp) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=TRUE----------------------------------------------------------
diamonds


## ---- eval=TRUE----------------------------------------------------------
diamonds %>% 
  group_by(cut)


## ---- eval=TRUE----------------------------------------------------------
diamonds %>% 
  group_by(cut) %>% 
  summarize(avg_price = mean(price))


## ---- eval=TRUE----------------------------------------------------------
diamonds %>% 
  group_by(cut) %>% 
  ungroup()


## ---- eval=TRUE----------------------------------------------------------
by_origin <- flights %>% 
  group_by(origin) %>% 
  summarize(count = n())
by_origin

## ---- echo=FALSE, eval=FALSE---------------------------------------------
## by_origin <- flights %>%
##   group_by(origin) %>%
##   summarize(count = n())
## kable(by_origin) %>%
##   kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
##                 latex_options = c("HOLD_position"))


## ------------------------------------------------------------------------
by_origin_monthly <- flights %>% 
  group_by(origin, month) %>% 
  summarize(count = n())
by_origin_monthly


## ------------------------------------------------------------------------
by_origin_monthly_incorrect <- flights %>% 
  group_by(origin) %>% 
  group_by(month) %>% 
  summarize(count = n())
by_origin_monthly_incorrect




## NA



## ---- eval=FALSE---------------------------------------------------------
## weather <- weather %>%
##   mutate(temp_in_C = (temp-32)/1.8)
## View(weather)

## ---- eval=TRUE, echo=FALSE----------------------------------------------
weather <- weather %>% 
  mutate(temp_in_C = (temp-32)/1.8)


## ------------------------------------------------------------------------
summary_monthly_temp <- weather %>% 
  group_by(month) %>% 
  summarize(mean_temp_in_F = mean(temp, na.rm = TRUE), 
            mean_temp_in_C = mean(temp_in_C, na.rm = TRUE))
summary_monthly_temp


## ------------------------------------------------------------------------
flights <- flights %>% 
  mutate(gain = dep_delay - arr_delay)


## ---- echo=FALSE---------------------------------------------------------
flights %>% 
  select(dep_delay, arr_delay, gain) %>% 
  slice(1:5)


## ---- eval=FALSE---------------------------------------------------------
## gain_summary <- flights %>%
##   summarize(
##     min = min(gain, na.rm = TRUE),
##     q1 = quantile(gain, 0.25, na.rm = TRUE),
##     median = quantile(gain, 0.5, na.rm = TRUE),
##     q3 = quantile(gain, 0.75, na.rm = TRUE),
##     max = max(gain, na.rm = TRUE),
##     mean = mean(gain, na.rm = TRUE),
##     sd = sd(gain, na.rm = TRUE),
##     missing = sum(is.na(gain))
##   )
## gain_summary

## ----echo=FALSE----------------------------------------------------------
gain_summary <- flights %>% 
  summarize(
    min = min(gain, na.rm = TRUE),
    q1 = quantile(gain, 0.25, na.rm = TRUE),
    median = quantile(gain, 0.5, na.rm = TRUE),
    q3 = quantile(gain, 0.75, na.rm = TRUE),
    max = max(gain, na.rm = TRUE),
    mean = mean(gain, na.rm = TRUE),
    sd = sd(gain, na.rm = TRUE),
    missing = sum(is.na(gain))
  )
kable(gain_summary) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16), 
                latex_options = c("HOLD_position"))


## ----message=FALSE, fig.cap="Histogram of gain variable"-----------------
ggplot(data = flights, mapping = aes(x = gain)) +
  geom_histogram(color = "white", bins = 20)


## ------------------------------------------------------------------------
flights <- flights %>% 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours
  )






## ---- eval---------------------------------------------------------------
freq_dest <- flights %>% 
  group_by(dest) %>% 
  summarize(num_flights = n())
freq_dest


## ------------------------------------------------------------------------
freq_dest %>% 
  arrange(num_flights)


## ------------------------------------------------------------------------
freq_dest %>% 
  arrange(desc(num_flights))


## ----eval=FALSE----------------------------------------------------------
## View(airlines)




## ----eval=FALSE----------------------------------------------------------
## flights_joined <- flights %>%
##   inner_join(airlines, by = "carrier")
## View(flights)
## View(flights_joined)




## ----eval=FALSE----------------------------------------------------------
## View(airports)


## ---- eval=FALSE---------------------------------------------------------
## flights_with_airport_names <-  flights %>%
##   inner_join(airports, by = c("dest" = "faa"))
## View(flights_with_airport_names)


## ------------------------------------------------------------------------
named_dests <- flights %>%
  group_by(dest) %>%
  summarize(num_flights = n()) %>%
  arrange(desc(num_flights)) %>%
  inner_join(airports, by = c("dest" = "faa")) %>%
  rename(airport_name = name)
named_dests


## ---- eval=FALSE---------------------------------------------------------
## flights_weather_joined <- flights %>%
##   inner_join(weather, by = c("year", "month", "day", "hour", "origin"))
## View(flights_weather_joined)






## ----eval=FALSE----------------------------------------------------------
## joined_flights <- flights %>%
##   inner_join(airlines, by = "carrier")
## View(joined_flights)


## **_Learning check_**






## ---- eval=FALSE---------------------------------------------------------
## glimpse(flights)


## ---- eval=FALSE---------------------------------------------------------
## flights %>%
##   select(carrier, flight)


## ---- eval=FALSE---------------------------------------------------------
## flights_no_year <- flights %>%
##   select(-year)
## glimpse(flights_no_year)


## ---- eval=FALSE---------------------------------------------------------
## flight_arr_times <- flights %>%
##   select(month:day, arr_time:sched_arr_time)
## flight_arr_times


## ---- eval=FALSE---------------------------------------------------------
## flights_reorder <- flights %>%
##   select(year, month, day, hour, minute, time_hour, everything())
## glimpse(flights_reorder)


## ---- eval=FALSE---------------------------------------------------------
## flights_begin_a <- flights %>%
##   select(starts_with("a"))
## flights_begin_a


## ---- eval=FALSE---------------------------------------------------------
## flights_delays <- flights %>%
##   select(ends_with("delay"))
## flights_delays


## ---- eval=FALSE---------------------------------------------------------
## flights_time <- flights %>%
##   select(contains("time"))
## flights_time


## ---- eval=FALSE---------------------------------------------------------
## flights_time_new <- flights %>%
##   select(contains("time")) %>%
##   rename(departure_time = dep_time,
##          arrival_time = arr_time)
## glimpse(flights_time)


## ---- eval=FALSE---------------------------------------------------------
## named_dests %>%
##   top_n(n = 10, wt = num_flights)


## ---- eval=FALSE---------------------------------------------------------
## named_dests  %>%
##   top_n(n = 10, wt = num_flights) %>%
##   arrange(desc(num_flights))






## ----wrangle-summary-table, echo=FALSE, message=FALSE--------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1nRkXfYMQiTj79c08xQPY0zkoJSpde3NC1w6DRhsWCss/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRgwl1lugQA6zxzfB6_0hM5vBjXkU7cbUVYYXLcWeaRJ9HmvNXyCjzJCgiGW8HCe1kvjLCGYHf-BvYL/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  select(-X1) %>% 
  kable(
    caption = "Summary of data wrangling verbs", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position")) %>%
  column_spec(1, width = "0.9in") %>% 
  column_spec(2, width = "3.3in")






## ----dplyr-cheatsheet, echo=FALSE, fig.cap="Data Transformation with dplyr cheatsheat"----
include_graphics("images/dplyr_cheatsheet-1.png")

