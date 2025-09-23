local ls = require("luasnip")
-- snippets/tex/command.lua
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local rep = require("luasnip.extras").rep

local function sanitize_label(args, snip)
    local text = args[1][1] or ""

    -- Supprimer les accents (approximation simple)
    local accent_map = {
        ["à"] = "a",
        ["á"] = "a",
        ["â"] = "a",
        ["ã"] = "a",
        ["ä"] = "a",
        ["å"] = "a",
        ["è"] = "e",
        ["é"] = "e",
        ["ê"] = "e",
        ["ë"] = "e",
        ["ì"] = "i",
        ["í"] = "i",
        ["î"] = "i",
        ["ï"] = "i",
        ["ò"] = "o",
        ["ó"] = "o",
        ["ô"] = "o",
        ["õ"] = "o",
        ["ö"] = "o",
        ["ù"] = "u",
        ["ú"] = "u",
        ["û"] = "u",
        ["ü"] = "u",
        ["ý"] = "y",
        ["ÿ"] = "y",
        ["ñ"] = "n",
        ["ç"] = "c",
        -- Majuscules
        ["À"] = "A",
        ["Á"] = "A",
        ["Â"] = "A",
        ["Ã"] = "A",
        ["Ä"] = "A",
        ["Å"] = "A",
        ["È"] = "E",
        ["É"] = "E",
        ["Ê"] = "E",
        ["Ë"] = "E",
        ["Ì"] = "I",
        ["Í"] = "I",
        ["Î"] = "I",
        ["Ï"] = "I",
        ["Ò"] = "O",
        ["Ó"] = "O",
        ["Ô"] = "O",
        ["Õ"] = "O",
        ["Ö"] = "O",
        ["Ù"] = "U",
        ["Ú"] = "U",
        ["Û"] = "U",
        ["Ü"] = "U",
        ["Ý"] = "Y",
        ["Ÿ"] = "Y",
        ["Ñ"] = "N",
        ["Ç"] = "C",
    }

    -- Remplacer les caractères accentués
    for accented, plain in pairs(accent_map) do
        text = text:gsub(accented, plain)
    end

    -- Convertir en minuscules
    text = text:lower()

    -- Remplacer tout ce qui n'est pas alphanumérique par des underscores
    text = text:gsub("[^%w]", "-")

    -- Remplacer les underscores multiples par un seul
    text = text:gsub("-+", "-")

    -- Supprimer les underscores au début et à la fin
    text = text:gsub("^-+", ""):gsub("-+$", "")

    return text
end

return { -- Snippet pour \input{}
    s("input", {
        t("\\input{"),
        i(1, "filename"),
        t("}"),
        i(0),
    }),

    -- Snippet pour \include{} (alternative à input)
    s("include", {
        t("\\include{"),
        i(1, "filename"),
        t("}"),
        i(0),
    }),

    -- Snippet pour \includeonly{}
    s("includeonly", {
        t("\\includeonly{"),
        i(1, "filename1,filename2"),
        t("}"),
        i(0),
    }),

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

    -- newcommand
    s("newcommand", {
        t("\\newcommand{\\"),
        i(1, "command name"),
        t("}{"),
        i(2, "command"),
        t("\\xspace}"),
        t({ "", "" }),
    }),
}
