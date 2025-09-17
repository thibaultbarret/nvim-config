local ls = require("luasnip")
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

return {
    -- Chapter:
    s("chapter", {
        t("\\chapter{"),
        i(1),
        t({ "}", "\\label{chap:" }),
        f(sanitize_label, { 1 }),
        t("}"),
    }),
    -- Section:
    s("section", {
        t("\\section{"),
        i(1),
        t({ "}", "\\label{sec:" }),
        f(sanitize_label, { 1 }),
        t("}"),
    }),
    -- Subsection:
    s("subsection", {
        t("\\subsection{"),
        i(1),
        t({ "}", "\\label{sub:" }),
        f(sanitize_label, { 1 }),
        t("}"),
    }),
    -- #
    s("subsubsection", {
        t("\\subsubsection{"),
        i(1),
        t({ "}", "\\label{ssub:" }),
        f(sanitize_label, { 1 }),
        t("}"),
    }),
}
