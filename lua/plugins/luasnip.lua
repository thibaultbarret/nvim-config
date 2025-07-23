return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",                -- Suivre les versions mineures
    build = "make install_jsregexp", -- Support des regex JavaScript

    dependencies = {
        "rafamadriz/friendly-snippets", -- Collection de snippets prêts à l'emploi
    },

    event = "InsertEnter", -- Chargement paresseux à l'insertion

    config = function()
        local ls = require("luasnip")
        local types = require("luasnip.util.types")
        --
        --         -- =========================================================================
        --         -- CONFIGURATION DE BASE
        --         -- =========================================================================
        --
        --         ls.config.set_config({
        --             -- Garder l'historique pour naviguer entre les snippets
        --             history = true,
        --
        --             -- Mise à jour des snippets en temps réel pendant la frappe
        --             updateevents = "TextChanged,TextChangedI",
        --
        --             -- Activer les snippets automatiques (sans trigger explicite)
        --             enable_autosnippets = true,
        --
        --             -- Supprimer les snippets automatiquement quand on sort
        --             delete_check_events = "TextChanged",
        --
        --             -- Style visuel des placeholders
        --             ext_opts = {
        --                 [types.choiceNode] = {
        --                     active = {
        --                         virt_text = { { " <- Choix actuel", "Comment" } },
        --                     },
        --                 },
        --                 [types.insertNode] = {
        --                     active = {
        --                         virt_text = { { " <- ", "NonTest" } },
        --                     },
        --                 },
        --             },
        --         })
        --
        --         -- =========================================================================
        --         -- CHARGEMENT DES SNIPPETS
        --         -- =========================================================================
        --
        --         -- Snippets VS Code (friendly-snippets)
        --         require("luasnip.loaders.from_vscode").lazy_load()
        --
        --         -- Vos snippets personnalisés (format Lua)
        --         require("luasnip.loaders.from_lua").load({
        --             paths = "~/.config/nvim/lua/snippets/"
        --         })
        --
        --         -- Optionnel: Snippets au format SnipMate
        --         -- require("luasnip.loaders.from_snipmate").lazy_load()
        --
        --         -- =========================================================================
        --         -- MAPPINGS POUR NAVIGATION
        --         -- =========================================================================
        --
        --         -- Expansion du snippet
        --         vim.keymap.set({ "i" }, "<C-K>", function()
        --             ls.expand()
        --         end, {
        --             silent = true,
        --             desc = "Expand snippet"
        --         })
        --
        --         -- Navigation vers le prochain placeholder
        --         vim.keymap.set({ "i", "s" }, "<C-L>", function()
        --             ls.jump(1)
        --         end, {
        --             silent = true,
        --             desc = "Jump to next placeholder"
        --         })
        --
        --         -- Navigation vers le placeholder précédent
        --         vim.keymap.set({ "i", "s" }, "<C-J>", function()
        --             ls.jump(-1)
        --         end, {
        --             silent = true,
        --             desc = "Jump to previous placeholder"
        --         })
        --
        --         -- Changer le choix dans un choiceNode
        --         vim.keymap.set({ "i", "s" }, "<C-E>", function()
        --             if ls.choice_active() then
        --                 ls.change_choice(1)
        --             end
        --         end, {
        --             silent = true,
        --             desc = "Change choice in snippet"
        --         })
        --
        --         -- =========================================================================
        --         -- COMMANDES UTILES POUR LE DÉVELOPPEMENT
        --         -- =========================================================================
        --
        --         -- Recharger les snippets (utile pendant le développement)
        --         vim.keymap.set("n", "<leader>sr", function()
        --             require("luasnip.loaders.from_lua").load({
        --                 paths = "~/.config/nvim/lua/snippets/"
        --             })
        --             vim.notify("Snippets rechargés!", vim.log.levels.INFO)
        --         end, { desc = "Reload snippets" })
        --
        --         -- Éditer les snippets du langage actuel
        --         vim.keymap.set("n", "<leader>se", function()
        --             local ft = vim.bo.filetype
        --             local snippet_file = vim.fn.stdpath("config") .. "/lua/snippets/" .. ft .. ".lua"
        --             vim.cmd("edit " .. snippet_file)
        --         end, { desc = "Edit snippets for current filetype" })
    end,
}
