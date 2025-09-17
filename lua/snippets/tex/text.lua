local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

return {
    -- small cap
    s("sc", {
        t("\\textsc{"),
        i(1),
        t("} "),
    }),
    -- italic
    s("it", {
        t("\\textit{"),
        i(1),
        t("} "),
    }),
    -- bold
    s("bf", {
        t("\\textbf{"),
        i(1),
        t("} "),
    }),
    -- sans font
    s("sf", {
        t("\\textsf{"),
        i(1),
        t("} "),
    }),
    -- quotes
    s("quotes", {
        t("\\og "),
        i(1),
        t(" \\fg{} "),
    }),
}
