-- Lua filter to convert bookdown block types to Quarto callouts
-- This handles ```{block, type="learncheck"} and similar constructs

function Div(el)
  -- Handle divs with class "learncheck"
  if el.classes:includes("learncheck") then
    -- Create a callout-tip block
    el.classes = pandoc.List({"callout-tip"})
    el.attributes["title"] = "Learning Check"
    return el
  end
  
  -- Handle divs with class "announcement"
  if el.classes:includes("announcement") then
    el.classes = pandoc.List({"callout-warning"})
    el.attributes["title"] = "Announcement"
    return el
  end
  
  -- Handle divs with class "review"
  if el.classes:includes("review") then
    el.classes = pandoc.List({"callout-note"})
    el.attributes["title"] = "Review"
    return el
  end
  
  return el
end
