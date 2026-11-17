return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    lazy = true,
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local luasnip = require("luasnip")
        local types = require("luasnip.util.types")

        luasnip.config.set_config({
            -- Équivalent non déprécié de `history = true`
            keep_roots = true,
            link_roots = true,
            link_children = true,
            exit_roots = false,
            update_events = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            delete_check_events = "TextChanged",
            region_check_events = "CursorMoved,CursorHold,InsertEnter",
            cut_selection_keys = "<Tab>",
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { " <- Choix actuel", "Comment" } },
                        hl_group = "Visual",
                    },
                    passive = {
                        virt_text = { { " (choix disponible)", "Comment" } },
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { " <- Tapez ici", "Comment" } },
                    },
                },
            },
        })

        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({
            paths = vim.fn.stdpath("config") .. "/lua/snippets/",
        })

        -- <C-n>/<C-p> pour changer de choix sont gérés dans nvim-cmp.lua
        vim.keymap.set({ "i", "s" }, "<C-l>", function()
            require("config.luasnip_choice_popup").show()
        end, { desc = "Afficher les choix LuaSnip" })
    end,
}
