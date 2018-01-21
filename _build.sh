#!/bin/sh

Rscript -e "bookdown::clean_book(TRUE); bookdown::render_book('index.Rmd', 'bookdown::gitbook')"   
Rscript -e "source('purl.R')"