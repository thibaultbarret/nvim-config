return {
    "DrKJeff16/triforce.nvim",
    dependencies = { "nvzone/volt" },
    keys = {
        {
            "<leader>tp",
            function()
                require("triforce").show_profile()
            end,
        },
    },
    opts = {},
}
