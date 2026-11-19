return {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- @type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
        { "zk",     mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        { "Zk",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        { "fq",     mode = "o",               function() require("flash").remote() end, desc = "Remote Flash" },
        { "ft",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-b>",  mode = { "c" },           function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
}
