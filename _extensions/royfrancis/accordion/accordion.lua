-- Author: Roy Francis

-- Add html dependencies
local function addHTMLDeps()
  -- add the HTML requirements for the Bootstrap accordion
  quarto.doc.add_html_dependency({
    name = 'accordion',
    stylesheets = {'accordion.css'}
  })
end

-- Check if empty or nil
local function isEmpty(s)
  return s == '' or s == nil
end

-- Sanitize and get strings
local function sanitizeStrings(headerContent, bodyContent)
   -- checking if headerContent and bodyContent are not nil
  if headerContent == nil or bodyContent == nil then
    return nil
  end

  -- sanitize the last 10 characters of the headerContent and bodyContent
  local id_hc = string.gsub(string.lower(string.sub(headerContent, -10)), "[^%w]", "")
  local id_bc = string.gsub(string.lower(string.sub(bodyContent, -10)), "[^%w]", "")
  local id = id_hc .. id_bc
  return id
end

-- Create unique accordion Id
local function generateId(accordionId, headerContent, bodyContent, item)
  -- check if id is provided in yaml
  if item.id ~= nil then
    return "-" .. accordionId .. "-" .. pandoc.utils.stringify(item.id)
  else
    local id = sanitizeStrings(headerContent, bodyContent)
    
    -- if the id is empty or nil, generate a random id
    if id == nil or id == "" then
      id = ""
      local charset = {}  do -- [0-9a-z]
        for c = 48, 57  do table.insert(charset, string.char(c)) end
        for c = 97, 122 do table.insert(charset, string.char(c)) end
      end
      for i = 1, 10 do
        id = id .. charset[math.random(1, #charset)]
      end
    end
    
    -- return the id prefixed with the accordion id and a hyphen
    return "-" .. accordionId .. "-" .. id
  end
end


-- Main Accordion Function Shortcode
return {

["accordion"] = function(args, kwargs, meta)
  
  if quarto.doc.is_format("html:js") then
    addHTMLDeps()

    local accordionId = args[1]
    local accordion_items = meta["accordion"]

    for i = 1, #accordion_items do
        if next(accordion_items[i]) == accordionId then
            accordion_items = accordion_items[i][accordionId]
            break
        end
    end

    local accordion_start = "<div id = \"" .. accordionId .. "\" class = \"accordion quarto-accordion\">\n"
    local accordion_end = "</div>\n"
  
    for i = 1, #accordion_items do
      
      local item = accordion_items[i]

      local headerContent = pandoc.utils.stringify(item.header)
      local bodyContent = pandoc.utils.stringify(item.body)
      local collapseId = generateId(accordionId, headerContent, bodyContent, item)
      
      local collapsed = item.collapsed
      if collapsed == nil then
        collapsed = true
      end

      local collapseClass = collapsed and "collapsed" or ""
      local collapseAria = collapsed and "false" or "true"
      local collapseShow = collapsed and "" or " show"

      accordion_start = accordion_start .. "<div class=\"accordion-item\">\n"
      accordion_start = accordion_start .. "<div class=\"accordion-header\" id=\"heading" .. collapseId .. "\">\n"
      accordion_start = accordion_start .. "<button class=\"accordion-button " .. collapseClass .. "\" type=\"button\" data-bs-toggle=\"collapse\" data-bs-target=\"#collapse" .. collapseId .. "\" aria-expanded=\"" .. collapseAria .. "\" aria-controls=\"collapse" .. collapseId .. "\">\n"
      accordion_start = accordion_start .. "<div class=\"accordion-header-content\"\n>"
      accordion_start = accordion_start .. headerContent
      accordion_start = accordion_start .. "</div>"
      accordion_start = accordion_start .. "</button>\n</div>\n"
      accordion_start = accordion_start .. "<div id=\"collapse" .. collapseId .. "\" class=\"accordion-collapse collapse" .. collapseShow .. "\" aria-labelledby=\"heading" .. collapseId .. "\" data-bs-parent=\"" .. accordionId .. "\">\n"
      accordion_start = accordion_start .. "<div class=\"accordion-body\">\n"
      accordion_start = accordion_start .. "<div class=\"accordion-body-content\"\n>"
      accordion_start = accordion_start .. bodyContent
      accordion_start = accordion_start .. "</div>"
      accordion_start = accordion_start .. "</div>\n</div>\n</div>\n"
      
    end

    accordion_start = accordion_start .. accordion_end
    return pandoc.RawInline("html", accordion_start)

  else
    print("Warning: Accordions are disabled because output format is not HTML.")
    return pandoc.Null()
  end

end
}
