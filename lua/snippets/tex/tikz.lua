local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local rep = require("luasnip.extras").rep
local ls = require("luasnip")
local d = ls.dynamic_node
local sn = ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmt

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
    -- Figure with externalization
    s("figuretikz", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "" }),
        t("    \\tikzsetnextfilename{"),
        f(helpers.sanitize_title, { 1 }),
        t("}"),
        t({ "", "" }),
        t("    \\input{Tikz/"),
        f(helpers.sanitize_title, { 1 }),
        t(".tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
    -- Figure with externalization in folder
    s("figuretikzfolder", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "" }),
        t("    \\tikzsetnextfilename{"),
        f(helpers.sanitize_title, { 1 }),
        t("}"),
        t({ "", "" }),
        t("    \\input{Tikz/"),
        f(helpers.sanitize_title, { 1 }),
        t("/figure.tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
    -- Tikzpicture
    s("tikzpicture", {
        t("\\begin{tikzpicture}["),
        i(1),
        t({ "]", "    " }),
        i(0),
        t({ "", "\\end{tikzpicture}" }),
    }),
    -- Coordinate frame
    s("coordframe", {
        -- t("% Coordinate frame"),
        t({ "% Coordinate frame", "\\draw [" }),
        i(2),
        t("] (0, 0) -- ("),
        i(1),
        t(", 0) ;", ""),
        t({ "", "\\draw [" }),
        rep(2),
        t("] (0, 0) -- (0, "),
        rep(1),
        t({ ") ;", "" }),
        i(0),
    }),
    -- draw
    s("draw", {
        t("\\draw ["),
        i(1, ""),
        t("] ("),
        i(2, "0"),
        t(", "),
        i(3, "0"),
        t(") "),
        i(0),
        t(";"),
    }),
    --
    s("--", {
        t(" -- ("),
        i(1, "x"),
        t(", "),
        i(2, "y"),
        t(") "),
        i(0),
    }),
    -- scope
    s("scope", {
        t({ "\\begin{scope}[" }),
        i(1),
        -- t("]", ""),
        t({ "]", "    " }),
        -- t({ "" }),
        i(0),
        t({ "", "\\end{scope}" }),
    }),
    -- xshift
    s("xshift", {
        t("xshift = "),
        i(1),
        t(" cm, "),
        i(0),
    }),
    -- yshift
    s("yshift", {
        t("yshift = "),
        i(1),
        t(" cm, "),
        i(0),
    }),
    -- shift
    s("shift", {
        t("shift = {("),
        i(1),
        t(" ,"),
        i(2),
        t(")}"),
    }),
    -- polar shift
    s("pshift", {
        t("shift = {("),
        i(1, "angle"),
        t(" :"),
        i(2, "radius"),
        t(")}"),
    }),
}
