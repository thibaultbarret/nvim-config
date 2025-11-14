return {
    {
        "github/copilot.vim",
        lazy = false,
        config = function() -- Mapping tab is already used in NvChad
            vim.g.copilot_no_tab_map = true -- Disable tab mapping
            vim.g.copilot_assume_mapped = true -- Assume that the mapping is already done
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        opts = {
            -- See Configuration section for options
        },
    },
}
