local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    -- Equation
    s("equ", {
        t("\\begin{equation} % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\label{equ:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        t({ "", "\\end{equation}" }),
    }),
    -- Equation with label
    s("equl", {
        t("\\begin{equation} % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\label{equ:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        t({ "", "\\end{equation}" }),
        t({ "", "\\myequations{" }),
        rep(1),
        t("}"),
    }),
    -- dfrac
    s("dfrac", {
        t("\\dfrac{"),
        i(1),
        t("}{"),
        i(2),
        t("} "),
        i(0),
    }),
    -- frac
    s("frac", {
        t("\\frac{"),
        i(1),
        t("}{"),
        i(2),
        t("} "),
        i(0),
    }),
    -- Parentheses
    s("pare", {
        t("\\left( "),
        i(0),
        t(" \\right)"),
    }),
    -- Bracket
    s("cro", {
        t("\\left\\[ "),
        i(0),
        t(" \\right\\]"),
    }),
    -- Power 2
    s("p2", {
        t("^{2} "),
    }),
    -- Power
    s("pow", {
        t("^{ "),
        i(0),
        t("} "),
    }),
}
