local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
local rep = require("luasnip.extras").rep

return {
    s("num", {
        t("\\num{"),
        i(1),
        t({ "}" }),
        i(0),
    }),
}
