--[[
  Glossary auto-link filter.

  For each chapter rendered (except the glossary itself), scans prose and
  inserts a hyperlink to the matching glossary entry on the FIRST occurrence
  of each glossary term per chapter. Subsequent occurrences are left alone
  (avoids visual clutter and respects the principle that a reader who needs
  to look a term up will scroll to the top of the chapter to find the
  reference, not every appearance).

  Multi-word terms (e.g., "sampling distribution") are matched by walking
  consecutive Str/Space inlines whose concatenated text matches the term
  (case-insensitive). Single-word terms match a single Str.

  The term-to-anchor map is built at filter startup by parsing
  `96-glossary.qmd` for `## <Term> {#sec-gloss-<X>}` headings.

  Excluded contexts (term mentions here are NOT auto-linked):
    * Code spans / blocks
    * Already-linked text (an existing Link node containing the term)
    * Headings (h1/h2/h3) — a heading "Confidence interval" shouldn't link
      to its own glossary entry
    * Math
]]

local seen = {}            -- anchor -> true once we've linked it in this doc
local term_to_anchor = nil -- lowercased term -> "sec-gloss-X"
local term_keys = nil      -- sorted longest-first so multi-word wins over partial
local in_heading = false   -- skip while walking inside Headers
local anchor_to_def = {}   -- "sec-gloss-X" -> plain-text definition (popover body)
local anchor_to_title = {} -- "sec-gloss-X" -> display term (popover header)

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- Reduce a glossary definition paragraph to popover-friendly plain text:
-- drop the trailing "See @sec-..." cross-ref, any inline @sec refs, code
-- backticks and *italic* markers; rewrite $math$ to MathJax's default
-- \(math\) inline delimiters (Quarto's MathJax only listens for \(\), not
-- $...$) so the popover JS can re-typeset it; collapse whitespace.
local function clean_def(s)
  s = s:gsub("%s*See @sec[%w%-]+%s*%.%s*$", "")  -- trailing "See @sec-foo."
  s = s:gsub("@sec[%w%-]+", "")                   -- any other cross-ref token
  s = s:gsub("`", "")                              -- inline code backticks
  s = s:gsub("%*", "")                             -- *italic* markers
  s = s:gsub("%$(.-)%$", "\\(%1\\)")              -- $math$ -> \(math\)
  s = s:gsub("%s+", " ")
  return trim(s)
end

