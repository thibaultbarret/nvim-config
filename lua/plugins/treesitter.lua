return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = { enable = true, additional_vim_regex_highlighting = false },
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
            },
        })
    end,
    vim.treesitter.language.register("cpp", "mfront"),
    vim.treesitter.language.register("cpp", "mtest"),
}
