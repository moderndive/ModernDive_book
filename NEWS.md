# ModernDive 0.3.0.9000

- Updated links to free DataCamp course in Visualization and Data Wrangling chapters

# ModernDive 0.3.0

## Content changes

* Reorganized chapter sequencing according to flowchart at top of [Section 1.1](http://moderndive.com/index.html#intro-for-students)
* Chapter 2 - Getting Started: Added more explanation on R packages, including analogy for `install.packages()` and `library()` (akin to downloading apps onto phone)
* Added "Data Modeling" portion to book
    + Chapter 6 - Basic regression: one numerical explanatory variable, correlation, one categorical explanatory variable)
    + Chapter 7 - Multiple regression: two numerical explanatory variables, one numerical and one categorical, interaction effects, Simpson's Paradox
    + Uses new [`moderndive`](https://moderndive.github.io/moderndive/) package, which includes `get_regression_table()` and `get_regression_points()` wrapper functions to simplify outputing of clean regression tables and observed/fitted values + resisuals
* Added "statistical inference" portion to book
    + Added Chapter 8 - Sampling (still under construction) using [sampling bowl](https://github.com/moderndive/moderndive/blob/master/data-raw/sampling_bowl.jpeg)
    + Chapters 9 and 10 on confidence intervals and hypothesis testing have not yet been updated, as we were awaiting the now launched package: [`infer`: A tidyverse-friendly R package fo statistical inference](https://github.com/andrewpbray/infer)
    + Added Chapter 11 - Inference for regression (still under construction), where we'll revisit the regression models fit in Chapters 6 & 7


## Other changes

- Development version of book now available at <http://moderndive.netlify.com/>; deployed via travis-ci + netlify. 
- Added wide ModernDive logo to top of each chapter and `logos` folder
- Added favicon (icon in browser tab)
- Moved home GitHub repository from <https://github.com/ismayc/moderndiver-book/> to <https://github.com/moderndive/moderndive_book>



# ModernDive 0.2.0

## Content changes

* Incorporated feedback from consultations with Prof. Yana Weinstein, cognitive psychological scientist and co-founder of [The Learning Scientists](http://www.learningscientists.org/yana-weinstein/).
* Restructured/revamped chapters
    + **Chapter 1: Introduction**
        + Friendlier introduction targetted to students is first thing users see. Followed then by introduction  for instructors, ways to connect/contribute, and technical details.
        + Added links to example student projects from two courses that have previously used ModernDive:
            + Middlebury College [MATH 116 Introduction to Statistical and Data Sciences](https://rudeboybert.github.io/MATH116/PS/final_project/final_project_outline.html#past_examples) using student collected data.
            + Pacific University [SOC 301 Social Statistics](https://ismayc.github.io/soc301_s2017/group-projects/index.html) using data from the [fivethirtyeight R package](https://cran.r-project.org/web/packages/fivethirtyeight/vignettes/fivethirtyeight.html)
    + **Chapter 2: Getting Started** New chapter added meant for new R users/coders, including
        + Discusions on R vs RStudio and how to install both (with support videos)
        + A "How do I code in R?" section with links to [DataCamp.com](https://www.datacamp.com/) courses that covers the console, data types, vectors, factors, data frames, boolean operators, functions etc
        + Thorough discussion on R packages
        + An end-to-end starter example analysis of the data frames in the `nycflights13` package using the console, `View()`, `glimpse()` etc.
    + **Chapter 3: Data Visualization via `ggplot2`** now first non-intro chapter.
        + Replaced Menard's "Napolean's March on Moscow" with Hans Rosling's (RIP) "Gapminder" plots as introductory example to Grammar of Graphics.
        + Added `geom_col()` for making barcharts when data is pre-tabulated, instead of using `geom_bar(stat="identity")` 
    + **Chapter 4: Tidy Data via `tidyr`** bumped back. Added sections on converting from wide to long/tidy format and importing CSV's
    + **Chapter 5: Data ~~Manipulation~~ Wrangling via `dplyr`**
    + **Chapter 6: Data Modeling using Regression via `broom`** bumped up from end of book to here given its pedagogical importance, added notes on viewing regression in a prediction framework.
    + **Chapter 7-9: Sampling, Hypothesis Testing, Confidence Intervals** Mostly unchanged for now; see pending changes section below.

## Technical changes

* Book is now hosted on [ModernDive.com](http://moderndive.com/)
* Development version now on original ModernDive site [https://ismayc.github.io/moderndiver-book/](https://ismayc.github.io/moderndiver-book/)
* Added links to digital copies and source code of all past versions of ModernDive in Chapter 1.
* Cut build/compilation time of book from ~20 minutes to ~1 minute
* Disabled gitbook PDF output

## Pending changes for next version

* **Chapter 6: Data Modeling using Regression via `broom`**
    + Better treatment of experimental design and its effect on bias/causation than currently exists in chapter.
    + Examples of regression with categorical predictors with 3 or more levels.
    + Multivariate regression, in particular the following predictor scenarios: 2 numerical, 2 categorical, and 1 numerical + 1 categorical
    + Interaction effects
* **Chapter 7-9: Sampling, Hypothesis Testing, Confidence Intervals** have largely not been updated, pending developments of [`infer`: A tidyverse-friendly R package fo statistical inference](https://github.com/andrewpbray/infer)



# ModernDive 0.1.3

* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/moderndive/moderndive_book/issues/2)
    * Reverted to using screenshot with link instead
* Updated link to `dplyr` [cheatsheet](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/data-transformation-cheatsheet.pdf) and `ggplot2` [cheatsheet](https://www.rstudio.com/wp-content/uploads/2016/11/ggplot2-cheatsheet-2.1.pdf)
* Began adding DataCamp chapters as Review Questions to the end of Chapters 3 and 4 (More to come)
* Updated link to MailChimp
* Fixed wording in a few Ch 3 Learning Checks



# ModernDive 0.1.2

* Converted last updated in index.Rmd to inline instead of R chunk
* Fixed edit link to point to moderndive-book GitHub repo instead of moderndive-source repo
* Fixed broken links to script files at the end of Chapters 4-9
* Added `purl=FALSE` to chunks that do not contain useful code to the reader
* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/moderndive/moderndive_book/issues/2)



# ModernDive 0.1.1

* Fixed the problems of chapter cross-references not working by removing the backticks in chapter names
    + Issue created on `bookdown` [here](https://github.com/rstudio/bookdown/issues/294)
* Looked for typos throughout all chapters
* Added coggle diagrams to Chapter 4 and Appendix B
* Followed the same format of having a Conclusion section at the end of each chapter
* Fixed $T$ distribution plot with histogram in Chapter 7
    + May be weird issue with `cache = TRUE` that incorrectly plotted values on 1/10^th^ the correct scale
    + Will need to keep an eye on it going forward
* Fixed typo on Reach for the Stars chapter name



# ModernDive 0.1.0

* Fiat Lux!
* Basic chapter structure in place
* First pass at II Inference section (Chapters 6-9) complete
* First revisions of I Data Exploration (Chapters 3-5) nearly complete
