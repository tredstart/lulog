local Parser = require("rvparser")


--- @class Renderer
--- @field last_token Token?
--- @field content string
local Renderer = {}


local tag_closers = {
    ["text"] = "</p>",
}

---create heading
---@param token Token
function Renderer:heading(token)
    if self.last_token ~= nil and tag_closers[self.last_token.type] ~= nil then
        self.content = self.content .. tag_closers[self.last_token.type]
    end
    self.content = self.content .. "<h" .. token.count .. ">" .. token.content .. "</h" .. token.count .. ">"
end

---create p
---@param token Token
function Renderer:plain_text(token)
    local space = " "
    if self.last_token == nil or (self.last_token.type ~= "text" and self.last_token.type ~= "codeblock") then
        space = ""
        self.content = self.content .. "<p>"
    end
    self.content = self.content .. space .. token.content
end

local tag_handles = {
    ["heading"] = Renderer.heading,
    ["text"] = Renderer.plain_text,
}
---creates an html tags from the token
---@param token Token
function Renderer:unwrap_token(token)
    tag_handles[token.type](self, token)
end

---create html from markdown
---@param content any
---@return string
function Renderer:render(content)
    local parser = Parser
    parser:new()
    self.content = ""
    local parsed = parser:parse(content)
    for _, token in ipairs(parsed) do
        self:unwrap_token(token)
        self.last_token = token
    end
    if self.last_token.type == "text" then
        self.content = self.content .. "</p>"
    end
    return self.content
end

return Renderer
