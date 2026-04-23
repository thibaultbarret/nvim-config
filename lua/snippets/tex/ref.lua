local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    -- Plot label
    s("plotl", {
        t("\\label{plot:"),
        i(1),
        t("} "),
        i(0),
    }),
    -- ref
    s("ref", {
        t("\\ref{"),
        i(1),
        t("} "),
        i(0),
    }),
    -- figure ref
    s("fref", {
        t("figure~\\ref{fig"),
        i(1),
        t("} "),
        i(0),
    }),
    -- table ref
    s("tref", {
        t("tableau~\\ref{tab"),
        i(1),
        t("} "),
        i(0),
    }),
    -- equation ref
    s("eref", {
        t("\\eqref{eq"),
        i(1),
        t("} "),
        i(0),
    }),
}
