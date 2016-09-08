## To-do

- Change colors of Learning check/Review Question blocks as needed
    + Need to match colors in preamble.tex too
- See if way to automate numbering of Learning check questions
    + (Hacky way with R variable counting right now)
    + Currently an issue with https://github.com/rstudio/bookdown/issues/152
    + Need to specify both CSS and LaTeX environment code for custom blocks
- Remove hard-coding whenever possible
- Add captions and labels to all plots
- Look into appropriate license (LICENSE file)
- Need to tweak tufte template for title
    + No paragraph indent and a new line between paragraphs in pdf_book to match with
  gitbook

## Notes

- Chunk options with figures shouldn't have `_` or `-` in them
    + Gives an error when Knitting to PDF since LaTeX is looking for `$`

### Down the road

- Parameterize the chapters so that other examples could be plugged in easily
   + Will need to set up `ifelse` conditions for the text to make sense in some spots
- Add `tufte_book` download format but in `gitbook` format
- Include discussion on ethics of various datasets

