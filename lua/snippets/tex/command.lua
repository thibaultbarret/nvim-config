local ls = require("luasnip")
-- snippets/tex/command.lua
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep
local helpers = require("snippets.tex.helpers")

return { -- Snippet pour \input{}
    s("input", {
        t("\\input{"),
        i(1, "filename"),
        t("}"),
        i(0),
    }),
    --
    -- \input{<CHAPITRE|ANNEXE>/<sous-dossier>/<Nom_du_fichier>.tex} + création du fichier
    helpers.input_here_snippet("inputdir"),
    -- \input{<dossier courant>/<Nom_de_section>/Premiere_page.tex} + \section adaptée au niveau
    helpers.input_section_snippet("inputsection"),
    --
    -- Snippet pour \include{} (alternative à input)
    s("include", {
        t("\\include{"),
        i(1, "filename"),
        t("}"),
        i(0),
    }),
    --
    -- Snippet pour \includeonly{}
    s("includeonly", {
        t("\\includeonly{"),
        i(1, "filename1,filename2"),
        t("}"),
        i(0),
    }),
    --
    -- Snippet plus avancé avec choix entre input/include
    s("inp", {
        c(1, {
            t("\\input{"),
            t("\\include{"),
        }),
        i(2, "filename"),
        t("}"),
        i(0),
    }),
    --
    -- Snippet avec extension automatique .tex
    s("inputtex", {
        t("\\input{"),
        i(1, "filename"),
        f(function(args)
            local name = args[1][1]
            if name and not name:match("%.tex$") then
                return ".tex"
            end
            return ""
        end, { 1 }),
        t("}"),
        i(0),
    }),
    --
    -- newcommand
    s("newcommand", {
        t("\\newcommand{\\"),
        i(1, "command name"),
        t("}{"),
        i(2, "command"),
        t("\\xspace}"),
        t({ "", "" }),
    }),
    --
    -- newmathcommand
    s("newmathcommand", {
        t("\\newcommand{\\"),
        i(1, "command name"),
        t("}{\\ensuremath{"),
        i(2, "command"),
        t("}\\xspace}"),
        t({ "", "" }),
    }),
}
