local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- Fonction simple pour obtenir le commentaire
local function comment()
    local commentstring = vim.bo.commentstring
    if commentstring and commentstring ~= "" then
        return commentstring:gsub("%%s.*", "") .. " "
    end
    return "// " -- fallback
end

-- Fonction pour la date
local function date()
    return os.date("%Y-%m-%d")
end

-- Fonction pour l'utilisateur
local function user()
    return os.getenv("USER") or "user"
end

-- Snippets essentiels
local snippets = {
    -- TODO
    s("todo", fmt("{}{}: {} - {} ({})", {
        f(comment),
        t("TODO"),
        i(1, "description"),
        f(user),
        f(date),
    })),

    -- FIXME
    s("fixme", fmt("{}{}: {} - {} ({})", {
        f(comment),
        t("FIXME"),
        i(1, "problème à corriger"),
        f(user),
        f(date),
    })),

    -- NOTE
    s("note", fmt("{}{}: {}", {
        f(comment),
        t("NOTE"),
        i(1, "note importante"),
    })),

    -- HACK
    s("hack", fmt("{}{}: {}", {
        f(comment),
        t("HACK"),
        i(1, "solution temporaire"),
    })),

    -- Versions courtes
    s("td", fmt("{}{}: {}", {
        f(comment),
        t("TODO"),
        i(1),
    })),

    s("fx", fmt("{}{}: {}", {
        f(comment),
        t("FIXME"),
        i(1),
    })),
}

-- Ajouter pour tous les filetypes
ls.add_snippets("all", snippets)
