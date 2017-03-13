# ModernDive

Welcome to the development version of the book **ModernDive: An Introduction to
Statistical and Data Sciences** available at <http://www.moderndive.com/>. This
book is generated via the
[bookdown](https://www.rstudio.com/resources/webinars/introducing-bookdown/)
package from RStudio. For information on using `bookdown`, see
<https://bookdown.org/>.


## Contents of this Repository

This repository contains :

* Development version of book
    + Source code here.
* Current/live version of the book on <http://www.moderndive.com/>
    + Book output in `docs` folder.
    + Source code is available by clicking on the "release" tab above. 


## A Work in Progress

This book is in constant evolution: below are many items to be addressed in the
future to improve on the book. 

### To-do

- Change colors of Learning check/Review Question blocks as needed
    + Need to match colors in preamble.tex too
- See if way to automate numbering of Learning check questions
    + (Hacky way with R variable counting right now)
    + Currently an issue with https://github.com/rstudio/bookdown/issues/152
    + Need to specify both CSS and LaTeX environment code for custom blocks
- Remove hard-coding whenever possible
- Add captions and labels to all plots
- Look into appropriate license (LICENSE file)


### Notes

- Chunk options with figures shouldn't have `_` or `-` in them
    + Gives an error when Knitting to PDF since LaTeX is looking for `$`

### Down the road

- Parameterize the chapters so that other examples could be plugged in easily
   + Will need to set up `ifelse` conditions for the text to make sense in some spots
- Add `tufte_book` download format but in `gitbook` format
- Include discussion on ethics of various datasets
