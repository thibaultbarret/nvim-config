return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    -- Fonction : évaluée au chargement de bufferline, après catppuccin (priority = 1000)
    opts = function()
        return {
            highlights = require("catppuccin.special.bufferline").get_theme(),
            options = {
                separator_style = "slant",
                offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
            },
        }
    end,
}
