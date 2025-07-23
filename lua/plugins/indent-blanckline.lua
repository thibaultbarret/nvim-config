return {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
        indent = {
            char = "│", -- tu peux tester "▏" ou "▎" aussi
            tab_char = "│",
            highlight = { "IblIndent" }, -- toutes les lignes
        },
        scope = {
            enabled = true,
            highlight = { "IblScope" }, -- uniquement la ligne active
            show_start = true,
            show_end = false,
            include = {
                node_type = {
                    ["*"] = { "*" },
                },
            },
        },
        exclude = {
            filetypes = {
                "help", "dashboard", "lazy", "mason", "NvimTree", "terminal",
            },
        },
    },
    config = function(_, opts)
        require("ibl").setup(opts)

        -- Ajout d'un groupe de couleurs personnalisé si nécessaire
        local cp = require("catppuccin.palettes").get_palette("mocha")
        vim.api.nvim_set_hl(0, "IblIndent", { fg = cp.surface1 })
        vim.api.nvim_set_hl(0, "IblScope", { fg = cp.lavender, bold = true })
    end,
}
