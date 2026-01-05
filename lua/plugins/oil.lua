return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
        -- Définir le highlight group personnalisé
        vim.api.nvim_set_hl(0, "OilMtimeCustom", { fg = "#88c0d0", italic = true })

        require("oil").setup({
            columns = {
                "icon",
                {
                    "mtime",
                    highlight = "OilMtimeCustom", -- Applique le highlight personnalisé
                },
            },
            delete_to_trash = true,
            skip_confirm_for_simple_edits = false,
            view_options = {
                show_hidden = false,
                -- Trier par date de modification (le plus récent en premier)
                sort = {
                    { "mtime", "desc" },
                    { "type", "asc" },
                },
            },
        })

        -- Raccourci clavier
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Ouvrir le dossier parent" })
    end,
}
