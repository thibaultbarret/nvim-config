return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status")

        lualine.setup({
            options = {
                icons_enabled = true,
                theme = "auto",
                -- Glyphes Powerline explicites (Nerd Font requis)
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true, -- ← nouvelle option
                globalstatus = true, -- ← recommandé sur Neovim 0.7+
                refresh = {
                    statusline = 100, -- ← défaut actuel du dépôt (était 1000)
                    tabline = 100,
                    winbar = 100,
                    refresh_time = 16, -- ← nouvelle sous-option (~60fps)
                    events = { -- ← nouvelle sous-option
                        "WinEnter",
                        "BufEnter",
                        "BufWritePost",
                        "SessionLoadPost",
                        "FileChangedShellPost",
                        "VimResized",
                        "Filetype",
                        "CursorMoved",
                        "CursorMovedI",
                        "ModeChanged",
                    },
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = {
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = { fg = "#ff9e64" },
                    },
                    { "encoding" },
                    { "filetype" },
                },
                lualine_y = { "progress" }, -- ← remplace "location" (plus standard)
                lualine_z = { "location" }, -- ← ligne:colonne ici, total lignes retiré
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = {},
        })
    end,
}
