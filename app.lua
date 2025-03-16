local lapis = require("lapis")
local db = require("lapis.db")

local app = lapis.Application()
app:enable("etlua")

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
    }
end)

app:get("/blog/:id", function(self)
    local article = db.query("select * from articles where id = ? limit 1", self.params.id)
    if #article == 1 then
        self.article = article[1]
    end
    return {
        render = "article",
    }
end)

return app
