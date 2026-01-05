return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = { enable = true, additional_vim_regex_highlighting = true },
            indent = { enable = true },
            ensure_installed = {
                "bash",
                "python",
                "latex",
                "markdown",
                "lua",
                "gitignore",
                "cpp",
                "c",
                "javascript",
                "json",
                -- "biblatex",
            },
            -- rainbow = {
            -- enable = true,
            -- list of languages you want to disable the plugin for
            -- disable = { "jsx", "cpp" },
            -- Which query to use for finding delimiters
            -- query = "rainbow-parens",
            -- -- Highlight the entire buffer all at once
            -- strategy = require("ts-rainbow.strategy.global"),
            -- -- Do not enable for files with more than n lines
            -- max_file_lines = 3000,
            -- },
        })
    end,
    vim.treesitter.language.register("cpp", "mfront"),
    vim.treesitter.language.register("cpp", "mtest"),
}
