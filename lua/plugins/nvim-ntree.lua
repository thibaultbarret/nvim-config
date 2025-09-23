return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            view = {
                width = 50,
                side = "left",
            },
            renderer = {
                group_empty = false,
                highlight_git = true,
                full_name = true,
                highlight_opened_files = "none",
                root_folder_label = ":~:s?$?/..?",
                indent_width = 2,
                indent_markers = {
                    enable = true,
                    inline_arrows = false,
                    icons = {
                        corner = "└", -- Ajout d'un tiret
                        none = " ",
                        edge = "│", -- Espace pour aligner
                        item = "├", -- Ajout d'un tiret
                        bottom = "─",
                    },
                },
                icons = {
                    webdev_colors = true,
                    git_placement = "after",
                    symlink_arrow = " ➛ ",
                    padding = " ",
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                    },
                },
            },
            filters = {
                dotfiles = false,
                git_clean = false,
                custom = {
                    "^.git$",
                    ".DS_Store",
                    "__pycache__",
                },
            },
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")

                -- Charge tous les mappings par défaut
                api.config.mappings.default_on_attach(bufnr)

                -- Ajoute le mapping personnalisé pour 'cd'
                vim.keymap.set("n", "cd", api.tree.change_root_to_node, {
                    desc = "CD (Change Root)",
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    nowait = true,
                })
            end,
        })
        vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
    end,
}
