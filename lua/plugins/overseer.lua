return {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle", "OverseerBuild" },
    keys = {
        { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer: run" },
        { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Overseer: toggle" },
        { "<leader>oa", "<cmd>OverseerQuickAction<cr>", desc = "Overseer: action" },
    },
    opts = {
        strategy = "terminal",
        templates = { "builtin", "cpp.clang_build", "cpp.clang_run" },
        task_list = {
            direction = "bottom",
            min_height = 12,
            bindings = {
                ["<C-l>"] = "OpenOutput",
                ["<C-q>"] = "Close",
            },
        },
    },
}
