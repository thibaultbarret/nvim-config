local TERMINAL_HEIGHT = 15
local NUMBERED_TERMINALS = 5

-- <leader>; : terminal n°1 ; <leader>1 … <leader>5 : terminaux numérotés
local function terminal_keys()
    local keys = {
        {
            "<leader>;",
            function()
                Snacks.terminal.toggle(nil, { count = 1 })
            end,
            desc = "Terminal",
        },
    }
    for i = 1, NUMBERED_TERMINALS do
        table.insert(keys, {
            "<leader>" .. i,
            function()
                Snacks.terminal.toggle(nil, { count = i })
            end,
            desc = "Terminal " .. i,
        })
    end
    return keys
end

return {
    "folke/snacks.nvim",
    priority = 1000, -- charge tôt pour override vim.ui.input avant les autres plugins
    lazy = false,
    keys = terminal_keys(),
    ---@type snacks.Config
    opts = {
        -- Images (\includegraphics, Markdown) rendues dans Neovim, sans les formules.
        -- WezTerm ne gère pas l'affichage dans le buffer : Snacks utilise alors une
        -- fenêtre flottante, ouverte quand le curseur est sur l'image.
        -- Nécessite config.enable_kitty_graphics = true dans ~/.wezterm.lua.
        image = {
            enabled = true,
            doc = {
                float = true,
                max_width = 80,
                max_height = 40,
            },
            math = { enabled = false }, -- pas de rendu des formules LaTeX
        },
        -- Terminal (remplace nvim-terminal) : split en bas, raccourcis plus bas
        terminal = {
            win = { position = "bottom", height = TERMINAL_HEIGHT },
        },
        -- Picker (utilisé par papis). L'aperçu n'est pas une fenêtre minimale : il hérite
        -- de cursorcolumn (core/options.lua) et des « ~ » de fin de buffer.
        picker = {
            ui_select = false, -- déclarer picker l'active : garder le vim.ui.select natif
            win = { preview = { wo = { cursorcolumn = false, fillchars = "fold: ,eob: " } } },
        },
        input = {
            enabled = true,
            -- options propres à input (valeurs par défaut, à ajuster)
            icon = " ",
            icon_hl = "SnacksInputIcon",
            icon_pos = "left",
            prompt_pos = "title", -- prompt dans le titre de la fenêtre flottante
            expand = true, -- élargit la fenêtre au fur et à mesure de la saisie

            win = {
                style = "input",
                -- surcharge des keymaps par défaut du style "input"
                keys = {
                    n_esc = { "<esc>", "stopinsert", mode = "n", expr = true }, -- <Esc> en normal ne ferme plus
                    -- q     = false,  -- si tu veux libérer q en normal mode
                },
            },
        },
    },
}
