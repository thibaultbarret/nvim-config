return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    event = "BufReadPre",
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
