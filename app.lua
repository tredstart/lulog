local lapis = require("lapis")
local db = require("lapis.db")

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

return app
