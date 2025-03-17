local parser = require("rvparser")

local function test_text_parser()
    local sample_input = "plain text\n"
    local expected_output = {
        {
            type = "text",
            content = "plain text",
        },
    }
    local parsed = parser:parse(sample_input)
    for i, expected in ipairs(expected_output) do
        assert(expected.type == parsed[i].type and expected.content == parsed[i].content, "failed to parse plain text")
    end
end

local function test_heading_parser()
    local sample_input = "# heading one\n## heading two\n### heading three \n#noheading\n"
    local expected_output = {
        {
            type = "heading",
            count = 1,
            content = "heading one",
        },
        {
            type = "heading",
            count = 2,
            content = "heading two",
        },
        {
            type = "heading",
            count = 3,
            content = "heading three ",
        },
        {
            type = "text",
            content = "#noheading",
        },
    }
    local parsed = parser:parse(sample_input)
    for i, expected in ipairs(expected_output) do
        assert(
            expected.type == parsed[i].type and
            expected.content == parsed[i].content and
            expected.count == parsed[i].count,
            "failed to header text at step: " .. i)
    end
end

--- simple test runner for them tests
local function test_runner()
    parser:new()
    local tests = {
        test_text_parser,
        test_heading_parser,
    }

    for i, test in ipairs(tests) do
        print("\x1b[1A\x1b[2Ktest [" .. i .. "/" .. #tests .. "]")
        test()
    end
    print("\n\x1b[38;2;0;200;0;mOK\x1b[0m")
end

test_runner()
