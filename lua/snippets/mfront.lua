local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

-- Fonction pour générer la date au format JJ/MM/YYYY
local function get_current_date()
    return os.date("%d/%m/%Y")
end

-- Charger les snippets spécifiquement pour les fichiers mfront
ls.add_snippets("mfront", {
    s("mfront-header", {
        t("@DSL "), c(1, {
        t("IsotropicPlasticMisesFlow"),
        t("Implicit"),
        t("MaterialProperty"),
        t("MaterialLaw"),
        t("Model")
    }), t(";"),
        t({ "", "@Behaviour " }), i(2, "NomDuComportement"), t(";"),
        t({ "", "@Author Thibault Barret;" }),
        t({ "", "@Date " }), f(get_current_date, {}), t(";"),
        t({ "", "@Description{" }), i(3, "Description du comportement"), t("};"),
        t({ "", "" }),
        i(0)
    })
})
