--[[
  Inject ARIA landmark attributes onto our custom callout divs
  (`.learncheck`, `.announcement`, `.review`).

  Quarto's built-in callouts (`callout-note`, `callout-tip`, etc.) already
  emit accessible markup with role + aria-label. Our custom CSS-classed
  callouts don't get the same treatment, so this filter adds:

    role="region"
    aria-label="<descriptive>"

  to each so screen readers expose them as landmarks.
]]

local LABELS = {
  ["learncheck"]   = "Learning check",
  ["announcement"] = "Announcement",
  ["review"]       = "Review"
}

function Div(el)
  for class, label in pairs(LABELS) do
    if el.classes:includes(class) then
      el.attributes["role"] = el.attributes["role"] or "region"
      el.attributes["aria-label"] = el.attributes["aria-label"] or label
      return el
    end
  end
  return el
end
