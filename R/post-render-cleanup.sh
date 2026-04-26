#!/usr/bin/env bash
# Two cleanups Quarto's render leaves behind that we don't want committed:
#  1. Empty "<name> 2" directories in the output dir, created by macOS's
#     Cocoa file API when Quarto's render races on _files/ creation.
#  2. A bare /.quarto/ line that Quarto re-appends to .gitignore each
#     render — it overrides our `!/.quarto/_freeze/` un-ignore which
#     keeps the freeze cache committed.
set -euo pipefail
OUT="${QUARTO_PROJECT_OUTPUT_DIR:-docs}"
find "$OUT" -depth -type d -name "* 2" -empty -delete

# Strip a trailing bare /.quarto/ line if present (Quarto re-adds this on
# every render, undoing our gitignore tuning that keeps _freeze tracked).
if [ -f .gitignore ] && grep -qE '^/\.quarto/$' .gitignore; then
  awk 'BEGIN{p=0} /^\/\.quarto\/$/{next} {print}' .gitignore > .gitignore.tmp \
    && mv .gitignore.tmp .gitignore
fi
