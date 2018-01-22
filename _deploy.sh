#!/bin/sh
# This file is not used!
git config --global user.email "chester.ismay@gmail.com"
git config --global user.name "Chester Ismay"

git clone -b master https://${GITHUB_PAT}@github.com/${TRAVIS_REPO_SLUG}.git travis-ci_book
cd travis-ci_book
cp -r ../docs/* ./
git add --all *
git commit -m"Update the book via travis" || true
git push -q origin master
