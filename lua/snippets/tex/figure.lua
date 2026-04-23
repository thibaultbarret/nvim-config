local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep
local helpers = require("snippets.tex.helpers")

return {
    -- Figure:
    s("figure", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
    -- Figure with 2 subfigures:
    s("subfig2", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    \\begin{subfigure}[b]{0.49\\linewidth} % " }),
        i(2),
        t({ "", "        " }),
        -- t("")
        t({ "", "        \\centering" }),
        t({ "", "        \\caption{\\label{subfig:" }),
        f(helpers.sanitize_label, { 2 }),
        t("}"),
        rep(2),
        t("}"),
        t({ "", "    \\end{subfigure}" }),
        t({ "", "    ~" }),
        -- second subfigure
        t({ "", "    \\begin{subfigure}[b]{0.49\\linewidth} % " }),
        i(3),
        t({ "", "        " }),
        -- t("")
        t({ "", "        \\centering" }),
        t({ "", "        \\caption{\\label{subfig:" }),
        f(helpers.sanitize_label, { 3 }),
        t("}"),
        rep(3),
        t("}"),
        t({ "", "    \\end{subfigure}" }),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
        t({ "", "" }),
        i(0),
    }),
    -- Subfigure:
    s("subfig", {
        t({ "", "\\begin{subfigure}[b]{\\linewidth} % " }),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{subfig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{subfigure}" }),
    }),
    -- Figure with TikZ externalization:
    s("figtikz", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    \\tikzsetnextfilename{" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}", "    \\input{Tikz/" }),
        f(helpers.sanitize_label, { 1 }),
        t(".tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
    -- Figure with TikZ externatlization in file:
    s("figtikzfolder", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    \\tikzsetnextfilename{" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}", "    \\input{Tikz/" }),
        f(helpers.sanitize_label, { 1 }),
        t("/figure.tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(helpers.sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
}
