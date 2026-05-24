# Shared "back to instructor hub" navigation snippet.
#
# Every standalone HTML page in instructor-solutions/_site/ sources this
# helper and calls `hub_nav_html()` to drop a consistent top-of-page link
# back to index.html. Quarto-rendered pages (index.qmd, syllabus.qmd,
# slides/, facilitator-notes/) get the same look via the matching
# `_includes/hub-nav.html` include wired into instructor-solutions/_quarto.yml.
#
# `at_root = TRUE` is the default (links to `index.html`); set FALSE for
# pages that live one level deep (e.g., solutions/index.html → `../index.html`).

hub_nav_html <- function(at_root = TRUE) {
  href <- if (at_root) "index.html" else "../index.html"
  paste(c(
    # MathJax 3 — handles $…$ inline and $$…$$ display math. Defensive: the
    # script only does work when it finds math delimiters on the page, so it's
    # safe to load even on pages that don't use LaTeX. Configured for both
    # the "single dollar" inline convention and the "double-dollar" display
    # convention used across the book's exercises and solutions.
    '<script>',
    '  window.MathJax = {',
    '    tex: { inlineMath: [["$","$"], ["\\\\(","\\\\)"]], displayMath: [["$$","$$"], ["\\\\[","\\\\]"]] },',
    '    options: { skipHtmlTags: ["script","noscript","style","textarea","pre","code"] }',
    '  };',
    '</script>',
    '<script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js" async></script>',
    '<style>',
    '  .hub-nav { position: sticky; top: 0; z-index: 1000;',
    '             background: linear-gradient(180deg, #1F3A6B 0%, #1A6FBE 100%);',
    '             color: #fff; padding: 0.55em 1em;',
    '             font: 500 0.92em/1.3 -apple-system, system-ui, sans-serif;',
    '             box-shadow: 0 2px 6px rgba(0,0,0,0.1);',
    '             margin: -2em -1em 1.5em -1em; }',
    '  .hub-nav a { color: #fff; text-decoration: none; }',
    '  .hub-nav a:hover { text-decoration: underline; }',
    '  .hub-nav .hub-arrow { display: inline-block; margin-right: 0.3em; }',
    '  .hub-nav .hub-tag { background: rgba(255,255,255,0.18); padding: 0.1em 0.5em;',
    '                       border-radius: 3px; font-size: 0.82em;',
    '                       margin-left: 0.6em; letter-spacing: 0.04em; }',
    '  @media print { .hub-nav { display: none; } }',
    '</style>',
    sprintf('<nav class="hub-nav" aria-label="Hub navigation"><a href="%s"><span class="hub-arrow">&larr;</span> ModernDive instructor hub</a><span class="hub-tag">INSTRUCTOR</span></nav>',
            href)
  ), collapse = "\n")
}
