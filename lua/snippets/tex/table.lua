local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    s("table", {
        t("\\begin{table}[h!] % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{tab:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{table}" }),
    }),
}
