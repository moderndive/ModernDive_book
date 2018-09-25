#!/bin/sh

Rscript -e "bookdown::clean_book(TRUE); bookdown::render_book('index.Rmd', 'bookdown::gitbook'); bookdown::render_book('index.Rmd', 'bookdown::pdf_book');"
Rscript -e "source('purl.R')"
