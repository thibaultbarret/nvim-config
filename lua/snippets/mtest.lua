local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node

local function get_current_date()
    return os.date("%d/%m/%Y")
end

ls.add_snippets("mtest", {
    s("mtest_header", {
        t({ "", "@Author Thibault Barret;" }),
        t({ "", "@Date " }),
        f(get_current_date, {}),
        t(";"),
        t({ "", "@Description{" }),
        i(1, "Description du comportement"),
        t("};"),
        t({ "", "" }),
        i(0),
    }),
})
