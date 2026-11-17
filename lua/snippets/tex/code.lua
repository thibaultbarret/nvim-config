local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    s("citco", {
        t("\\begin{citco}[h!] % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{", "        \\label{citco:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}", "        " }),
        rep(1),
        t({ "", "    }" }),
        t({ "", "\\end{citco}" }),
    }),
}
