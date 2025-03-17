local Lexer = require("rvlexer")

--- @class Parser
--- @field lexer Lexer
local Parser = {}

function Parser:new()
    Parser.lexer = Lexer
end

---parse the input duh
---@param input string
---@return table<Token>
function Parser:parse(input)
    local parsed = {}

    local start = 1
    for i = 1, input:len(), 1 do
        if input:sub(i, i) == "\n" then
            Parser.lexer:reset(input:sub(start, i - 1))
            table.insert(parsed, Parser.lexer:tokenize_line())
            start = i + 1
        end
    end

    return parsed
end

return Parser
