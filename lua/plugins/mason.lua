return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    envent = "BufReadPre",
    config = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            }
        }
    },
    config = function()
        require("mason").setup()
    end,
}
