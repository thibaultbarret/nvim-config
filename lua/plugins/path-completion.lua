return {
    dir = "~/Documents/Programmation/Plugins_neovim/Path_completion",
    name = "path_completion",
    dependencies = {
        "ibhagwan/fzf-lua",
        "nvim-tree/nvim-web-devicons", -- ou "echasnovski/mini.icons"
    },
    keys = {
        {
            "<leader>ppf",
            function()
                require("path_completion").project({
                    kind = "file",
                })
            end,
            mode = { "n" },
            desc = "Chemin projet",
        },
        {
            "<leader>ppd",
            function()
                require("path_completion").project({ kind = "dir" })
            end,
            mode = { "n" },
            desc = "Chemin projet",
        },
        ---
        {
            "<leader>pbf",
            function()
                require("path_completion").buffer()
            end,
            mode = { "n" },
            desc = "Chemin fichier",
        },
        {
            "<leader>pfd",
            function()
                require("path_completion").system()
            end,
            mode = { "n" },
            desc = "Chemin système",
        },
    },
    config = function()
        require("path_completion").setup({
            -- icons = true par défaut ; mets false si tu ne veux pas de devicons
            fd_opts = "--color=never --hidden --exclude .git --exclude .env --exclude .snakemake",
        })
    end,
    -- chargement paresseux sur les commandes (optionnel) :
    cmd = { "PathCompleteProject", "PathCompleteBuffer", "PathCompleteSystem" },
}
