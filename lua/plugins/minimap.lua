return {
    "Isrothy/neominimap.nvim",
    version = "v3.x.x",
    lazy = false,
    keys = {
        -- Global Minimap Controls
        { "<leader>nm", "<cmd>Neominimap Toggle<cr>", desc = "Toggle global minimap" },
        -- { "<leader>no", "<cmd>Neominimap Enable<cr>", desc = "Enable global minimap" },
        -- { "<leader>nc", "<cmd>Neominimap Disable<cr>", desc = "Disable global minimap" },
        -- { "<leader>nr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh global minimap" },
        -- Window-Specific Minimap Controls
        -- { "<leader>nwt", "<cmd>Neominimap WinToggle<cr>", desc = "Toggle minimap for current window" },
        -- { "<leader>nwr", "<cmd>Neominimap WinRefresh<cr>", desc = "Refresh minimap for current window" },
        -- { "<leader>nwo", "<cmd>Neominimap WinEnable<cr>", desc = "Enable minimap for current window" },
        -- { "<leader>nwc", "<cmd>Neominimap WinDisable<cr>", desc = "Disable minimap for current window" },
        -- Tab-Specific Minimap Controls
        -- { "<leader>ntt", "<cmd>Neominimap TabToggle<cr>", desc = "Toggle minimap for current tab" },
        -- { "<leader>ntr", "<cmd>Neominimap TabRefresh<cr>", desc = "Refresh minimap for current tab" },
        -- { "<leader>nto", "<cmd>Neominimap TabEnable<cr>", desc = "Enable minimap for current tab" },
        -- { "<leader>ntc", "<cmd>Neominimap TabDisable<cr>", desc = "Disable minimap for current tab" },
        -- Buffer-Specific Minimap Controls
        -- { "<leader>nbt", "<cmd>Neominimap BufToggle<cr>", desc = "Toggle minimap for current buffer" },
        -- { "<leader>nbr", "<cmd>Neominimap BufRefresh<cr>", desc = "Refresh minimap for current buffer" },
        -- { "<leader>nbo", "<cmd>Neominimap BufEnable<cr>", desc = "Enable minimap for current buffer" },
        -- { "<leader>nbc", "<cmd>Neominimap BufDisable<cr>", desc = "Disable minimap for current buffer" },
        ---Focus Controls
        -- { "<leader>nf", "<cmd>Neominimap Focus<cr>", desc = "Focus on minimap" },
        -- { "<leader>nu", "<cmd>Neominimap Unfocus<cr>", desc = "Unfocus minimap" },
        { "<leader>ns", "<cmd>Neominimap ToggleFocus<cr>", desc = "Switch focus on minimap" },
    },
    init = function()
        vim.opt.sidescrolloff = 35
        -- vim.opt.scrolloff = 999

        vim.g.neominimap = {
            auto_enable = false,
            click = {
                enabled = true,
                auto_switch_focus = false, -- Garder le focus sur le fichier
            },
        }

        -- Timer pour vérifier et nettoyer toutes les fenêtres minimap
        local function clean_minimap_windows()
            vim.schedule(function()
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    local buf_name = vim.api.nvim_buf_get_name(buf)
                    local ft = vim.bo[buf].filetype

                    -- Vérifier par filetype ET par nom de buffer
                    if ft == "neominimap" or buf_name:match("neominimap") then
                        vim.wo[win].statuscolumn = ""
                        vim.wo[win].signcolumn = "no"
                        vim.wo[win].number = false
                        vim.wo[win].relativenumber = false
                        vim.wo[win].foldcolumn = "0"
                    end
                end
            end)
        end

        -- Multiples événements pour capturer toutes les situations
        vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter", "BufEnter", "WinNew" }, {
            callback = clean_minimap_windows,
        })

        -- Timer additionnel pour le premier chargement
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                vim.defer_fn(clean_minimap_windows, 100)
                vim.defer_fn(clean_minimap_windows, 300)
                vim.defer_fn(clean_minimap_windows, 500)
            end,
        })

        -- Autocommand pour mapper j et k dans la minimap
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "neominimap",
            callback = function(args)
                local buf = args.buf

                -- Fonction pour centrer dans le fichier principal
                local function center_main_window()
                    -- Trouver la fenêtre principale (non-minimap)
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local win_buf = vim.api.nvim_win_get_buf(win)
                        local ft = vim.bo[win_buf].filetype
                        if ft ~= "neominimap" then
                            -- Centrer cette fenêtre
                            vim.api.nvim_win_call(win, function()
                                vim.cmd("normal! zz")
                            end)
                            break
                        end
                    end
                end

                -- Remapper j
                vim.keymap.set("n", "j", function()
                    vim.cmd("normal! j")
                    vim.schedule(center_main_window)
                end, { buffer = buf, silent = true })

                -- Remapper k
                vim.keymap.set("n", "k", function()
                    vim.cmd("normal! k")
                    vim.schedule(center_main_window)
                end, { buffer = buf, silent = true })

                -- Pour <Down> et <Up>
                vim.keymap.set("n", "<Down>", function()
                    vim.cmd("normal! j")
                    vim.schedule(center_main_window)
                end, { buffer = buf, silent = true })

                vim.keymap.set("n", "<Up>", function()
                    vim.cmd("normal! k")
                    vim.schedule(center_main_window)
                end, { buffer = buf, silent = true })
            end,
        })
    end,
}
