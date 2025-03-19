local Parser = require("rvparser")


--- @class Renderer
--- @field last_token Token?
--- @field content string
local Renderer = {}


local tags = {
    ["text"] = {
        opener = "<p>",
        closer = "</p>",
    },
    ["ul"] = {
        opener = "<ul>",
        closer = "</ul>"
    },
    ["ol"] = {
        opener = "<ol>",
        closer = "</ol>"
    }
}

---create a href
---@param start number
---@param content string
---@return string a resulting string
---@return integer 0 if not a link, else an index in the content where ")" was found
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


---create an img
---@param start number
---@param content string
---@param last_token Token
---@return string a resulting string
---@return integer 0 if not an img, else an index in the content where ")" was found
local function img(start, content, last_token)
    local end_href = 0
    local alt_text = ""
    local href_link = ""
    local link_start = 0
    local result = ""
    for i = start, #content do
        if content:sub(i, i) == "]" then
            alt_text = content:sub(start, i - 1)
            i = i + 1
            if content:sub(i, i) ~= "(" then
                return "", 0
            end
            link_start = i + 1
        end
        if content:sub(i, i) == ")" then
            end_href = i
            href_link = content:sub(link_start, i - 1)
            result = (tags[last_token.type] and tags[last_token.type].closer or "") ..
                "<img src=\"" .. href_link .. "\" alt=\"" .. alt_text .. "\">"
            break
        end
    end
    return result, end_href
end

---create heading
---@param token Token
function Renderer:heading(token)
    if self.last_token ~= nil and tags[self.last_token.type] ~= nil then
        self.content = self.content .. (tags[self.last_token.type].closer or "")
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
    local i = start
    while i < #token.content do
        if token.content:sub(i, i) == "[" then
            local result, endhref = href(i + 1, token.content)
            if endhref ~= 0 then
                self.content = self.content .. token.content:sub(start, i - 1) .. result
                i = endhref + 1
                start = endhref + 1
            end
        end

        if token.content:sub(i, i) == "!" and token.content:sub(i + 1, i + 1) == "[" then
            local result, endhref = img(i + 2, token.content, self.last_token)
            if endhref ~= 0 then
                self.content = self.content .. token.content:sub(start, i - 1) .. result
                i = endhref + 1
                start = endhref + 1
                if token.content:sub(i + 1, i + 1) ~= "" then
                    self.content = self.content ..
                        (tags[self.last_token.type] and tags[self.last_token.type].opener or "")
                end
            end
        end
        i = i + 1
    end
    self.content = self.content .. token.content:sub(start)
end

---create list
---@param token Token
function Renderer:list(token)
    if self.last_token ~= nil and tags[self.last_token.type] ~= nil and self.last_token.type ~= token.type then
        self.content = self.content .. (tags[self.last_token.type].closer or "")
    end
    if self.last_token ~= nil and self.last_token.type ~= token.type then
        self.content = self.content .. tags[token.type].opener
    end
    self.content = self.content .. "<li>" .. token.content .. "</li>"
end

---create codeblock
---@param token Token
function Renderer:codeblock(token)
    if self.last_token and self.last_token.type == "codeblock" then
        self.content = self.content .. "</pre>"
        self.last_token = nil
    else
        if self.last_token ~= nil and tags[self.last_token.type] ~= nil then
            self.content = self.content .. (tags[self.last_token.type].closer or "")
        end
        self.content = self.content .. "<pre>"
    end
end

local tag_handles = {
    ["heading"] = Renderer.heading,
    ["text"] = Renderer.plain_text,
    ["ul"] = Renderer.list,
    ["ol"] = Renderer.list,
    ["codeblock"] = Renderer.codeblock,
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
        if not self.last_token or self.last_token.type ~= "codeblock" then
            self.last_token = token
        end
    end
    if self.last_token then
        self.content = self.content .. (tags[self.last_token.type] and tags[self.last_token.type].closer or "")
    end
    return self.content
end

return Renderer
