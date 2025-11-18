#!/bin/sh
# This bash script can be used for local builds
quarto render
Rscript -e "source('purl.R')"

