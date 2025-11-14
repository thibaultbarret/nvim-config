local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- Fonction pour récupérer la date de création du fichier
local function get_file_creation_date()
    local filepath = vim.fn.expand("%:p")
    if filepath == "" or not vim.fn.filereadable(filepath) then
        return os.date("%d/%m/%Y à %H:%M") -- Si pas de fichier, retourne la date courante
    end

    local cmd
    local os_name = vim.fn.has("win32") == 1 and "windows" or vim.fn.has("mac") == 1 and "mac" or "linux"

    if os_name == "windows" then
        cmd = string.format('forfiles /m "%s" /c "cmd /c echo @fcreated"', vim.fn.expand("%:t"))
    elseif os_name == "mac" then
        cmd = string.format('stat -f "%%SB" -t "%%d/%%m/%%Y à %%H:%%M" "%s"', filepath)
    else -- Linux
        cmd = string.format('stat -c "%%w" "%s" 2>/dev/null || stat -c "%%y" "%s"', filepath, filepath)
    end

    local handle = io.popen(cmd)
    if handle then
        local result = handle:read("*a")
        handle:close()

        if result and result ~= "" then
            result = result:gsub("%s+$", "") -- Supprime les espaces en fin

            -- Pour Linux, convertir le format si nécessaire
            if os_name == "linux" and result ~= "-" then
                local year, month, day, hour, min = result:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
                if year then
                    return string.format("%s/%s/%s à %s:%s", day, month, year, hour, min)
                end
            elseif result ~= "-" and result ~= "" then
                return result
            end
        end
    end

    -- Si échec, retourne la date courante
    return os.date("%d/%m/%Y à %H:%M")
end

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
        t("# -*- coding: utf-8 -*-"),
        t({ "", "" }),
        t('"""'),
        t({ "", "" }),
        f(get_filename),
        t({ "", "", "Description : ", "    " }),
        i(1, "Description du fichier"),
        t({ "", "", "Auteur : thibaultbarret", "", "Date de création: " }),
        f(get_file_creation_date),
        t({ "", "Dernière modification: " }),
        f(get_current_date),
        t({ "", '"""' }),
    }),
    -- Snippet pour Parameters
    s(
        "params",
        fmt(
            [[
    Parameters
    ----------
    {} : {}
        {}{}
  ]],
            {
                i(1, "param_name"),
                i(2, "type"),
                i(3, "Description du paramètre"),
                i(0),
            }
        )
    ),
    s(
        "param",
        fmt(
            [[
    {} : {}
        {}
  ]],
            {
                i(1, "param_name"),
                i(2, "type"),
                i(3, "Description du paramètre"),
            }
        )
    ),
}
