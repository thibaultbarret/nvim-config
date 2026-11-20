local TEMP_REGISTER = '"'
local BLOCKWISE = "\22"

-- Mode visuel actif à l'ouverture de neoclip (nil si ouvert en mode normal)
local pending_vmode = nil

-- Colle une entrée de neoclip via smart-paste (réindentation), puis restaure le registre.
-- En visuel, remplace la sélection. Tout est synchrone pour pouvoir restaurer le registre.
local function paste_entry(key)
    return function(opts)
        local vmode = pending_vmode
        pending_vmode = nil
        local saved = vim.fn.getreginfo(TEMP_REGISTER)
        vim.fn.setreg(TEMP_REGISTER, opts.entry.contents, opts.entry.regtype)
        if not vmode then
            require("smart-paste").paste({ register = TEMP_REGISTER, key = key })
        elseif vmode == "V" and opts.entry.regtype:sub(1, 1) ~= BLOCKWISE then
            -- shortcut: module interne de smart-paste (pas d'API visuelle publique), à revoir s'il change
            require("smart-paste.paste").do_visual_paste(TEMP_REGISTER, "P", vmode)
        else
            vim.cmd('normal! gv"' .. TEMP_REGISTER .. "P") -- P : ne remplit pas le registre
        end
        vim.fn.setreg(TEMP_REGISTER, saved)
    end
end

return {
    "AckslD/nvim-neoclip.lua",
    dependencies = { "kkharji/sqlite.lua" }, -- pour la persistance
    event = { "TextYankPost", "BufReadPost", "BufNewFile" }, -- chargé au premier yank, pas au démarrage
    config = function()
        require("neoclip").setup({
            history = 100000,
            enable_persistent_history = true, -- nécessite sqlite.lua
            continuous_sync = true,
            filter = nil,
            preview = true,
            default_register = '"', -- registre cible par défaut au paste
            content_spec_column = false,
            on_select = {
                move_to_front = false,
                close_telescope = true,
            },
            on_paste = {
                set_reg = false,
                move_to_front = false,
            },
            keys = {
                fzf = {
                    select = "ctrl-r", -- met l'entrée dans le registre sans coller
                    paste = false, -- remplacés par les collages réindentés ci-dessous
                    paste_behind = false,
                    custom = {
                        ["default"] = paste_entry("p"), -- Enter : colle après (ou remplace la sélection)
                        -- colle avant ; pas ctrl-P (= ctrl-p dans un terminal) ni alt-p (⌥ compose dans WezTerm)
                        ["ctrl-o"] = paste_entry("P"),
                    },
                },
            },
        })

        -- Ouvre l'historique via fzf-lua ; en visuel, l'entrée choisie remplace la sélection
        vim.keymap.set("n", "<leader>fy", function()
            pending_vmode = nil
            require("neoclip.fzf")()
        end, { desc = "Neoclip: yank history (fzf)" })
        vim.keymap.set("x", "<leader>fy", function()
            pending_vmode = vim.fn.mode()
            vim.cmd("normal! \27") -- quitte le visuel pour fixer les marques '< '>
            require("neoclip.fzf")()
        end, { desc = "Neoclip: replace selection from yank history" })
    end,
}
