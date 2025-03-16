local lapis = require("lapis")
local db = require("lapis.db")
local respond_to = require("lapis.application").respond_to

local bcrypt = require("bcrypt")
local log_rounds = 9


local app = lapis.Application()
app:enable("etlua")
app.layout = "layout"

app:get("/", function()
    return {
        render = "index",
    }
end)

app:get("/about", function()
    return {
        render = "about",
    }
end)

app:get("/blog/list", function(self)
    self.articles = db.query("select * from articles")
    return {
        render = "list",
        layout = false,
    }
end)

app:get("/blog/:id", function(self)
    local article = db.query("select * from articles where id = ? limit 1", self.params.id)
    if #article == 1 then
        self.article = article[1]
    else
        return {
            status = 404,
            layout = false
        }
    end

    local hx_request = not (self.req.headers["Hx-Request"] == "true") and app.layout or false
    return {
        render = "article",
        layout = hx_request
    }
end)

--- check with the env key
--- @param key string
local function try_to_login(key)
    local server_key = io.open("prod.env", "r")
    if server_key == nil then
        error("YOU FORGOT TO PUT A KEY IN THE HOLE", nil)
        return false
    end
    local ak = server_key.read(server_key, "*l")

    return bcrypt.verify(key, ak)
end


app:match("/login", respond_to({
    -- do common setup
    before = function(self)
        if self.session.current_user then
            self:write({ redirect_to = "/" })
        end
    end,
    -- render the view
    GET = function()
        return { render = "login" }
    end,
    -- handle the form submission
    POST = function(self)
        print("are we actually posting???")
        self.session.current_user =
            try_to_login(self.params.key)

        return { redirect_to = "/" }
    end
}))


return app
