local Parser = require("rvparser")


--- @class Renderer
--- @field last_token Token?
--- @field content string
local Renderer = {}


local tag_closers = {
    ["text"] = "</p>",
}

local function href(start, content)
    local end_href = 0
    local href_title = ""
    local href_link = ""
    local link_start = 0
    local result = ""
    for i = start, #content do
        if content:sub(i, i) == "]" then
            href_title = content:sub(start, i - 1)
            i = i + 1
            if content:sub(i, i) ~= "(" then
                return "", 0
            end
            link_start = i + 1
        end
        if content:sub(i, i) == ")" then
            end_href = i
            href_link = content:sub(link_start, i - 1)
            result = "<a href=\"" .. href_link .. "\">" .. href_title .. "</a>"
            break
        end
    end
    return result, end_href
end

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
    self.content = self.content .. space
    if self.last_token ~= nil and self.last_token.type == "codeblock" then
        self.content = self.content .. token.content
        return
    end
    local start = 1
    for i = start, #token.content do
        if token.content:sub(i, i) == "[" then
            local result, endhref = href(i + 1, token.content)
            if endhref ~= 0 then
                self.content = self.content .. token.content:sub(start, i - 1) .. result
                i = endhref + 1
                start = endhref + 1
            end
        end
    end
    self.content = self.content .. token.content:sub(start)
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
