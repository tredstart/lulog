local Renderer = require("renderer")

local test = {}

test.renderer = function()
    local test_input = [[# Heading
some [titel](link) text hello world
multi line
## hello?
more text
![alttext](link) with some text
- ul me
- this
1. ol me
2. daddy
```
fucking code
```
]]
    local expected =
        "<h1>Heading</h1><p>some <a href=\"link\">titel</a> text hello world multi line</p><h2>hello?</h2><p>more text </p>" ..
        "<img src=\"link\" alt=\"alttext\"><p> with some text</p><ul><li>ul me</li><li>this</li></ul><ol><li>ol me</li><li>daddy</li></ol>" ..
        "<pre> fucking code</pre>"
    local result = Renderer:render(test_input)
    print(result)
    print(expected)
    assert(result == expected, "can't render this bs")
end

return test
