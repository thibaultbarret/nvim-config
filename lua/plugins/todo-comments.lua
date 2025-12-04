return {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>tdt", "<cmd>TodoFzfLua<CR>", { desc = "Todo Telescope" } },
        { "<leader>tdl", "<cmd>TodoQuickFix<CR>", { desc = "Todo QuickFix" } },
        {
            "]t",
            function()
                require("todo-comments").jump_next()
            end,
            desc = "Next todo",
        },
        {
            "[t",
            function()
                require("todo-comments").jump_prev()
            end,
            desc = "Previous todo",
        },
    },

    config = function()
        local todo_comments = require("todo-comments")

        todo_comments.setup({
            signs = true,
            keywords = {
                FIGURE = { icon = "📊", color = "#F54927", alt = { "FIG", "DIAGRAM", "CHART" } },
            },
        })
    end,
}
