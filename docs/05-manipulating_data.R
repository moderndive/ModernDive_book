## ------------------------------------------------------------------------
if(!require(nycflights13))
  install.packages("nycflights13", repos = "http://cran.rstudio.org")
library(nycflights13)
data(flights)
dim(flights)
ncol(flights)

## ------------------------------------------------------------------------
if(!require(dplyr))
  install.packages("dplyr", repos = "http://cran.rstudio.org")
library(dplyr)
flights <- flights %>% select(-year)
names(flights)

## ------------------------------------------------------------------------
flight_dep_times <- flights %>% select(month, day, dep_time, sched_dep_time)
flight_dep_times

## ------------------------------------------------------------------------
flight_arr_times <- flights %>% select(month:day, arr_time:sched_arr_time)
flight_arr_times

## ------------------------------------------------------------------------
flights_reorder <- flights %>% select(month:day, hour:time_hour, everything())
names(flights_reorder)

## ------------------------------------------------------------------------
flights_begin_a <- flights %>% select(starts_with("a"))
flights_begin_a

## ------------------------------------------------------------------------
flights_delays <- flights %>% select(ends_with("delay"))
flights_delays

## ------------------------------------------------------------------------
flights_time <- flights %>% select(contains("time"))
flights_time

## ------------------------------------------------------------------------
flights_time <- flights_time %>% 
  rename(departure_time = dep_time,
         arrival_time = arr_time)
names(flights_time)

## ------------------------------------------------------------------------
portland_flights <- flights %>% filter(dest == "PDX")
portland_flights

## ----eval=FALSE----------------------------------------------------------
## portland_flights <- filter(flights, dest = "PDX")

## ------------------------------------------------------------------------
reordered_flights <- flights %>% select(dest, everything())
pdx_flights <- reordered_flights %>% filter(dest == "PDX")
pdx_flights

## ------------------------------------------------------------------------
btv_sea_flights_fall <- flights %>% filter(
                               origin == "JFK", 
                               (dest == "BTV") | (dest == "SEA"),
                               month >= 10)

## ------------------------------------------------------------------------
not_summer_flights <- flights %>% filter(!between(month, 6, 8))
not_summer_flights

## ------------------------------------------------------------------------
not_summer_flights %>% count(month)

## ------------------------------------------------------------------------
<<<<<<< HEAD
not_summer2 <- flights %>% filter(month <= 5 | month >= 9)
not_summer2 %>% count(month)
=======
not_summer2 <- filter(flights, month <= 5 | month >= 9)
count(not_summer2, month)
>>>>>>> 4ab23aa9ddd89413ce4a5aec177faec9ef4a0378

## ------------------------------------------------------------------------
weather %>% summarize(mean = mean(temp),
                      std_dev = sd(temp))

## ------------------------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp, na.rm = TRUE),
            std_dev = sd(temp, na.rm = TRUE))
summary_temp

## ------------------------------------------------------------------------
summary_temp$mean
summary_temp$std_dev

## ------------------------------------------------------------------------
summary_tempXmonth <- weather %>%
  group_by(month) %>%
  summarize(mean = mean(temp, na.rm = TRUE),
          std_dev = sd(temp, na.rm = TRUE)
          )
summary_tempXmonth

## ------------------------------------------------------------------------
by_origin <- flights %>% 
  group_by(origin) %>% 
  summarize(count = n())
by_origin

## ------------------------------------------------------------------------
flights_plus <- flights %>% mutate(gain = arr_delay - dep_delay)

## ------------------------------------------------------------------------
gain_summary <- flights_plus %>% summarize(
          min = min(gain, na.rm = TRUE),
          q1 = quantile(gain, 0.25, na.rm = TRUE),
          median = quantile(gain, 0.5, na.rm = TRUE),
          q3 = quantile(gain, 0.75, na.rm = TRUE),
          max = max(gain, na.rm = TRUE),
          mean = mean(gain, na.rm = TRUE),
          sd = sd(gain, na.rm = TRUE),
          missing = sum(is.na(gain))
)
gain_summary

## ----message=FALSE, warning=FALSE, fig.cap="Histogram of gain variable"----
library(ggplot2)
ggplot(flights_plus, aes(x = gain)) +
  geom_histogram(color = "white", bins = 20)

## ------------------------------------------------------------------------
flights_plus2 <- flights %>% mutate(
  gain = arr_delay - dep_delay,
  hours = air_time / 60,
  gain_per_hour = gain / hours
)

## ------------------------------------------------------------------------
freq_dest <- flights %>% group_by(dest) %>% 
  summarize(by_dest, num_flights = n())
freq_dest

## ------------------------------------------------------------------------
freq_dest %>% arrange(num_flights)

## ------------------------------------------------------------------------
freq_dest %>% arrange(desc(num_flights))

## ------------------------------------------------------------------------
freq_dest %>% top_n(n = 10, wt = num_flights)

## ------------------------------------------------------------------------
ten_freq_dests <- flights %>%
  group_by(dest) %>%
  summarize(num_flights = n()) %>%
  top_n(n = 10) %>%
  arrange(desc(num_flights))

## ----eval=FALSE----------------------------------------------------------
## View(airports)

## ------------------------------------------------------------------------
airports_small <- airports %>%
  select(faa, name)

## ------------------------------------------------------------------------
named_freq_dests <- ten_freq_dests %>%
  inner_join(airports_small, by = c("dest" = "faa")) %>%
  rename(airport_name = name)
named_freq_dests
