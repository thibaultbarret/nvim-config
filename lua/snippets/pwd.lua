local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

-- Snippet qui affiche le chemin du répertoire courant
ls.add_snippets("all", {
    s("pwd", {
        f(function()
            return vim.fn.getcwd()
        end),
    }),

    -- Variante avec juste le nom du répertoire (sans le chemin complet)
    s("dirname", {
        f(function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end),
    }),

    -- Variante avec le chemin du fichier courant
    s("filepath", {
        f(function()
            return vim.fn.expand("%:p")
        end),
    }),

    -- Variante avec le répertoire du fichier courant
    s("filedir", {
        f(function()
            return vim.fn.expand("%:p:h")
        end),
    }),
})
