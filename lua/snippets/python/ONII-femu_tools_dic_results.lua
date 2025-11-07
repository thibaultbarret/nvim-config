local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
    -- Columns names
    s(
        "columns_names",
        t([[{
    "x_px": "Image X[Pixel]",
    "y_px": "Image Y[Pixel]",
    "x_mm": "X[mm]",
    "y_mm": "Y[mm]",
    "z_mm": "Z[mm]",
}]])
    ),
    --
}
