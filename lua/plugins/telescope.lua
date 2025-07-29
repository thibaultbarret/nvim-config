return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
        'nvim-lua/plenary.nvim',
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        telescope.setup({
            defaults = {

                -- Parce que c'est joli
                prompt_prefix = " ",
                selection_caret = " ",
                path_display = { "smart" },
                file_ignore_patterns = { ".git/", "node_modules", "__pycache__", ".DS_Store" },

                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                    },
                },
                hidden = true
            },
            pickers = {
                find_files = {
                    hidden = true,
                    -- Vous pouvez aussi utiliser cette option pour find_files spécifiquement
                    find_command = { "rg", "--files", "--hidden", "--glob", "!**/__pycache__/**" },
                },
            },
        })

        telescope.load_extension("fzf")

        local map = vim.keymap.set
        map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })

        -- Git
        map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
        map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
        --
        -- Files
        map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
        map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
            { desc = "telescope find all files" })
    end,
}
