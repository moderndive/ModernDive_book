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

# Shared HTML-escape + inline-markdown helpers for standalone scripts.
# Many scripts emit YAML-sourced text (exercise prompts, learning objectives,
# coverage notes) directly into HTML; the YAML uses inline markdown
# (**bold**, *italic*, `code`), so we need to render it after escaping the
# surrounding string. Scripts that need different behaviour can shadow these
# with their own local definitions.
md_escape_html <- function(s) {
  s <- as.character(s %||% "")
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;",  s, fixed = TRUE)
  s <- gsub(">", "&gt;",  s, fixed = TRUE)
  s
}
md_inline_html <- function(s) {
  s <- md_escape_html(s)
  # Order: code → bold → italic.
  # `code` first: backticks shouldn't have their contents processed further.
  # Bold uses NON-GREEDY (.+?) so it stops at the next `**` — this allows
  #   `**outer *italic* outer**` to bold first, then italic in a second pass.
  #   A greedy `[^*]+` would fail because `*` appears INSIDE the bold span.
  # Italic then matches single-`*`-wrapped runs that aren't adjacent to
  #   another `*` (avoids re-matching the `*` chars that came from `**`).
  s <- gsub("`([^`]+)`", "<code>\\1</code>", s, perl = TRUE)
  s <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", s, perl = TRUE)
  s <- gsub("(^|[^*])\\*([^*\\n]+?)\\*(?!\\*)", "\\1<em>\\2</em>", s, perl = TRUE)
  s
}
# `%||%` mirror in case the sourcing script doesn't define it yet
if (!exists("%||%", mode = "function")) {
  `%||%` <- function(a, b) if (is.null(a) || identical(a, "")) b else a
}

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
    # Pagefind sitewide search — modal overlay triggered by the navbar
    # button. CSS/JS injected here so it's available on every standalone
    # page; the matching pagefind index is built in companion CI after
    # the site renders (`npx pagefind --site instructor-solutions/_site`).
    sprintf('<link rel="stylesheet" href="%spagefind/pagefind-ui.css">', prefix),
    sprintf('<script src="%spagefind/pagefind-ui.js" defer></script>', prefix),
    '<style>',
    '  .insthub-search-btn { background: rgba(255,255,255,0.12); color: #fff;',
    '    border: 1px solid rgba(255,255,255,0.25); border-radius: 4px;',
    '    padding: 0.35em 0.9em; cursor: pointer; font: inherit; font-size: 0.9em; }',
    '  .insthub-search-btn:hover { background: rgba(255,255,255,0.22); }',
    '  .insthub-search-modal { display: none; position: fixed; inset: 0;',
    '    background: rgba(31, 58, 107, 0.45); z-index: 2000; padding: 6vh 1em; }',
    '  .insthub-search-modal.open { display: block; }',
    '  .insthub-search-modal-inner { background: white; max-width: 780px;',
    '    margin: 0 auto; border-radius: 8px; box-shadow: 0 20px 60px rgba(0,0,0,0.3);',
    '    padding: 1.3em 1.3em 0.6em 1.3em; max-height: 80vh; overflow-y: auto; }',
    '  .insthub-search-close { float: right; background: none; border: 0;',
    '    color: #1F3A6B; font-size: 1.4em; cursor: pointer; line-height: 1; }',
    '  .insthub-search-close:hover { color: #1A6FBE; }',
    '  .pagefind-ui__search-input { border-radius: 4px !important; border-color: #C5D5E5 !important; }',
    '  .pagefind-ui__result-link { color: #1F3A6B !important; font-weight: 600; }',
    '  .pagefind-ui__result-link:hover { color: #1A6FBE !important; }',
    '  .pagefind-ui__message { color: #555; }',
    '</style>',
    '<div class="insthub-search-modal" id="insthub-search-modal" role="dialog" aria-label="Search instructor hub" aria-modal="true">',
    '  <div class="insthub-search-modal-inner">',
    '    <button class="insthub-search-close" aria-label="Close search" onclick="document.getElementById(&quot;insthub-search-modal&quot;).classList.remove(&quot;open&quot;)">&times;</button>',
    '    <div id="insthub-pagefind-search"></div>',
    '  </div>',
    '</div>',
    '<script>',
    '  // Wire up Pagefind UI once script loads + escape key closes modal.',
    '  window.addEventListener("DOMContentLoaded", function() {',
    '    if (typeof PagefindUI !== "undefined") {',
    '      new PagefindUI({ element: "#insthub-pagefind-search",',
    '        showSubResults: true, resetStyles: false,',
    '        translations: { placeholder: "Search the instructor hub..." } });',
    '    }',
    '    document.addEventListener("keydown", function(e) {',
    '      if (e.key === "Escape") {',
    '        document.getElementById("insthub-search-modal").classList.remove("open");',
    '      }',
    '    });',
    '  });',
    '</script>',
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
    sprintf('        <a href="%sposit-cloud.html">Posit Cloud template</a>', prefix),
    '      </div>',
    '    </div>',
    '    <div class="insthub-drop">',
    '      <button aria-haspopup="true">Teach</button>',
    '      <div class="insthub-menu">',
    sprintf('        <a href="%sslides/index.html">Slide decks</a>', prefix),
    sprintf('        <a href="%sfacilitator-notes/index.html">Facilitator notes</a>', prefix),
    sprintf('        <a href="%sactive-learning.html">Active-learning prompts</a>', prefix),
    sprintf('        <a href="%smisconceptions.html">Misconceptions</a>', prefix),
    sprintf('        <a href="%scommon-errors.html">Common R errors</a>', prefix),
    sprintf('        <a href="%sdiagrams.html">Teaching diagrams</a>', prefix),
    sprintf('        <a href="%sethics-scenarios.html">Ethics &amp; data scenarios</a>', prefix),
    sprintf('        <a href="%sta-guide.html">TA training packet</a>', prefix),
    '        <a href="https://moderndive.github.io/moderndive_labs/" target="_blank" rel="noopener">ModernDive Labs &rarr;</a>',
    '      </div>',
    '    </div>',
    '    <div class="insthub-drop">',
    '      <button aria-haspopup="true">Assess</button>',
    '      <div class="insthub-menu">',
    sprintf('        <a href="%shomework-planner.html">Homework planner</a>', prefix),
    sprintf('        <a href="%scoverage-map.html">Coverage map</a>', prefix),
    sprintf('        <a href="%ssolutions/index.html">Worked exercise solutions</a>', prefix),
    sprintf('        <a href="%srubrics.html">Rubrics library</a>', prefix),
    sprintf('        <a href="%sprojects.html">Project prompt bank</a>', prefix),
    sprintf('        <a href="%sexam-bank.html">Exam question bank</a>', prefix),
    sprintf('        <a href="%scumulative-review.html">Cumulative review</a>', prefix),
    sprintf('        <a href="%sflashcards.html">Flashcards (Anki/Quizlet)</a>', prefix),
    '      </div>',
    '    </div>',
    sprintf('    <a class="insthub-link" href="%sNEWS.html">What\'s new</a>', prefix),
    '    <div class="insthub-spacer"></div>',
    '    <div class="insthub-right">',
    '      <button class="insthub-search-btn" onclick="document.getElementById(&quot;insthub-search-modal&quot;).classList.add(&quot;open&quot;); setTimeout(function(){var i=document.querySelector(&quot;.pagefind-ui__search-input&quot;); if(i)i.focus();}, 100);" aria-label="Search the instructor hub" title="Search (Cmd/Ctrl-K)">&#128269; Search</button>',
    '      <a href="https://github.com/moderndive/ModernDive_book" target="_blank" rel="noopener" aria-label="ModernDive book on GitHub">GitHub</a>',
    '    </div>',
    '  </div>',
    '</nav>'
  ), collapse = "\n")
}
