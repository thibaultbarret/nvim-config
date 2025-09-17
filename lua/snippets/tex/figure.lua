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
    -- Figure:
    s("figure", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    " }),
        i(0),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
    -- Figure with 2 subfigures:
    s("subfig2", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    \\begin{subfigure}[b]{0.49\\linewidth} % " }),
        i(2),
        t({ "", "        " }),
        -- t("")
        t({ "", "        \\centering" }),
        t({ "", "        \\caption{\\label{subfig:" }),
        f(sanitize_label, { 2 }),
        t("}"),
        rep(2),
        t("}"),
        t({ "", "    \\end{subfigure}" }),
        t({ "", "    ~" }),
        -- second subfigure
        t({ "", "    \\begin{subfigure}[b]{0.49\\linewidth} % " }),
        i(3),
        t({ "", "        " }),
        -- t("")
        t({ "", "        \\centering" }),
        t({ "", "        \\caption{\\label{subfig:" }),
        f(sanitize_label, { 3 }),
        t("}"),
        rep(3),
        t("}"),
        t({ "", "    \\end{subfigure}" }),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
        t({ "", "" }),
        i(0),
    }),
    -- Figure with TikZ externalisation:
    s("figtikz", {
        t("\\begin{figure}[h!] % "),
        i(1),
        t({ "", "    \\tikzsetnextfilename{" }),
        f(sanitize_label, { 1 }),
        t({ "}", "    \\input{Tikz/" }),
        f(sanitize_label, { 1 }),
        t(".tex}"),
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{\\label{fig:" }),
        f(sanitize_label, { 1 }),
        t("}"),
        rep(1),
        t("}"),
        t({ "", "\\end{figure}" }),
    }),
}
