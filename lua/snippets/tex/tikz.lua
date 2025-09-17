local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node

return {
    s("lc", {
        t("line cap = "),
        c(1, {
            t("round"),
            t("rect"),
            t("butt"),
            i(0), -- Point final
            t(", "),
        }),
    }),
    s("lj", {
        t("line join = "),
        c(1, {
            t("round"),
            t("rect"),
            t("butt"),
            i(0), -- Point final
        }),
    }),
    s("lw", {
        t("line width ="),
        i(1),
        t(", "),
    }),
}
