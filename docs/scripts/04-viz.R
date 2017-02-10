## ----warning=FALSE-------------------------------------------------------
library(ggplot2)
library(nycflights13)
library(knitr)
library(dplyr)

## ---- echo=FALSE---------------------------------------------------------
map <- data_frame(
  data = c("longitude", "latitude", "army size", "army direction"),
  aes = c("x", "y", "size", "color"),
  geom = c("point", "point", "path", "path")
)
line_graph <- data_frame(
  data = c("date", "temperature"),
  aes = c("x", "y"),
  geom = c("line & text", "line & text") 
)

knitr::kable(
  list(
    map,
    line_graph
  ),
  caption = "Grammar of Map (Top) and Line-Graph (Bottom) in Minard's Graphic of Napolean's March", booktabs = TRUE
)

## ----viz_review, type='review', engine="block"---------------------------
**_Review questions_**

## ------------------------------------------------------------------------
data(flights)
all_alaska_flights <- flights %>% 
  filter(carrier == "AS")

## ----noalpha, fig.cap="Arrival Delays vs Departure Delays for Alaska Airlines flights from NYC in 2013"----
ggplot(data = all_alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_point()

## ----alpha, fig.cap="Delay scatterplot with alpha=0.2"-------------------
ggplot(data = all_alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)

## ----jitter, fig.cap="Jittered delay scatterplot"------------------------
ggplot(data = all_alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)

## ------------------------------------------------------------------------
data(weather)
early_january_weather <- weather %>% 
  filter(origin == "EWR" & month == 1 & day <= 15)

## ----hourlytemp, fig.cap="Hourly Temperature in Newark for Jan 1-15 2013"----
ggplot(data = early_january_weather, aes(x = time_hour, y = temp)) +
  geom_line()

## ----echo=FALSE, fig.height=0.8, fig.cap="Strip Plot of Hourly Temperature Recordings from NYC in 2013"----
ggplot(data = weather, mapping = aes(x = temp, y = factor("A"))) +
  geom_point() +
  theme(axis.ticks.y = element_blank(), 
        axis.title.y = element_blank(),
        axis.text.y = element_blank())
hist_title <- "Histogram of Hourly Temperature Recordings from NYC in 2013"

## ---- warning=TRUE, fig.cap=hist_title-----------------------------------
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram()

## ----fig.cap=paste(hist_title, "- 60 Bins")------------------------------
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(bins = 60, color = "white")

## ----fig.cap=paste(hist_title, "- Binwidth = 10"), fig.height=5----------
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 10, color = "white")

## ----facethistogram, fig.cap="Faceted histogram"-------------------------
ggplot(data = weather, aes(x = temp)) +
  geom_histogram(binwidth = 5, color = "white") +
  facet_wrap(~ month, nrow = 4)

## ----badbox, fig.cap="Invalid boxplot specification", fig.height=3.5-----
ggplot(data = weather, aes(x = month, y = temp)) +
  geom_boxplot()

## ----monthtempbox, fig.cap="Month by temp boxplot", fig.height=3.7-------
ggplot(data = weather, mapping = aes(x = factor(month), y = temp)) +
  geom_boxplot()

## ----flightsbar, fig.cap="Number of flights departing NYC in 2013 by airline", fig.height=2.5----
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()

## ------------------------------------------------------------------------
data(airlines)
kable(airlines)

## ----message=FALSE-------------------------------------------------------
flights_table <- flights %>% dplyr::count(carrier)
knitr::kable(flights_table)

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

## ----message=FALSE-------------------------------------------------------
flights_namedports <- flights %>% 
  inner_join(airports, by = c("origin" = "faa"))

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

## ----viz-map, echo=FALSE, fig.cap="Mind map for Data Visualization", out.width="200%"----
#library(knitr)
#if(knitr:::is_html_output()){
#  include_url("https://coggle.it/diagram/V_G2gzukTDoQ-aZt-", 
#              height = "1000px")
#} else {
  include_graphics("images/coggleviz.png", dpi = 300)
#}

