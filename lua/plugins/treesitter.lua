return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- ← master → main
    lazy = false,
    build = ":TSUpdate",
    config = function()
        -- Le module a changé : nvim-treesitter.configs n'existe plus
        require("nvim-treesitter").setup({
            highlight = { enable = true },
            indent = { enable = true },
        })

        -- ensure_installed n'est plus une option de setup()
        -- Il faut appeler l'API d'installation séparément
        local to_install = {
            "bash",
            "python",
            "latex",
            "lua",
            "gitignore",
            "cpp",
            "c",
            "javascript",
            "json",
        }
        local already = require("nvim-treesitter.config").get_installed()
        local missing = vim.iter(to_install)
            :filter(function(p)
                return not vim.tbl_contains(already, p)
            end)
            :totable()
        require("nvim-treesitter").install(missing)

        -- Ça, ça ne change pas ✓
        vim.treesitter.language.register("cpp", "mfront")
        vim.treesitter.language.register("cpp", "mtest")
    end,
}
