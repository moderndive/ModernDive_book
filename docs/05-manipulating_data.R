## ----setup_manip, include=FALSE------------------------------------------
chap <- 5
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**
knitr::opts_chunk$set(tidy = FALSE, fig.align = "center", out.width = '\\textwidth')

## ----selectfig, echo=FALSE, fig.cap="Select diagram from Data Wrangling with dplyr and tidyr cheatsheet"----
knitr::include_graphics("images/select.png")

## ------------------------------------------------------------------------
library(nycflights13)
data(flights)
dim(flights)
ncol(flights)

## ------------------------------------------------------------------------
if(!require(dplyr))
  install.packages("dplyr", repos = "http://cran.rstudio.org")
library(dplyr)
flights <- select(.data = flights, -year)
names(flights)

## ------------------------------------------------------------------------
flight_dep_times <- select(flights, month, day, dep_time, sched_dep_time)
flight_dep_times

## ------------------------------------------------------------------------
flight_arr_times <- select(flights, month:day, arr_time:sched_arr_time)
flight_arr_times

## ------------------------------------------------------------------------
flights_reorder <- select(flights, month:day, hour:time_hour, everything())
names(flights_reorder)

## ------------------------------------------------------------------------
flights_begin_a <- select(flights, starts_with("a"))
flights_begin_a

## ------------------------------------------------------------------------
flights_delays <- select(flights, ends_with("delay"))
flights_delays

## ------------------------------------------------------------------------
flights_time <- select(flights, contains("time"))
flights_time

## ------------------------------------------------------------------------
flights_time <- rename(flights_time,
                       departure_time = dep_time,
                       arrival_time = arr_time)
names(flights_time)

## ----lc5-1, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----filter, echo=FALSE, fig.cap="Filter diagram from Data Wrangling with dplyr and tidyr cheatsheet"----
knitr::include_graphics("images/filter.png")

## ------------------------------------------------------------------------
portland_flights <- filter(flights, dest == "PDX")
portland_flights

## ----eval=FALSE----------------------------------------------------------
## portland_flights <- filter(flights, dest = "PDX")

## ------------------------------------------------------------------------
reordered_flights <- select(flights, dest, everything())
pdx_flights <- filter(reordered_flights, dest == "PDX")
pdx_flights

## ------------------------------------------------------------------------
btv_sea_flights_fall <- filter(flights,
                               origin == "JFK", 
                               (dest == "BTV") | (dest == "SEA"),
                               month >= 10)

## ------------------------------------------------------------------------
not_summer_flights <- filter(flights,
                             !between(month, 6, 8))
not_summer_flights

## ------------------------------------------------------------------------
count(not_summer_flights, month)

## ------------------------------------------------------------------------
not_summer2 <- filter(flights, month <= 5 | month >= 9)
count(not_summer2, month)

## ----lc5-2, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----sum1, echo=FALSE, fig.cap="Summarize diagram from Data Wrangling with dplyr and tidyr cheatsheet"----
knitr::include_graphics("images/summarize1.png")

## ----sum2, echo=FALSE, fig.cap="Another summarize diagram from Data Wrangling with dplyr and tidyr cheatsheet"----
knitr::include_graphics("images/summary.png")

## ------------------------------------------------------------------------
summarize(weather,
          mean = mean(temp),
          std_dev = sd(temp))

## ------------------------------------------------------------------------
summary_temp <- summarize(weather,
          mean = mean(temp, na.rm = TRUE),
          std_dev = sd(temp, na.rm = TRUE)
          )
summary_temp

## ------------------------------------------------------------------------
summary_temp$mean
summary_temp$std_dev

## ----groupsummarize, echo=FALSE,fig.cap="Group by and summarize diagram from Data Wrangling with dplyr and tidyr cheatsheet"----
knitr::include_graphics("images/group_summary.png")

## ------------------------------------------------------------------------
grouped_weather <- group_by(weather, month)
summary_tempXmonth <- summarize(grouped_weather,
          mean = mean(temp, na.rm = TRUE),
          std_dev = sd(temp, na.rm = TRUE)
          )
summary_tempXmonth

## ------------------------------------------------------------------------
grouped_flights <- group_by(flights, origin)
by_origin <- summarize(grouped_flights,
                       count = n())
by_origin

## ----lc5-3, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----select, echo=FALSE, fig.cap="Mutate diagram from Data Wrangling with dplyr and tidyr cheatsheet"----
knitr::include_graphics("images/mutate.png")

## ------------------------------------------------------------------------
flights_plus <- mutate(flights,
         gain = arr_delay - dep_delay)

## ------------------------------------------------------------------------
gain_summary <- summarize(flights_plus,
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
flights_plus2 <- mutate(flights,
  gain = arr_delay - dep_delay,
  hours = air_time / 60,
  gain_per_hour = gain / hours
)

## ----lc5-4, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ------------------------------------------------------------------------
by_dest <- group_by(flights, dest)
freq_dest <- summarize(by_dest, num_flights = n())
freq_dest

## ------------------------------------------------------------------------
arrange(freq_dest, num_flights)

## ------------------------------------------------------------------------
arrange(freq_dest, desc(num_flights))

## ------------------------------------------------------------------------
top_n(freq_dest, n = 10, wt = num_flights)

## ------------------------------------------------------------------------
arrange(top_n(freq_dest, n = 10, wt = num_flights), desc(num_flights))

## ----lc5-5, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----eval=FALSE----------------------------------------------------------
## arrange(top_n(freq_dest, n = 10, wt = num_flights), desc(num_flights))

## ------------------------------------------------------------------------
arrange(
  top_n(freq_dest, 
        n = 10,
        wt = num_flights), 
  desc(num_flights))

## ------------------------------------------------------------------------
freq_dest %>%
  top_n(n = 10, wt = num_flights) %>%
  arrange(desc(num_flights))

## ------------------------------------------------------------------------
ten_freq_dests <- flights %>%
  group_by(dest) %>%
  summarize(num_flights = n()) %>%
  top_n(n = 10) %>%
  arrange(desc(num_flights))

## ----lc5-6, type='learncheck', engine="block"----------------------------
**_Learning check_**

## ----eval=FALSE----------------------------------------------------------
## View(airports)

## ----reldiagram, echo=FALSE, fig.cap="Data relationships in nycflights13 from R for Data Science"----
knitr::include_graphics("images/relational-nycflights.png")

## ------------------------------------------------------------------------
airports_small <- airports %>%
  select(faa, name)

## ------------------------------------------------------------------------
named_freq_dests <- ten_freq_dests %>%
  inner_join(airports_small, by = c("dest" = "faa")) %>%
  rename(airport_name = name)
named_freq_dests

## ----ijdiagram, echo=FALSE, fig.cap="Diagram of inner join from R for Data Science"----
knitr::include_graphics("images/join-inner.png")

## ----lc5-7, type='learncheck', engine="block"----------------------------
**_Learning check_**

