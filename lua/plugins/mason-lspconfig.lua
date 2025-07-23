return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
        require("mason-lspconfig").setup({
            automatic_enable = true,
            ensure_installed = {
                "pyright",
                "lua_ls",
            },
        })
    end,
}
