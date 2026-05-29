return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            highlight = { enable = true },
            indent = { enable = true },
        })

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
            -- "astro",
        }
        local already = require("nvim-treesitter.config").get_installed()
        local missing = vim.iter(to_install)
            :filter(function(p)
                return not vim.tbl_contains(already, p)
            end)
            :totable()
        require("nvim-treesitter").install(missing)

        -- ── Parsers custom : mfront / mtest ─────────────────────────────────
        -- Neovim charge les .so depuis stdpath("data")/site/parser/
        -- (déjà compilés manuellement, pas via :TSInstall)
        vim.filetype.add({
            extension = {
                mfront = "mfront",
                mtest = "mtest",
            },
        })
    end,
}
