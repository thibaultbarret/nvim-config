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
                -- Nouvel onglet juste à droite du courant. Le tri par défaut (numéro de buffer)
                -- mettait à gauche les fichiers déjà chargés en arrière-plan (ex. \input vus par texlab).
                sort_by = "insert_after_current",
                offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
            },
        }
    end,
}
