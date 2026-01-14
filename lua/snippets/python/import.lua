local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("numpy", {
        t({ "import numpy as np", "" }),
        i(0),
    }),
}