local function load_glossary()
  if term_to_anchor then return end
  term_to_anchor = {}
  -- Look for the glossary in the project root (where Quarto runs).
  local f = io.open("96-glossary.qmd", "r")
  if not f then return end
  local pending_anchor = nil  -- anchor awaiting its definition paragraph
  for line in f:lines() do
    local term, anchor = line:match("^##%s+(.-)%s*{#(sec%-gloss%-[a-zA-Z0-9%-]+)")
    if term and anchor then
      local display = trim(term:gsub("`", ""))  -- popover header (keep case)
      term = display:gsub("%s*%(.-%)$", "")     -- drop trailing "(...)" qualifier
      term = trim(term):lower()
      -- Skip very short terms to avoid false positives (e.g. "n").
      if #term >= 3 then
        term_to_anchor[term] = anchor
        anchor_to_title[anchor] = display
        pending_anchor = anchor                 -- next prose line is its def
      else
        pending_anchor = nil
      end
    elseif pending_anchor and trim(line) ~= "" then
      -- First non-empty line after the heading is the definition paragraph.
      anchor_to_def[pending_anchor] = clean_def(line)
      pending_anchor = nil
    end
  end
  f:close()

  -- Sort terms longest-first so "sampling distribution" wins over "sampling"
  -- when both could match at the same position.
  term_keys = {}
  for k, _ in pairs(term_to_anchor) do table.insert(term_keys, k) end
  table.sort(term_keys, function(a, b) return #a > #b end)
end

-- Reads the concatenated lowercase text of a span of inlines starting at
-- index `start`. Returns the text and the count of inlines walked. Stops
-- when a Code / Link / Math / Strong / Emph / non-Str/Space inline is hit
-- (we don't want to link across formatting boundaries).
local function span_text(inlines, start, max_chars)
  local out = {}
  local n = 0
  for i = start, #inlines do
    local x = inlines[i]
    if x.tag == "Str" then
      table.insert(out, x.text:lower())
      n = n + 1
    elseif x.tag == "Space" or x.tag == "SoftBreak" then
      table.insert(out, " ")
      n = n + 1
    else
      break  -- end of plain-text span
    end
    local joined = table.concat(out)
    if max_chars and #joined > max_chars then return joined, n end
  end
  return table.concat(out), n
end

-- Given inlines and starting index `start`, check whether any glossary
-- term matches as a prefix (followed by a word boundary). Returns the
-- matching term and number of inlines consumed, or nil.
local function match_term_at(inlines, start)
  -- Find the longest contiguous text span starting at `start`
  local max_term_len = 0
  for _, k in ipairs(term_keys) do max_term_len = math.max(max_term_len, #k) end
  local text, _ = span_text(inlines, start, max_term_len + 1)
  if #text == 0 then return nil end

  for _, term in ipairs(term_keys) do
    if text:sub(1, #term) == term then
      -- Word boundary check: the char *after* the term must be non-word
      -- (end of span, space, or punctuation).
      local nextc = text:sub(#term + 1, #term + 1)
      if nextc == "" or nextc:match("[%s%p]") then
        -- Word boundary BEFORE the term: also enforce. Caller advances
        -- index past Space/SoftBreak boundaries, so we just need to ensure
        -- the start element is a Str (not mid-word continuation).
        if inlines[start].tag == "Str" then
          -- Count inlines that compose the matched text.
          local need = #term
          local consumed_chars = 0
          local n = 0
          for i = start, #inlines do
            local x = inlines[i]
            local len
            if x.tag == "Str" then len = #x.text
            elseif x.tag == "Space" or x.tag == "SoftBreak" then len = 1
            else break
            end
            consumed_chars = consumed_chars + len
            n = n + 1
            if consumed_chars >= need then
              -- Last consumed Inline must NOT split a Str mid-word; if it
              -- does, the match is invalid (e.g., "samplings" matching
              -- "sampling" at the boundary of a single Str).
              if x.tag == "Str" then
                local needed_from_this = need - (consumed_chars - len)
                if needed_from_this < len then
                  -- The Str has more chars than the term needs from it.
                  -- That's fine only if the leftover starts with a word
                  -- boundary.
                  local leftover = x.text:sub(needed_from_this + 1, needed_from_this + 1):lower()
                  if leftover ~= "" and not leftover:match("[%s%p]") then
                    return nil  -- mid-word, reject
                  end
                end
              end
              return term, n
            end
          end
        end
      end
    end
  end
  return nil
end

-- Build the glossary Link, attaching Bootstrap popover attributes so the
-- definition shows as a hover/focus bubble. Popovers are initialised in
-- _includes/glossary-popover.html. The href still jumps to the full entry.
local function make_gloss_link(content, anchor)
  local attrs = { class = "glossary-term" }
  local def = anchor_to_def[anchor]
  if def and def ~= "" then
    attrs["data-bs-toggle"]       = "popover"
    attrs["data-bs-trigger"]      = "hover focus"
    attrs["data-bs-placement"]    = "top"
    attrs["data-bs-html"]         = "false"
    attrs["data-bs-custom-class"] = "glossary-popover"
    attrs["data-bs-title"]        = anchor_to_title[anchor] or ""
    attrs["data-bs-content"]      = def
    attrs["tabindex"]             = "0"
  end
  return pandoc.Link(content, "#" .. anchor, "", attrs)
end

-- Walk an Inlines list and emit a new list where the FIRST occurrence
-- of each unseen glossary term is wrapped in a Link to its glossary entry.
local function process_inlines(inlines)
  if in_heading then return nil end
  local out = pandoc.List()
  local i = 1
  while i <= #inlines do
    local x = inlines[i]
    -- Skip elements where we shouldn't auto-link
    if x.tag == "Code" or x.tag == "Math" or x.tag == "Link" or x.tag == "Strong" or x.tag == "Emph" then
      out:insert(x)
      i = i + 1
    else
      local term, n_consumed = match_term_at(inlines, i)
      if term and not seen[term_to_anchor[term]] then
        seen[term_to_anchor[term]] = true
        -- Pull the matched inlines into a sublist
        local matched = pandoc.List()
        for k = 0, n_consumed - 1 do matched:insert(inlines[i + k]) end
        -- But the matched span may overflow the term (last Str had extra
        -- chars). Trim the last Str if so.
        local total = 0
        for _, m in ipairs(matched) do
          if m.tag == "Str" then total = total + #m.text
          elseif m.tag == "Space" or m.tag == "SoftBreak" then total = total + 1
          end
        end
        if total > #term then
          local extra = total - #term
          local last = matched[#matched]
          if last.tag == "Str" then
            -- Split last Str: first part goes into matched, rest stays outside
            local keep = last.text:sub(1, #last.text - extra)
            local leftover = last.text:sub(#last.text - extra + 1)
            matched[#matched] = pandoc.Str(keep)
            out:insert(make_gloss_link(matched, term_to_anchor[term]))
            out:insert(pandoc.Str(leftover))
            i = i + n_consumed
            goto continue
          end
        end
        out:insert(make_gloss_link(matched, term_to_anchor[term]))
        i = i + n_consumed
      else
        out:insert(x)
        i = i + 1
      end
    end
    ::continue::
  end
  return out
end

function Pandoc(doc)
  load_glossary()
  if not term_to_anchor or not next(term_to_anchor) then return doc end

  -- Don't auto-link inside the glossary chapter itself.
  local title = doc.meta.title and pandoc.utils.stringify(doc.meta.title) or ""
  if title:lower():find("glossary") then return doc end

  -- Reset per-document state
  seen = {}

  doc.blocks = doc.blocks:walk{
    -- Skip headers (don't auto-link a section title to a glossary entry)
    Header = function(h)
      in_heading = true
      local out = h
      in_heading = false
      return out
    end,
    -- Don't auto-link inside callouts whose title looks like an alert
    -- (Warning / Important / Common mistake) — those are emphasis blocks.
    Para = function(p)
      local result = process_inlines(p.content)
      if result then p.content = result end
      return p
    end,
    Plain = function(p)
      local result = process_inlines(p.content)
      if result then p.content = result end
      return p
    end
  }
  return doc
end
