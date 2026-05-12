/* ModernDive slide-deck MCQ helpers.
 *
 * Adds three behaviours to revealjs decks:
 *
 *  1. Click an option in a `.mcq` block: highlights as the participant's
 *     selection (no judgement) — supports calling on students without
 *     them needing to commit publicly.
 *  2. "Show poll" button: pretends to record audience votes by tracking
 *     local clicks (per slide) and rendering bar widths. Designed for
 *     small classrooms; for real polling, instructors swap in their own
 *     tool (Poll Everywhere, Slido, Mentimeter) — the slide already
 *     supports the pattern.
 *  3. "Show answer" button: reveals the .mcq-reveal block and highlights
 *     the correct option.
 *
 * Learning-sciences motivation: brief, low-stakes retrieval at frequent
 * intervals deepens encoding (testing effect). The reveal-after-prediction
 * pattern mirrors the "predict, then check" cycle that Brown, Roediger,
 * & McDaniel summarise as the most effective form of in-class practice.
 */

(function () {
  function setup() {
    document.querySelectorAll('.mcq').forEach(function (block) {
      var correct = block.getAttribute('data-correct') || '';
      var options = block.querySelectorAll('ol.mcq-options li');
      var votes = new Array(options.length).fill(0);

      options.forEach(function (li, idx) {
        li.addEventListener('click', function () {
          votes[idx] += 1;
          options.forEach(function (other) { other.classList.remove('selected'); });
          li.classList.add('selected');
        });
      });

      var reveal = block.querySelector('.mcq-reveal');
      var showAnsBtn = block.querySelector('.show-answer');
      if (showAnsBtn && reveal) {
        showAnsBtn.addEventListener('click', function () {
          reveal.classList.add('shown');
          // Highlight correct + incorrect options
          options.forEach(function (li, idx) {
            var letter = String.fromCharCode(97 + idx);
            if (letter === correct.toLowerCase()) li.classList.add('correct');
            else if (li.classList.contains('selected')) li.classList.add('incorrect');
          });
        });
      }

      var poll = block.querySelector('.poll-bar');
      var showPollBtn = block.querySelector('.show-poll');
      if (showPollBtn && poll) {
        showPollBtn.addEventListener('click', function () {
          var total = votes.reduce(function (a, b) { return a + b; }, 0);
          if (total === 0) { poll.innerHTML = '<em>No clicks yet — invite students to tap their answer.</em>'; }
          else {
            poll.innerHTML = votes.map(function (v, i) {
              var pct = Math.round((v / total) * 100);
              var letter = String.fromCharCode(97 + i);
              return '<div>(' + letter + ') <span class="bar" style="width:' + (pct * 2) + 'px"></span> ' + pct + '% <small>(' + v + ')</small></div>';
            }).join('');
          }
          poll.classList.add('shown');
        });
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setup);
  } else { setup(); }
})();
