## ----setup_viz, include=FALSE--------------------------------------------
knitr::opts_chunk$set(tidy = FALSE, fig.align = "center", out.width='\\textwidth')

## ----warning=FALSE, message=FALSE, results="hide"------------------------
if(!require("nycflights13"))
  install.packages("nycflights13", repos = "http://cran.rstudio.org")
library(nycflights13)
data(weather)

## ----echo=FALSE, warning=FALSE, fig.height=0.8, fig.cap="Strip Plot of Hourly Temperature Recordings from NYC in 2013"----
hist_title <- "Histogram of Hourly Temperature Recordings from NYC in 2013"
library(ggplot2)
ggplot(data = weather, mapping = aes(x = temp, y = factor("A"))) +
  geom_point() +
  theme(axis.ticks.y = element_blank(), axis.title.y = element_blank(),
    axis.text.y = element_blank())

## ----fig.cap="ggplot backdrop", fig.width=8, fig.height=3----------------
if(!require("ggplot2"))
  install.packages("ggplot2", repos = "http://cran.rstudio.org")
library(ggplot2)
ggplot(data = weather, mapping = aes(x = temp))

## ----fig.cap=hist_title, fig.height=3------------------------------------
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram()

## ----fig.cap=paste(hist_title, "- 60 Bins"), warning=FALSE, fig.height=5----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(bins = 60)

## ----fig.cap=paste(hist_title, "- Binwidth = 10"), warning=FALSE, fig.height=5----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 10, color = "white", fill = "forestgreen")

## ------------------------------------------------------------------------
summary(weather$temp)

## ------------------------------------------------------------------------
sd(weather$temp)

## ----eval=FALSE----------------------------------------------------------
## ?sd

## ------------------------------------------------------------------------
sd(weather$temp, na.rm = TRUE)

## ----facethistogram, warning=FALSE, fig.cap="Faceted histogram"----------
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 5, color = "white", fill = "firebrick") +
  facet_wrap(~ month)

## ----badbox, fig.cap="Invalid boxplot specification", fig.height=3.5-----
ggplot(data = weather, mapping = aes(x = month, y = temp)) +
  geom_boxplot()

## ----monthtempbox, fig.cap="Month by temp boxplot", warning=FALSE, fig.height=3.7----
ggplot(data = weather, mapping = aes(x = factor(month), y = temp)) +
  geom_boxplot()

## ----flightsbar, fig.cap="Number of flights departing NYC in 2013 by airline", fig.height=2.5----
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()

## ----warning=FALSE, message=FALSE----------------------------------------
if(!require("nycflights13"))
  install.packages("nycflights13", repos = "http://cran.rstudio.org")
library(nycflights13)
data(airlines)
airlines

## ----warning=FALSE, message=FALSE----------------------------------------
if(!require("dplyr"))
  install.packages("dplyr", repos = "http://cran.rstudio.org")
library(dplyr)
flights_table <- count(x = flights, vars = carrier)
flights_table

## ----carrierpie, echo=FALSE, fig.cap="The dreaded pie chart", fig.height=5----
ggplot(flights, aes(x = factor(1), fill = carrier)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y") +
  theme(axis.title.x = element_blank(), 
    axis.title.y = element_blank(),
    axis.ticks = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()) +
  guides(fill = guide_legend(keywidth = 0.8, keyheight = 0.8))

## ----echo=FALSE, fig.align='center', fig.cap="The only good pie chart", out.height=if(knitr:::is_latex_output()) '2.5in'----
knitr::include_graphics("images/Pie-I-have-Eaten.jpg")

## ----message=FALSE-------------------------------------------------------
library(dplyr)
flights_namedports <- inner_join(flights, airports, by = c("origin" = "faa"))

## ---- fig.cap="Stacked barplot comparing the number of flights by carrier and airport", fig.height=3.5----
ggplot(data = flights_namedports, mapping = aes(x = carrier, fill = name)) +
  geom_bar()

## ---- fig.cap="Side-by-side barplot comparing the number of flights by carrier and airport", fig.height=5----
ggplot(data = flights_namedports, mapping = aes(x = carrier, fill = name)) +
  geom_bar(position = "dodge")

## ---- fig.cap="Faceted barplot comparing the number of flights by carrier and airport", fig.height=7.5----
ggplot(data = flights_namedports, mapping = aes(x = carrier, fill = name)) +
  geom_bar() +
  facet_grid(name ~ .)

## ----include=FALSE-------------------------------------------------------
alaska_cap <- "Arrival Delays vs Departure Delays for Alaska Airlines flights from NYC in 2013"

## ----noalpha, warning=FALSE, fig.cap=alaska_cap, fig.height=4------------
alaska_flights <- filter(flights, carrier == "AS")
ggplot(alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_point()

## ----warning=FALSE, fig.cap="Jittered delay scatterplot", fig.height=4----
ggplot(alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)

## ----alpha, warning=FALSE, fig.cap=paste(alaska_cap, "- alpha=0.2", fig.height=1)----
ggplot(alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)

## ----jitteralpha, warning=FALSE, fig.cap=paste(alaska_cap, "- jitter and alpha added", fig.height=1)----
ggplot(alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30, alpha = 0.3)

## ----warning=FALSE, fig.cap="Hard to read scatterplot", cache=TRUE-------
ggplot(flights, aes(x = time_hour, y = arr_delay)) + 
  geom_point()

## ------------------------------------------------------------------------
flights_day <- mutate(flights, date = as.Date(time_hour))

## ------------------------------------------------------------------------
flights_summarized <- flights_day %>% group_by(date) %>%
  summarize(median_arr_delay = median(arr_delay, na.rm = TRUE))
flights_summarized

## ----lineflights, fig.cap="Line-graph of median arrival delay for flights leaving NYC in 2013 versus day of the year", fig.height=3.1----
ggplot(data = flights_summarized, aes(x = date, y = median_arr_delay)) +
  geom_line()

## ----include=FALSE-------------------------------------------------------
knitr::purl("04-visualizing_data.Rmd")

