local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    -- Subigure
    s("caption_subfig", {
        t({ "\\caption{\\label{subfig:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}" }),
        i(1),
        t("} "),
        i(0),
    }),
    -- Figure
    s("caption_fig", {
        t({ "\\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}" }),
        i(1),
        t("} "),
        i(0),
    }),
    -- Table
    s("caption_tab", {
        t({ "\\caption{\\label{tab:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}" }),
        i(1),
        t("} "),
        i(0),
    }),
}
