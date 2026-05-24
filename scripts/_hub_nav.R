# Shared instructor-hub navbar for R-generated standalone HTML pages.
#
# Mirrors the Quarto-website navbar defined in instructor-solutions/_quarto.yml
# (Plan / Teach / Assess dropdowns) so the R-generated pages
# (concept-map, assessment-matrix, misconceptions, exam-bank,
# pacing-calculator, cumulative-review, homework-planner, lesson-plans,
# coverage-map) get the same top-of-page navigation as the Quarto-rendered
# pages (index, NEWS, solutions, syllabus, slides, facilitator-notes).
#
# Every script under scripts/build_*.R + exercise_coverage_map.R sources
# this helper and emits hub_nav_html() right after <body>. The function
# also loads MathJax 3 for inline / display math rendering.
#
# When the website navbar changes in _quarto.yml, mirror the same edits
# here. Keep the two in sync.
#
# `at_root = TRUE` (default) for pages at instructor-solutions/_site/ root;
# set FALSE for pages one directory deep (the script flips hrefs to ../).

hub_nav_html <- function(at_root = TRUE) {
  prefix <- if (at_root) "" else "../"
  paste(c(
    # MathJax 3 — handles $…$ inline and $$…$$ display math. Safe to load
    # even on pages without math; only activates when delimiters appear.
    '<script>',
    '  window.MathJax = {',
    '    tex: { inlineMath: [["$","$"], ["\\\\(","\\\\)"]], displayMath: [["$$","$$"], ["\\\\[","\\\\]"]] },',
    '    options: { skipHtmlTags: ["script","noscript","style","textarea","pre","code"] }',
    '  };',
    '</script>',
    '<script src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js" async></script>',
    '<style>',
    '  /* Match Quarto cosmo navbar styling, themed in ModernDive navy */',
    '  .insthub-nav { background: #1F3A6B; color: #fff;',
    '                 font: 500 0.92em/1.4 -apple-system, system-ui, BlinkMacSystemFont, sans-serif;',
    '                 box-shadow: 0 2px 6px rgba(0,0,0,0.12);',
    '                 position: sticky; top: 0; z-index: 1050;',
    '                 margin: -2em -1em 1.5em -1em; }',
    '  .insthub-nav-inner { max-width: 1320px; margin: 0 auto; padding: 0.55em 1.2em;',
    '                       display: flex; align-items: center; flex-wrap: wrap; gap: 0.2em; }',
    '  .insthub-brand { font-weight: 700; margin-right: 1em; color: #fff; text-decoration: none;',
    '                   letter-spacing: 0.02em; }',
    '  .insthub-brand:hover { color: #cfe1f5; }',
    '  .insthub-link, .insthub-drop > button { color: #fff; text-decoration: none;',
    '                       padding: 0.35em 0.75em; border-radius: 4px;',
    '                       background: transparent; border: 0; cursor: pointer; font: inherit; }',
    '  .insthub-link:hover, .insthub-drop > button:hover { background: rgba(255,255,255,0.12); }',
    '  .insthub-drop { position: relative; display: inline-block; }',
    '  .insthub-drop > button::after { content: " \\25BE"; opacity: 0.7; }',
    '  .insthub-menu { display: none; position: absolute; top: 100%; left: 0;',
    '                  background: #fff; color: #1F3A6B; min-width: 230px;',
    '                  box-shadow: 0 4px 16px rgba(0,0,0,0.16); border-radius: 4px;',
    '                  padding: 0.35em 0; margin-top: 0.25em; z-index: 1100; }',
    '  .insthub-drop:hover .insthub-menu, .insthub-drop:focus-within .insthub-menu { display: block; }',
    '  .insthub-menu a { display: block; padding: 0.5em 1em; color: #1F3A6B; text-decoration: none;',
    '                    font-size: 0.95em; }',
    '  .insthub-menu a:hover { background: #F0F4F8; color: #1A6FBE; }',
    '  .insthub-spacer { flex: 1; }',
    '  .insthub-right a { color: #fff; opacity: 0.85; padding: 0.35em 0.75em;',
    '                     text-decoration: none; }',
    '  .insthub-right a:hover { opacity: 1; }',
    '  @media print { .insthub-nav { display: none; } }',
    '  @media (max-width: 720px) {',
    '    .insthub-nav-inner { padding: 0.4em 0.6em; }',
    '    .insthub-link, .insthub-drop > button { padding: 0.3em 0.5em; font-size: 0.88em; }',
    '  }',
    '</style>',
    '<nav class="insthub-nav" aria-label="Instructor hub navigation">',
    '  <div class="insthub-nav-inner">',
    sprintf('    <a class="insthub-brand" href="%sindex.html">ModernDive &mdash; Instructor</a>', prefix),
    sprintf('    <a class="insthub-link" href="%sindex.html">Hub</a>', prefix),
    '    <div class="insthub-drop">',
    '      <button aria-haspopup="true">Plan</button>',
    '      <div class="insthub-menu">',
    sprintf('        <a href="%ssyllabus.html">Sample syllabus</a>', prefix),
    sprintf('        <a href="%slesson-plans.html">Lesson plans</a>', prefix),
    sprintf('        <a href="%sconcept-map.html">Concept map</a>', prefix),
    sprintf('        <a href="%spacing-calculator.html">Pacing calculator</a>', prefix),
    sprintf('        <a href="%sassessment-matrix.html">Assessment alignment</a>', prefix),
    '      </div>',
    '    </div>',
    '    <div class="insthub-drop">',
    '      <button aria-haspopup="true">Teach</button>',
    '      <div class="insthub-menu">',
    sprintf('        <a href="%sslides/index.html">Slide decks</a>', prefix),
    sprintf('        <a href="%sfacilitator-notes/index.html">Facilitator notes</a>', prefix),
    sprintf('        <a href="%smisconceptions.html">Misconceptions</a>', prefix),
    '        <a href="https://moderndive.github.io/moderndive_labs/" target="_blank" rel="noopener">ModernDive Labs &rarr;</a>',
    '      </div>',
    '    </div>',
    '    <div class="insthub-drop">',
    '      <button aria-haspopup="true">Assess</button>',
    '      <div class="insthub-menu">',
    sprintf('        <a href="%shomework-planner.html">Homework planner</a>', prefix),
    sprintf('        <a href="%scoverage-map.html">Coverage map</a>', prefix),
    sprintf('        <a href="%ssolutions/index.html">Worked solutions</a>', prefix),
    sprintf('        <a href="%sexam-bank.html">Exam question bank</a>', prefix),
    sprintf('        <a href="%scumulative-review.html">Cumulative review</a>', prefix),
    '      </div>',
    '    </div>',
    sprintf('    <a class="insthub-link" href="%sNEWS.html">What\'s new</a>', prefix),
    '    <div class="insthub-spacer"></div>',
    '    <div class="insthub-right">',
    '      <a href="https://github.com/moderndive/ModernDive_book" target="_blank" rel="noopener" aria-label="ModernDive book on GitHub">GitHub</a>',
    '    </div>',
    '  </div>',
    '</nav>'
  ), collapse = "\n")
}
