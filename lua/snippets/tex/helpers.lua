local M = {}
--
-- Table des accents commune
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

-- Fonction privée pour la logique commune
local function process_text(text)
    -- Remplacer les caractères accentués
    for accented, plain in pairs(accent_map) do
        text = text:gsub(accented, plain)
    end

    -- Convertir en minuscules
    text = text:lower()

    -- Remplacer tout ce qui n'est pas alphanumérique par des tirets
    text = text:gsub("[^%w]", "-")

    -- Remplacer les tirets multiples par un seul
    text = text:gsub("-+", "-")

    -- Supprimer les tirets au début et à la fin
    text = text:gsub("^-+", ""):gsub("-+$", "")

    return text
end

function M.sanitize_label(args, snip)
    local text = args[1][1] or ""
    return process_text(text)
end

function M.sanitize_title(args, snip)
    local text = args[1][1] or ""
    text = process_text(text)

    -- Capitaliser la première lettre
    if text:len() > 0 then
        text = text:sub(1, 1):upper() .. text:sub(2)
    end

    return text
end

return M
