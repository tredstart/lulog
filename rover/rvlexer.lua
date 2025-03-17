--- @class Lexer
--- @field line string
--- @field position number
--- @field read_position number
--- @field char string
local Lexer = {}


--- set default values to lexer + a line to tokenize
--- @param line string
--- @param position number?
function Lexer:reset(line, position)
    Lexer.line = line
    Lexer.position = position or 1
    Lexer.read_position = position or 1
    Lexer.char = ""
end

--- @class Token
--- @field type string
--- @field count number?
--- @field content string
local Token = {}

---proceed with collecting plaintext
---@param line string
---@return Token
function Lexer:plain_text(line)
    return {
        type = "text",
        content = line,
    }
end

---proceed with collecting heading
---@param line string
---@return Token?
function Lexer:handle_heading(line)
    local count = 1
    local complete = false
    for i = Lexer.position + 1, Lexer.position + 3, 1 do
        if line:sub(i, i) == " " then
            Lexer.position = i + 1
            complete = true
            break
        elseif line:sub(i, i) ~= "#" then
            break
        end
        count = count + 1
    end
    return complete and {
        type = "heading",
        count = complete and count or nil,
        content = line:sub(Lexer.position)
    } or nil
end

Lexer.tokens = {
    ["#"] = Lexer.handle_heading,
}

--- create tokens from the line
--- @return Token
function Lexer:tokenize_line()
    local char = Lexer.line:sub(Lexer.position, Lexer.position)
    local token_handler = Lexer.tokens[char] or Lexer.plain_text
    return token_handler(Lexer, Lexer.line) or Lexer:plain_text(Lexer.line)
end

return Lexer
