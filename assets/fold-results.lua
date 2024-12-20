-- Fold output from code chunks
-- In code chunk, add #| attr.output: '.details summary="Output"'
-- Only works for knitr chunks
-- https://gist.github.com/atusy/f2b5b992e45c68ab6823499f2339c6e6

function CodeBlock(elem)
  if elem.classes and elem.classes:find("details") then
    local summary = "Code"
    if elem.attributes.summary then
      summary = elem.attributes.summary
    end
    return{
      pandoc.RawBlock(
        "html", "<details><summary>" .. summary .. "</summary>"
      ),
      elem,
      pandoc.RawBlock("html", "</details>")
    }
  end
end
