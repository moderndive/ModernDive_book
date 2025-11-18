#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/webr-html-book"
git checkout -b "$BRANCH"

# Ensure _includes exists
mkdir -p _includes

# Add the webR setup include
install -m 0644 webr-setup.html _includes/webr-setup.html

# Update _output.yml to include the header include under bs4_book
# If an includes: block exists, this will not duplicate it. Adjust if your YAML differs.
if ! grep -q '_includes/webr-setup.html' _output.yml; then
  awk '
    BEGIN{printed=0}
    /bookdown::bs4_book:/ && !printed {
      print;
      print "  includes:";
      print "    in_header: \"_includes/webr-setup.html\"";
      printed=1; next
    }
    {print}
  ' _output.yml > _output.yml.tmp && mv _output.yml.tmp _output.yml
fi

git add _includes/webr-setup.html _output.yml
git commit -m "HTML: add webR support via header include and runnable code cells"

# Optional: add example blocks to two chapters (manual placement recommended)
echo 'See RMD_SNIPPET.md in the PR for a ready-to-paste `.webr` chunk.'

echo "Branch $BRANCH is ready. Push and open a PR:"
echo "  git push -u origin $BRANCH"
