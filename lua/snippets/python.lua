local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Fonction pour obtenir la date actuelle
local function get_current_date()
    return os.date("%d/%m/%Y à %H:%M")
end

-- Fonction pour obtenir le nom du fichier sans l'extension
local function get_filename()
    local filename = vim.fn.expand("%:t")
    return filename ~= "" and filename or "nom_du_fichier"
end


return {
    s("header", {
        t('# -*- coding: utf-8 -*-'),
        t({ "", "" }),
        t('"""'),
        t({ "", "" }),
        f(get_filename),
        t({ "", "", "Description : ", "    " }),
        i(1, "Description du fichier"),
        t({ "", "", "Auteur : thibaultbarret", "", "Date de création: " }),
        f(get_current_date),
        t({ "", "Dernière modification: " }),
        f(get_current_date),
        t({ "", '"""' })
    })
}
