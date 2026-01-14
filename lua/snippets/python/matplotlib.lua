local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("matplotlib", {
        t({ "import matplotlib.pyplot as plt", "" }),
        i(0),
    }),

    s("figure", {
        t("fig = plt.figure()"),
        i(0),
    }),
}
