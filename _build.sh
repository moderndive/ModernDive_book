#!/bin/sh
# This bash script is run by .travis.yml
Rscript -e "bookdown::clean_book(TRUE); bookdown::render_book('index.Rmd', 'bookdown::gitbook');"
Rscript -e "source('purl.R')"

