return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
        { "<leader>ar", "<cmd>AerialToggle<cr>", desc = "Aerial (symbols)" },
        {
            "<leader>far",
            function()
                require("aerial").fzf_lua_picker()
            end,
            desc = "Aerial picker (fzf-lua)",
        },
        { "{", "<cmd>AerialPrev<cr>", desc = "Aerial prev symbol" },
        { "}", "<cmd>AerialNext<cr>", desc = "Aerial next symbol" },
    },
    opts = {
        -- Ordre de priorité des backends. LSP d'abord (basedpyright/clangd/texlab),
        -- treesitter en fallback, markdown pour les fichiers .md.
        backends = { "lsp", "treesitter", "markdown", "man" },

        layout = {
            max_width = { 40, 0.25 },
            min_width = 25,
            default_direction = "prefer_right",
            placement = "window",
            resize_to_content = true,
        },

        -- Suit le symbole sous le curseur, referme les branches non pertinentes.
        attach_mode = "window",
        close_automatic_events = { "unsupported" },
        show_guides = true,
        guides = {
            mid_item = "├─",
            last_item = "└─",
            nested_top = "│ ",
            whitespace = "  ",
        },

        filter_kind = false, -- affiche tous les kinds ; mets une liste pour restreindre

        highlight_on_hover = true,
        autojump = true,

        -- Ferme aerial quand il ne reste que lui.
        close_on_select = false,

        icons = {}, -- récupérées via nvim-web-devicons / lspkind par défaut

        nav = {
            border = "rounded",
            max_height = 0.9,
            min_height = { 10, 0.1 },
            max_width = 0.5,
            min_width = { 0.2, 20 },
            preview = true,
        },

        on_attach = function(bufnr)
            vim.keymap.set("n", "[s", "<cmd>AerialPrev<cr>", { buffer = bufnr })
            vim.keymap.set("n", "]s", "<cmd>AerialNext<cr>", { buffer = bufnr })
        end,
    },
}
