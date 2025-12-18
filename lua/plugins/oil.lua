return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
        require("oil").setup({
            columns = {
                "icon",
            },
            -- Utiliser la corbeille du système
            delete_to_trash = true,

            -- Confirmation avant suppression
            skip_confirm_for_simple_edits = false,

            -- Vue par défaut
            view_options = {
                show_hidden = false,
            },
            vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Ouvrir le dossier parent" }),
        })
    end,
}
