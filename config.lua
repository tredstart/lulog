local config = require("lapis.config")

config("development", {
    server = "nginx",
    code_cache = "off",
    num_workers = "1",
    port = "6969",
    sqlite = {
        database = "blog.sqlite",
    }
})
