return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")

        fzf.setup({
            -- Configuration globale
            winopts = {
                height = 0.85,
                width = 0.80,
                row = 0.35,
                col = 0.50,
                border = "rounded",
                preview = {
                    layout = "flex",
                    flip_columns = 120,
                },
            },
            -- Fichiers à ignorer
            files = {
                prompt = " ",
                file_ignore_patterns = { ".git/", "node_modules", "__pycache__", ".DS_Store" },
                -- Pour inclure les fichiers cachés par défaut
                fd_opts = [[--color=never --type f --hidden --follow --exclude .git --exclude __pycache__]],
            },
            grep = {
                prompt = " ",
            },
        })

        local map = vim.keymap.set

        local function get_visual_selection()
            -- Sauvegarder le registre actuel
            local saved_reg = vim.fn.getreg('"')
            local saved_regtype = vim.fn.getregtype('"')

            -- Copier la sélection dans le registre
            vim.cmd('normal! "xy')
            local selection = vim.fn.getreg("x")

            -- Restaurer le registre
            vim.fn.setreg('"', saved_reg, saved_regtype)

            return selection
        end

        -- Recherche de fichiers
        map("n", "<leader>ff", fzf.files, { desc = "fzf find files" })
        map("n", "<leader>fa", function()
            fzf.files({
                fd_opts = [[--color=never --type f --hidden --follow --no-ignore]],
            })
        end, { desc = "fzf find all files (no ignore)" })

        map("v", "<leader>FF", function()
            local selection = get_visual_selection()
            require("fzf-lua").files({
                query = selection,
                fd_opts = [[--color=never --type f --hidden --follow --no-ignore]],
            })
        end, { desc = "Rechercher fichiers avec sélection" })

        map("v", "<leader>fW", function()
            local selection = get_visual_selection()
            require("fzf-lua").grep({ search = selection })
        end, { desc = "Rechercher la sélection avec fzf-lua" })

        -- Grep/recherche de texte
        map("n", "<leader>fw", fzf.live_grep, { desc = "fzf live grep" })

        -- Git
        map("n", "<leader>cm", fzf.git_commits, { desc = "fzf git commits" })
        map("n", "<leader>gt", fzf.git_status, { desc = "fzf git status" })

        -- File browser (équivalent)
        map("n", "<leader>fb", function()
            fzf.files({ cwd = vim.fn.getcwd() })
        end, { desc = "fzf file browser" })

        map("n", "<leader>fB", function()
            fzf.files({ cwd = vim.fn.expand("%:p:h") })
        end, { desc = "fzf files (current file directory)" })

        -- Recherche dans $HOME
        map("n", "<leader>fh", function()
            fzf.files({
                cwd = vim.fn.expand("$HOME"),
                prompt = "Find Files in $HOME> ",
            })
        end, { desc = "Find files in $HOME directory" })

        -- File browser pour la thèse
        map("n", "<leader>bt", function()
            fzf.files({
                cwd = vim.fn.expand("$HOME/Documents/THESE/"),
                prompt = "Browse THESE> ",
            })
        end, { desc = "Browse files in THESE directory" })

        map("n", "<leader>ft", function()
            fzf.files({
                cwd = vim.fn.expand("$HOME/Documents/THESE/"),
                prompt = "Find Files in THESE> ",
            })
        end, { desc = "Find files in THESE directory" })

        -- Recherche dans un répertoire personnalisé
        map("n", "<leader>fd", function()
            local dir = vim.fn.input("Directory: ", vim.fn.getcwd() .. "/", "dir")
            if dir and dir ~= "" then
                fzf.files({ cwd = dir })
            end
        end, { desc = "Find files in directory" })

        map("n", "<leader>bd", function()
            local dir = vim.fn.input("Browse Directory: ", vim.fn.getcwd() .. "/", "dir")
            if dir and dir ~= "" then
                fzf.files({
                    cwd = dir,
                    prompt = "Browse " .. dir .. "> ",
                })
            end
        end, { desc = "Browse custom directory" })

        map("n", "<leader>ftex", function()
            fzf.files({
                prompt = " TeX Files> ",
                fd_opts = [[--color=never --type f --hidden --follow --exclude .git --extension tex]],
            })
        end, { desc = "Find .tex files" })

        -- Buffers, oldfiles, etc. (bonus)
        map("n", "<leader>bb", fzf.buffers, { desc = "fzf buffers" })
        map("n", "<leader>fo", fzf.oldfiles, { desc = "fzf old files" })
        map("n", "<leader>fh", fzf.help_tags, { desc = "fzf help tags" })
    end,
}
