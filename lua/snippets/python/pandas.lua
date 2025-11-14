local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {
    s("df_csv", {
        t({
            "header = 0,",
            'sep=";",',
            'decimal=",",',
            'usecols = lambda x : x in [""]',
        }),
    }),
    s("df_csv_matchid", {
        t({
            "header = 0,",
            'sep=";",',
            'decimal=",",',
            'usecols = lambda x : x in ["Image X[Pixel]", "Image Y[Pixel]", "X[mm]", "Y[mm]", "Z[mm]"]',
        }),
    }),
}
