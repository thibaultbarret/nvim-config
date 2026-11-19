return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Syntaxe Trouble v3 (les anciennes clés v2 position/height/mode/action_keys
    -- étaient ignorées). q / <esc> / <cr> sont déjà les touches par défaut.
    opts = {
        win = { position = "bottom", size = 10 },
    },
    cmd = "Trouble",
    keys = {
        {
            "<leader>tx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
    },
}
