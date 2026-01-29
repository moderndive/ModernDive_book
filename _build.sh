#!/bin/sh
# This bash script builds the Quarto book
quarto render
Rscript -e "source('purl.R')"

