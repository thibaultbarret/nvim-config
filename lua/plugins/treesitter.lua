return {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = { enable = true },
            indent = { enable = true },
            additionnal_vim_regex_highlighting = false,
            ensure_installed = {
                "bash",
                "python",
                "latex",
                "markdown",
                "lua",
                "gitignore",
            },
        })
    end
}
