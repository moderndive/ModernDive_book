## ---- message=FALSE------------------------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights13)
library(knitr)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.

## ---- eval=FALSE---------------------------------------------------------
## portland_flights <- flights %>%
##   filter(dest == "PDX")
## View(portland_flights)

## ---- eval=FALSE---------------------------------------------------------
## btv_sea_flights_fall <- flights %>%
##   filter(origin == "JFK", (dest == "BTV" | dest == "SEA"), month >= 10)
## View(btv_sea_flights_fall)

## ---- eval=FALSE---------------------------------------------------------
## not_BTV_SEA <- flights %>%
##   filter(!(dest == "BTV" | dest == "SEA"))
## View(not_BTV_SEA)

## **Learning Check Solutions**

## ---- eval=FALSE, echo=show_solutions('5-1')-----------------------------
## # Original in book
## not_BTV_SEA <- flights %>%
##   filter(!(dest == "BTV" | dest == "SEA"))
## 
## # Alternative way
## not_BTV_SEA <- flights %>%
##   filter(!dest == "BTV" & !dest == "SEA")
## 
## # Yet another way
## not_BTV_SEA <- flights %>%
##   filter(dest != "BTV" & dest != "SEA")

## ------------------------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp), std_dev = sd(temp))
kable(summary_temp)

## ------------------------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp, na.rm = TRUE), std_dev = sd(temp, na.rm = TRUE))
kable(summary_temp)

## ------------------------------------------------------------------------
#summary_temp$mean

## ----eval=FALSE----------------------------------------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp, na.rm = TRUE)) %>%
##   summarize(std_dev = sd(temp, na.rm = TRUE))

## **Learning Check Solutions**

## ---- eval=show_solutions('5-2'), echo=show_solutions('5-2')-------------
data(weather)
weather %>% 
  summarize(count = n())

## **`r paste0("(LC", chap, ".", (lc), ")")`** Why doesn't the following code work?

## ----eval=FALSE, include=show_solutions('5-2')---------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp, na.rm = TRUE)) %>%
##   summarize(std_dev = sd(temp, na.rm = TRUE))

## Consider the output of only running the first two lines:

## ---- eval=show_solutions('5-2'), echo=show_solutions('5-2')-------------
weather %>%   
  summarize(mean = mean(temp, na.rm = TRUE))

## Because after the first `summarize()`, the variable `temp` disappears as it has been collapsed to the value `mean`. So when we try to run the second `summarize()`, it can't find the variable temp` to compute the standard deviation of.

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

## **_Learning check_**

## **Learning Check Solutions**

## ---- echo=show_solutions('5-2')-----------------------------------------
library(dplyr)
library(nycflights13)

summary_temp_by_month <- weather %>% 
  group_by(month) %>% 
  summarize(
          mean = mean(temp, na.rm = TRUE),
          std_dev = sd(temp, na.rm = TRUE)
          )

## ---- echo=FALSE, include=show_solutions('5-2')--------------------------
kable(summary_temp_by_month)

## The standard deviation is a quantification of **spread** and **variability**. We

## ---- echo=show_solutions('5-2'), include=show_solutions('5-2')----------
summary_temp_by_day <- weather %>% 
  group_by(year, month, day) %>% 
  summarize(
          mean = mean(temp, na.rm = TRUE),
          std_dev = sd(temp, na.rm = TRUE)
          )
summary_temp_by_day

## Note: `group_by(day)` is not enough, because `day` is a value between 1-31. We need to `group_by(year, month, day)`

## ---- echo=show_solutions('5-2'), include=show_solutions('5-2')----------
by_monthly_origin <- flights %>% 
  group_by(month, origin) %>% 
  summarize(count = n())

## ---- eval=FALSE, echo=show_solutions('5-2')-----------------------------
## by_monthly_origin

## ---- echo=FALSE, include=show_solutions('5-2')--------------------------
kable(by_monthly_origin)

## The difference is they are organized/sorted by `month` first, then `origin`

## ---- echo=show_solutions('5-2'), include=show_solutions('5-2')----------
count_flights_by_airport <- flights %>% 
  group_by(origin, month) %>% 
  summarize(count=n())

## ---- eval=FALSE, include=show_solutions('5-2')--------------------------
## count_flights_by_airport

## ---- echo=FALSE, include=show_solutions('5-2')--------------------------
kable(count_flights_by_airport)

## All remarkably similar!

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

## **Learning Check Solutions**

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

## **`r paste0("(LC", chap, ".", (lc - 1), ")")`** Looking at Figure \@ref(fig:reldiagram), when joining `flights` and `weather` (or, in other words, matching the hourly weather values with each flight), why do we need to join by all of `year`, `month`, `day`, `hour`, and `origin`, and not just `hour`?

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
##   arrange(desc(num_flights)) %>%
##   top_n(n = 10)
## View(ten_freq_dests)

## **`r paste0("(LC", chap, ".", (lc - 2), ")")`** How could one use `starts_with`, `ends_with`, and `contains` to select columns from the `flights` data frame?  Provide three different examples in total: one for `starts_with`, one for `ends_with`, and one for `contains`.

## ---- echo=show_solutions('5-4')-----------------------------------------
library(dplyr)
library(nycflights13)

## ---- echo=show_solutions('5-4'), eval=FALSE-----------------------------
## # The regular way:
## flights %>%
##   select(dest, air_time, distance)
## 
## # Since they are sequential columns in the dataset
## flights %>%
##   select(dest:distance)
## 
## # Not as effective, by removing everything else
## flights %>%
##   select(-year, -month, -day, -dep_time, -sched_dep_time, -dep_delay, -arr_time,
##          -sched_arr_time, -arr_delay, -carrier, -flight, -tailnum, -origin,
##          -hour, -minute, -time_hour)

## **`r paste0("(LC", chap, ".", (lc - 1), ")")`** Why might we want to use the `select` function on a data frame?

## ---- echo=TRUE, eval=FALSE----------------------------------------------
## # Anything that starts with "d"
## flights %>%
##   select(starts_with("d"))
## # Anything related to delays:
## flights %>%
##   select(ends_with("delay"))
## # Anything related to departures:
## flights %>%
##   select(contains("dep"))

## **`r paste0("(LC", chap, ".", (lc), ")")`** Create a new data frame that shows the top 5 airports with the largest arrival delays from NYC in 2013.To narrow down the data frame, to make it easier to look at. Using `View()` for example.

