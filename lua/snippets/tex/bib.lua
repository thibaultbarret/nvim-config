local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
local rep = require("luasnip.extras").rep

return {
    s("cite", {
        t("\\cite{"),
        i(1),
        t({ "}" }),
        i(0),
    }),
    s("citeaut", {
        t("\\citeauthor{"),
        i(1),
        t({ "}" }),
        i(0),
    }),
    s("doublecit", {
        t("\\citeauthor{"),
        i(1),
        t({ "} \\cite{" }),
        rep(1),
        t("}"),
        i(0),
    }),
}
