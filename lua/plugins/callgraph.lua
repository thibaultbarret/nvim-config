return {
    "mengq627/callgraph.nvim",
    cmd = { "Callout", "Callin" },
    keys = {
        { "<leader>co", "<cmd>Callout<CR>", desc = "Call graph: callees" },
        { "<leader>ci", "<cmd>Callin<CR>", desc = "Call graph: callers" },
    },
    opts = {}, -- optional, see below
}
