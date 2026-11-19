return {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
        {
            "<leader>S",
            function()
                require("spectre").toggle()
            end,
            desc = "Toggle Spectre",
        },
    },
}
