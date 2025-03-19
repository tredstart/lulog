local parser = require("rover.rvparser")

local test_parser = require("rover.test_parser")
local test_render = require("rover.test_render")

--- simple test runner for them tests
local function test_runner()
    parser:new()
    local tests = {
        test_parser.text_parser,
        test_parser.heading_parser,
        test_parser.list_parser,
        test_parser.blockquote,
        test_parser.ordered_list,
        test_parser.codeblock,
        test_render.renderer,
    }

    for i, test in ipairs(tests) do
        print("\x1b[1A\x1b[2Ktest [" .. i .. "/" .. #tests .. "]")
        test()
    end
    print("\n\x1b[38;2;0;200;0;mOK\x1b[0m")
end

test_runner()
