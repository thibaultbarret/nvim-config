return {
    "andersevenrud/nvim_context_vt",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost", -- Charge le plugin après l'ouverture d'un buffer
    config = function()
        require("nvim_context_vt").setup({
            -- Configuration par défaut
            enabled = false,
            prefix = "-->",

            -- Vous pouvez personnaliser selon vos préférences :
            -- prefix = '',
            -- disable_ft = { 'markdown' },
            -- min_rows = 1,
        })
    end,
}
