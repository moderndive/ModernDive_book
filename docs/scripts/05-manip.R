## ---- message=FALSE------------------------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights13)
library(knitr)

## ---- eval=FALSE---------------------------------------------------------
## portland_flights <- flights %>%
##   filter(dest == "PDX")
## View(portland_flights)

## ----eval=FALSE----------------------------------------------------------
## portland_flights <- flights %>%
##   filter(dest = "PDX")

## ---- eval=FALSE---------------------------------------------------------
## btv_sea_flights_fall <- flights %>%
##   filter(origin == "JFK", (dest == "BTV" | dest == "SEA"), month >= 10)
## View(btv_sea_flights_fall)

## ---- eval=FALSE---------------------------------------------------------
## not_BTV_SEA <- flights %>%
##   filter(!(dest == "BTV" | dest == "SEA"))
## View(not_BTV_SEA)

## ------------------------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp), std_dev = sd(temp))
kable(summary_temp)

## ------------------------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp, na.rm = TRUE), std_dev = sd(temp, na.rm = TRUE))
kable(summary_temp)

## ------------------------------------------------------------------------
summary_temp$mean

## ----eval=FALSE----------------------------------------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp, na.rm = TRUE)) %>%
##   summarize(std_dev = sd(temp, na.rm = TRUE))

## ------------------------------------------------------------------------
summary_monthly_temp <- weather %>% 
  group_by(month) %>% 
  summarize(mean = mean(temp, na.rm = TRUE), 
            std_dev = sd(temp, na.rm = TRUE))
kable(summary_monthly_temp)

## ------------------------------------------------------------------------
by_origin <- flights %>% 
  group_by(origin) %>% 
  summarize(count = n())
kable(by_origin)

## ------------------------------------------------------------------------
by_monthly_origin <- flights %>% 
  group_by(origin, month) %>% 
  summarize(count = n())
kable(by_monthly_origin)

## ------------------------------------------------------------------------
by_monthly_origin2 <- flights %>% 
  dplyr::count(origin, month)
kable(by_monthly_origin2)

## ----lc-groupby, type='learncheck', engine="block"-----------------------
**_Learning check_**

## ------------------------------------------------------------------------
flights <- flights %>% 
  mutate(gain = arr_delay - dep_delay)

## ------------------------------------------------------------------------
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
kable(gain_summary)

## ----message=FALSE, fig.cap="Histogram of gain variable"-----------------
ggplot(data = flights, mapping = aes(x = gain)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
flights <- flights %>% 
  mutate(
    gain = arr_delay - dep_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours
  )

## ---- eval---------------------------------------------------------------
freq_dest <- flights %>% 
  group_by(dest) %>% 
  summarize(num_flights = n())
freq_dest

## ------------------------------------------------------------------------
freq_dest %>% arrange(num_flights)

## ------------------------------------------------------------------------
freq_dest %>% arrange(desc(num_flights))

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
## flights %>%
##   inner_join(airports, by = c("dest" = "faa"))

## ---- eval=FALSE---------------------------------------------------------
## named_dests <- flights %>%
##   group_by(dest) %>%
##   summarize(num_flights = n()) %>%
##   arrange(desc(num_flights)) %>%
##   inner_join(airports, by = c("dest" = "faa")) %>%
##   rename(airport_name = name)
## View(named_dests)

## ---- eval=FALSE---------------------------------------------------------
## glimpse(flights)

## ---- eval=FALSE---------------------------------------------------------
## flights %>%
##   select(carrier, flight)

## ---- eval=FALSE---------------------------------------------------------
## flights_no_year <- flights %>%
##   select(-year)
## names(flights_no_year)

## ---- eval=FALSE---------------------------------------------------------
## flight_arr_times <- flights %>%
##   select(month:day, arr_time:sched_arr_time)
## flight_arr_times

## ---- eval=FALSE---------------------------------------------------------
## flights_reorder <- flights %>%
##   select(month:day, hour:time_hour, everything())
## names(flights_reorder)

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
## names(flights_time)

## ---- eval=FALSE---------------------------------------------------------
## named_dests %>%
##   top_n(n = 10, wt = num_flights)

## ---- eval=FALSE---------------------------------------------------------
## named_dests  %>%
##   top_n(n = 10, wt = num_flights) %>%
##   arrange(desc(num_flights))

## ---- eval=FALSE---------------------------------------------------------
## ten_freq_dests <- flights %>%
##   group_by(dest) %>%
##   summarize(num_flights = n()) %>%
##   top_n(n = 10) %>%
##   arrange(desc(num_flights))
## View(ten_freq_dests)

