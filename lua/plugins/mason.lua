return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    event = "BufReadPre",
    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                }
            },
            ensure_installed = {
                -- LSP servers
                "pyright",
                "lua-language-server",
                -- Linters
                "ruff",
                "luacheck",
                -- Formatters
                "stylua",
            }
        })
    end,
}
