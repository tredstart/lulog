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
    --- check first if we're are not in the ordered list
    if tonumber(line:sub(Lexer.position, Lexer.position)) ~= nil and
        line:sub(Lexer.position + 1, Lexer.position + 1) == "." then
        return {
            type = "ol",
            content = line:sub(Lexer.position + 3),
        }
    end

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

---proceed with collecting list
---@param line string
---@return Token?
function Lexer:handle_list(line)
    if line:sub(Lexer.position + 1, Lexer.position + 1) == " " then
        return {
            type = "ul",
            content = line:sub(Lexer.position + 2)
        }
    end
    return nil
end

---proceed with collecting blockquote
---@param line string
---@return Token?
function Lexer:handle_blockquote(line)
    if line:sub(Lexer.position + 1, Lexer.position + 1) == " " then
        return {
            type = "blockquote",
            content = line:sub(Lexer.position + 2)
        }
    end
    return nil
end

---proceed with collecting codeblock
---@param line string
---@return Token?
function Lexer:handle_codeblock(line)
    if line:sub(Lexer.position, Lexer.position + 2) == "```" then
        return {
            type = "codeblock",
        }
    end
    return nil
end

Lexer.tokens = {
    ["#"] = Lexer.handle_heading,
    ["-"] = Lexer.handle_list,
    [">"] = Lexer.handle_blockquote,
    ["`"] = Lexer.handle_codeblock,
}

--- create tokens from the line
--- @return Token
function Lexer:tokenize_line()
    local char = Lexer.line:sub(Lexer.position, Lexer.position)
    local token_handler = Lexer.tokens[char] or Lexer.plain_text
    return token_handler(Lexer, Lexer.line) or Lexer:plain_text(Lexer.line)
end

return Lexer
