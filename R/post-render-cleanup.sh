#!/usr/bin/env bash
# Quarto + macOS occasionally creates empty "<name> 2" directories in the
# output dir when its render pipeline races to create the same _files/
# directory twice. Cocoa's file API auto-suffixes the name instead of
# erroring, leaving empty duplicates behind. This script removes them.
set -euo pipefail
OUT="${QUARTO_PROJECT_OUTPUT_DIR:-docs}"
find "$OUT" -depth -type d -name "* 2" -empty -delete
