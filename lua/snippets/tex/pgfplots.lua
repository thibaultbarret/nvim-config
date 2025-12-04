local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    -- Axis environment
    s("axis", {
        t("\\begin{axis}["),
        t({ "", "        " }),
        i(1),
        t({ "", "    ]" }),
        t({ "", "    " }),
        i(0),
        t({ "", "\\end{axis}" }),
    }),
    -- TikZ picture with axis
    s("tikzaxis", {
        t("\\begin{tikzpicture}"),
        t({ "", "    \\begin{axis}[ " }),
        t({ "", "            " }),
        i(1),
        t({ "", "        ]" }),
        t({ "", "        " }),
        i(0),
        t({ "", "    \\end{axis}" }),
        t({ "", "\\end{tikzpicture}" }),
    }),
}
