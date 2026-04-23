local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep
local helpers = require("snippets.tex.helpers")

return {
    -- Chapter:
    s("chapter", {
        t("\\chapter{"),
        i(1),
        t({ "}", "\\label{chap:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
    }),
    -- Section:
    s("section", {
        t("\\section{"),
        i(1),
        t({ "}", "\\label{sec:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
    }),
    -- Subsection:
    s("subsection", {
        t("\\subsection{"),
        i(1),
        t({ "}", "\\label{sub:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
    }),
    -- Subsubsection:
    s("subsubsection", {
        t("\\subsubsection{"),
        i(1),
        t({ "}", "\\label{ssub:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
    }),
}
