local helpers = require("snippets.tex.helpers")
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep

return {
    s("schema", {
        t("\\begin{schema}[h!] % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{", "        \\label{sch:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}", "        " }),
        rep(1),
        t({ "", "    }" }),
        t({ "", "\\end{schema}" }),
    }),

    s("schema-tikz", {
        t("\\begin{schema}[h!] % "),
        i(1),
        -- t({ "", "    " }),
        t({ "", "    \\tikzsetnextfilename{" }),
        f(helpers.sanitize_title, { 1 }),
        t({ "}", "    \\input{Tikz/" }),
        f(helpers.sanitize_label, { 1 }),
        t(".tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{", "        \\label{sch:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}", "        " }),
        rep(1),
        t({ "", "    }" }),
        t({ "", "\\end{schema}" }),
    }),
    s("schema-tikz-folder", {
        t("\\begin{schema}[h!] % "),
        i(1),
        -- t({ "", "    " }),
        t({ "", "    \\tikzsetnextfilename{" }),
        f(helpers.sanitize_title, { 1 }),
        t({ "}", "    \\input{Tikz/" }),
        f(helpers.sanitize_label, { 1 }),
        t("/figure.tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{", "        \\label{sch:" }),
        f(helpers.sanitize_label, { 1 }),
        t({ "}", "        " }),
        rep(1),
        t({ "", "    }" }),
        t({ "", "\\end{schema}" }),
    }),
    -- Schéma + création du fichier TikZ dans le chapitre
    helpers.tikz_float_snippet("schema-tikz-chap", "schema", "sch", false),
    helpers.tikz_float_snippet("schema-tikz-folder-chap", "schema", "sch", true),
}
