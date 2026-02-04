local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    s("pandas", {
        t({ "import pandas as pd", "" }),
        i(0),
    }),

    s("df_csv", {
        t({
            "header = 0,",
            'sep=";",',
            'decimal=",",',
            'usecols = lambda x : x in [""]',
        }),
    }),
    s("df_csv_matchid", {
        t("df = pd.read_csv('"),
        i(1, "file_path"),
        t({
            "',",
            "header = 0,",
            'sep=";",',
            'decimal=",",',
            'usecols = lambda x : x in ["Image X[Pixel]", "Image Y[Pixel]", "X[mm]", "Y[mm]", "Z[mm]"]',
            ")",
            "",
        }),
        i(0),
    }),
    s("rename_columns", {
        i(1, "dataframe"),
        t({
            ".rename(",
            "    columns={",
            '        "Image X[Pixel]": "x_px",',
            '        "Image Y[Pixel]": "y_px",',
            '        "X[mm]": "x_mm",',
            '        "Y[mm]": "y_mm",',
            '        "Z[mm]": "z_mm",',
            "    }",
            ")",
            "",
        }),
        i("0"),
    }),
}
