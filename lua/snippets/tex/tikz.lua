local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    -- line cap
    s("lc", {
        t("line cap = "),
        c(1, {
            t("round"),
            t("rect"),
            t("butt"),
            i(0), -- Point final
            t(", "),
        }),
    }),
    -- line join
    s("lj", {
        t("line join = "),
        c(1, {
            t("round"),
            t("rect"),
            t("butt"),
            i(0), -- Point final
        }),
    }),
    -- line width
    s("lw", {
        t("line width ="),
        i(1),
        t(", "),
    }),
    -- externalization
    s("ext", {
        t("% "),
        i(1, "TikZ file name"),
        t({ "", "" }),
        t("\\tikzsetnextfilename{"),
        f(helpers.sanitize_title, { 1 }),
        t("}"),
        t({ "", "" }),
        t("\\input{Tikz/"),
        f(helpers.sanitize_title, { 1 }),
        t(".tex}"),
        t({ "", "" }),
        i(0),
    }),
    -- externalization folder
    s("extf", {
        t("% "),
        i(1, "TikZ file name"),
        t({ "", "" }),
        t("\\tikzsetnextfilename{"),
        f(helpers.sanitize_title, { 1 }),
        t("}"),
        t({ "", "" }),
        t("\\input{Tikz/"),
        f(helpers.sanitize_title, { 1 }),
        t("/figure.tex}"),
        t({ "", "" }),
        i(0),
    }),
}
