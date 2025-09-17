-- snippets/tex/init.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Liste des fichiers de snippets à charger
local snippet_files = {
    -- "command",
    -- "list",
    -- "tikz",
    -- "title",
    -- "math",
    -- "environments",
    -- "formatting",
    -- "symbols"
}

-- Snippets de base directement dans ce fichier
local snippets = {
    s("doc", {
        t("\\documentclass{article}"),
        t({ "", "\\begin{document}" }),
        t({ "", "" }),
        i(1),
        t({ "", "\\end{document}" }),
    }),

    s("standalone", {
        t("\\documentclass[margin=1cm]{standalone}"),
        t({ "", "", "\\usepackage{tikzpgfplots, MMC, unite}" }),
        t({ "", "", "\\begin{document}" }),
        t({ "", "\\begin{tikzpicture}" }),
        t({ "", "" }),
        i(1),
        t({ "", "\\end{tikzpicture}" }),
        t({ "", "\\end{document}" }),
    }),
    s("usepackage", {
        t("\\usepackage{"),
        i(1),
        t("}"),
        i(0),
    }),
}

-- Charger automatiquement tous les fichiers de snippets
for _, file in ipairs(snippet_files) do
    local ok, file_snippets = pcall(require, "snippets.tex." .. file)
    if ok and file_snippets then
        vim.list_extend(snippets, file_snippets)
    else
        -- Optionnel : message de debug si un fichier n'existe pas encore
        print("Fichier de snippets non trouvé : " .. file)
    end
end
return snippets
