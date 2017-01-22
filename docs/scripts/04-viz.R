## ----setup_viz, include=FALSE--------------------------------------------
chap <- 4
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**
knitr::opts_chunk$set(
  tidy = FALSE, 
  out.width = '\\textwidth', 
  fig.height = 4,
  warning = FALSE
  )

## ----warning=FALSE-------------------------------------------------------
library(ggplot2)
library(nycflights13)
library(knitr)
library(dplyr)

## ----minard, echo=FALSE, fig.cap="Minard's Visualization of Napolean's March"----
knitr::include_graphics("images/Minard.png")

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

## ----lc-all_alaska_flights, type='learncheck', engine="block"------------
**_Learning check_**

## ----noalpha, fig.cap="Arrival Delays vs Departure Delays for Alaska Airlines flights from NYC in 2013"----
ggplot(data = all_alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_point()

## ----lc-scatter-plots, type='learncheck', engine="block"-----------------
**_Learning check_**

## ----alpha, fig.cap="Delay scatterplot with alpha=0.2"-------------------
ggplot(data = all_alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)

## ----jitter, fig.cap="Jittered delay scatterplot"------------------------
ggplot(data = all_alaska_flights, aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)

## ----lc-overplotting, type='learncheck', engine="block"------------------
**_Learning check_**

## ------------------------------------------------------------------------
data(weather)
early_january_weather <- weather %>% 
  filter(origin == "EWR" & month == 1 & day <= 15)

## ----lc-early_january_weather, type='learncheck', engine="block"---------
**_Learning check_**

## ----hourlytemp, fig.cap="Hourly Temperature in Newark for Jan 1-15 2013"----
ggplot(data = early_january_weather, aes(x = time_hour, y = temp)) +
  geom_line()

## ----lc-line-graph, type='learncheck', engine="block"--------------------
**_Learning check_**

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

## ----lc-histogram, type='learncheck', engine="block"---------------------
**_Learning check_**

## ----facethistogram, fig.cap="Faceted histogram"-------------------------
ggplot(data = weather, aes(x = temp)) +
  geom_histogram(binwidth = 5, color = "white") +
  facet_wrap(~ month, nrow = 4)

## ----lc-facet, type='learncheck', engine="block"-------------------------
**_Learning check_**

## ----badbox, fig.cap="Invalid boxplot specification", fig.height=3.5-----
ggplot(data = weather, aes(x = month, y = temp)) +
  geom_boxplot()

## ----monthtempbox, fig.cap="Month by temp boxplot", fig.height=3.7-------
ggplot(data = weather, mapping = aes(x = factor(month), y = temp)) +
  geom_boxplot()

## ----lc-boxplot, type='learncheck', engine="block"-----------------------
**_Learning check_**

## ----flightsbar, fig.cap="Number of flights departing NYC in 2013 by airline", fig.height=2.5----
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()

## ------------------------------------------------------------------------
data(airlines)
kable(airlines)

## ----message=FALSE-------------------------------------------------------
flights_table <- flights %>% dplyr::count(carrier)
knitr::kable(flights_table)

## ----lc-barplot, type='learncheck', engine="block"-----------------------
**_Learning check_**

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

## ----lc-pie-charts, type='learncheck', engine="block"--------------------
**_Learning check_**

## ----message=FALSE-------------------------------------------------------
flights_namedports <- flights %>% 
  inner_join(airports, by = c("origin" = "faa"))

## ---- fig.cap="Stacked barplot comparing the number of flights by carrier and airport", fig.height=3.5----
ggplot(data = flights_namedports, mapping = aes(x = carrier, fill = name)) +
  geom_bar()

## ----lc-barplot-two-var, type='learncheck', engine="block"---------------
**_Learning check_**

## ---- fig.cap="Side-by-side barplot comparing the number of flights by carrier and airport", fig.height=5----
ggplot(data = flights_namedports, mapping = aes(x = carrier, fill = name)) +
  geom_bar(position = "dodge")

## ----lc-barplot-stacked, type='learncheck', engine="block"---------------
**_Learning check_**

## ---- fig.cap="Faceted barplot comparing the number of flights by carrier and airport", fig.height=7.5----
ggplot(data = flights_namedports, mapping = aes(x = carrier, fill = name)) +
  geom_bar() +
  facet_grid(name ~ .)

## ----lc-barplot-facet, type='learncheck', engine="block"-----------------
**_Learning check_**

## ----viz-map, echo=FALSE, fig.cap="Mind map for Data Visualization", out.width="200%"----
#library(knitr)
#if(knitr:::is_html_output()){
#  include_url("https://coggle.it/diagram/V_G2gzukTDoQ-aZt-", 
#              height = "1000px")
#} else {
  include_graphics("images/coggleviz.png", dpi = 300)
#}

## ----include=FALSE, eval=FALSE-------------------------------------------
## knitr::purl("04-viz.Rmd", "docs/scripts/04-viz.R")

