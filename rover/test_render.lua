local Renderer = require("renderer")

local test = {}

test.renderer = function()
    local test_input = [[# Heading
some pure bs text hello world
multi line
## hello?
more text
]]
    local expected = "<h1>Heading</h1><p>some pure bs text hello world multi line</p><h2>hello?</h2><p>more text</p>"
    local result = Renderer:render(test_input)
    print(result)
    assert(result == expected, "can't render this bs")
end

return test
