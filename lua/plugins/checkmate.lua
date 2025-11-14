return {
    "bngarren/checkmate.nvim",
    ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
    opts = {
        files = { "**/todo.md" }, -- any .md file (instead of defaults)
        enabled = true,
        notify = true,
        todo_count_formatter = function(completed, total)
            return string.format("[%.0f%%]", completed / total * 100)
        end,
        style = {
            CheckmateTodoCountIndicator = { fg = "#faef89" },
        },
    },
}
