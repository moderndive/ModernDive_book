## ---- message=FALSE------------------------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights13)

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

## ---- eval=FALSE---------------------------------------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp), std_dev = sd(temp))
## summary_temp

## ---- echo=FALSE---------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp), std_dev = sd(temp))
kable(summary_temp)

## ---- eval=FALSE---------------------------------------------------------
## summary_temp <- weather %>%
##   summarize(mean = mean(temp, na.rm = TRUE), std_dev = sd(temp, na.rm = TRUE))
## summary_temp

## ---- echo=FALSE---------------------------------------------------------
summary_temp <- weather %>% 
  summarize(mean = mean(temp, na.rm = TRUE), std_dev = sd(temp, na.rm = TRUE))
kable(summary_temp)

## ------------------------------------------------------------------------
#summary_temp$mean

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
kable(summary_monthly_temp)

## ---- eval=FALSE---------------------------------------------------------
## by_origin <- flights %>%
##   group_by(origin) %>%
##   summarize(count = n())
## by_origin

## ---- echo=FALSE---------------------------------------------------------
by_origin <- flights %>% 
  group_by(origin) %>% 
  summarize(count = n())
kable(by_origin)

## ------------------------------------------------------------------------
by_origin_monthly <- flights %>% 
  group_by(origin, month) %>% 
  summarize(count = n())
by_origin_monthly

## ------------------------------------------------------------------------
by_monthly_origin <- flights %>% 
  group_by(month, origin) %>% 
  summarize(count = n())
by_monthly_origin

## ------------------------------------------------------------------------
by_origin_monthly_incorrect <- flights %>% 
  group_by(origin) %>% 
  group_by(month) %>% 
  summarize(count = n())
by_origin_monthly_incorrect

## ---- eval=FALSE---------------------------------------------------------
## by_monthly_origin <- flights %>%
##   count(origin, month)
## by_monthly_origin

## NA
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
kable(gain_summary)

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
## flights %>%
##   inner_join(airports, by = c("dest" = "faa"))

## ------------------------------------------------------------------------
named_dests <- flights %>%
  group_by(dest) %>%
  summarize(num_flights = n()) %>%
  arrange(desc(num_flights)) %>%
  inner_join(airports, by = c("dest" = "faa")) %>%
  rename(airport_name = name)
named_dests

## ------------------------------------------------------------------------
flights_weather_joined <- flights %>%
  inner_join(weather, by = c("year", "month", "day", "hour", "origin"))
flights_weather_joined

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

## ----wrangle-summary-table, echo=FALSE, message=FALSE--------------------
# Original at https://docs.google.com/spreadsheets/d/1nRkXfYMQiTj79c08xQPY0zkoJSpde3NC1w6DRhsWCss/edit#gid=0
read_csv("data/ch5_summary_table - Sheet1.csv", na = "") %>% 
  rename_(" " = "X1") %>% 
  kable(
    caption = "Summary of data wrangling verbs", 
    booktabs = TRUE
  )

## **Learning Check Solutions**

## ----lc5-71solutions-2, include=show_solutions('5-7')--------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance) %>% 
  mutate(ASM = seats * distance) %>% 
  group_by(carrier) %>% 
  summarize(ASM = sum(ASM, na.rm = TRUE)) %>% 
  arrange(desc(ASM))

## Let's now break this down step-by-step. To compute the available seat miles for a given flight, we need the `distance` variable from the `flights` data frame and the `seats` variable from the `planes` data frame, necessitating a join by the key variable `tailnum` as illustrated in Figure \@ref(fig:reldiagram). To keep the resulting data frame easy to view, we'll `select()` only these two variables and `carrier`:

## ----lc5-71solutions-4, include=show_solutions('5-7')--------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance)

## Now for each flight we can compute the available seat miles `ASM` by multiplying the number of seats by the distance via a `mutate()`:

## ----lc5-71solutions-6, include=show_solutions('5-7')--------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance) %>% 
  # Added:
  mutate(ASM = seats * distance)

## Next we want to sum the `ASM` for each carrier. We achieve this by first grouping by `carrier` and then summarizing using the `sum()` function:

## ----lc5-71solutions-8, include=show_solutions('5-7')--------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance) %>% 
  mutate(ASM = seats * distance) %>% 
  # Added:
  group_by(carrier) %>% 
  summarize(ASM = sum(ASM))

## However, because for certain carriers certain flights have missing `NA` values, the resulting table also returns `NA`'s. We can eliminate these by adding a `na.rm = TRUE` argument to `sum()`, telling R that we want to remove the `NA`'s in the sum. We saw this in Section \ref(summarize):

## ----lc5-71solutions-10, include=show_solutions('5-7')-------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance) %>% 
  mutate(ASM = seats * distance) %>% 
  group_by(carrier) %>% 
  # Modified:
  summarize(ASM = sum(ASM, na.rm = TRUE))

## Finally, we `arrange()` the data in `desc()`ending order of `ASM`.

## ----lc5-71solutions-12, include=show_solutions('5-7')-------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance) %>% 
  mutate(ASM = seats * distance) %>% 
  group_by(carrier) %>% 
  summarize(ASM = sum(ASM, na.rm = TRUE)) %>% 
  # Added:
  arrange(desc(ASM))

## While the above data frame is correct, the IATA `carrier` code is not always useful. For example, what carrier is `WN`? We can address this by joining with the `airlines` dataset using `carrier` is the key variable. While this step is not absolutely required, it goes a long way to making the table easier to make sense of. It is important to be empathetic with the ultimate consumers of your presented data!

## ----lc5-71solutions-14, include=show_solutions('5-7')-------------------
flights %>% 
  inner_join(planes, by = "tailnum") %>% 
  select(carrier, seats, distance) %>% 
  mutate(ASM = seats * distance) %>% 
  group_by(carrier) %>% 
  summarize(ASM = sum(ASM, na.rm = TRUE)) %>% 
  arrange(desc(ASM)) %>% 
  # Added:
  inner_join(airlines, by = "carrier")

