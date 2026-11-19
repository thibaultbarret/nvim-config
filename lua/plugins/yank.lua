return {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua" }, -- pour la persistance
    event = { "TextYankPost", "BufReadPost", "BufNewFile" }, -- chargé au premier yank, pas au démarrage
    config = function()
        require("neoclip").setup({
            history = 100000,
            enable_persistent_history = true, -- nécessite sqlite.lua
            continuous_sync = true,
            filter = nil,
            preview = true,
            default_register = '"', -- registre cible par défaut au paste
            content_spec_column = false,
            on_select = {
                move_to_front = false,
                close_telescope = true,
            },
            on_paste = {
                set_reg = false,
                move_to_front = false,
            },
            keys = {
                fzf = {
                    select = "default", -- Enter : colle après le curseur (p)
                    paste = "ctrl-p", -- colle après
                    paste_behind = "ctrl-P",
                    custom = {},
                },
            },
        })

        -- Mapping pour ouvrir l'historique via fzf-lua
        vim.keymap.set("n", "<leader>fy", function()
            require("neoclip.fzf")()
        end, { desc = "Neoclip: yank history (fzf)" })
    end,
}
