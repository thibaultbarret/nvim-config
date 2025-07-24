return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
            dependencies = {
                "rafamadriz/friendly-snippets",
            },
        },
        "saadparwaiz1/cmp_luasnip",
    },

    event = "InsertEnter",

    config = function()
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local types = require('luasnip.util.types')
        --
        -- =================================================================
        -- CONFIGURATION LUASNIP
        -- =================================================================

        -- Configuration de LuaSnip
        luasnip.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            delete_check_events = "TextChanged",
            ext_opts = {
                [types.choiceNode] = {
                    active = {
                        virt_text = { { " <- Choix actuel", "Comment" } },
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { " <- ", "NonTest" } },
                    },
                },
            },
        })

        -- Chargement des snippets
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({
            paths = "~/.config/nvim/lua/snippets/"
        })

        cmp.setup({
            completion = {
                completeopt = "menu,menuone, noinsert",
            },
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                -- Choix
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                -- Deplacement dans la doc
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                -- Complete
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),

                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif require("luasnip").jumpable(-1) then
                        require("luasnip").jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = 'luasnip' },
                { name = 'nvim_lsp' },
            }, {
                { name = 'buffer' },
                { name = 'path' },
            }),
            -- Configuration pour éviter les doublons
            experimental = {
                ghost_text = false, -- Désactive le texte fantôme si problématique
            },

            -- Filtrage des doublons
            duplicates = {
                nvim_lsp = 1,
                luasnip = 1,
                buffer = 1,
                path = 1,
            },

            -- Formatage des items dans le menu
            formatting = {
                fields = { "kind", "abbr", "menu" }, -- Ordre d'affichage
                format = function(entry, vim_item)
                    -- Ajouter des icônes pour identifier les sources
                    local kind_icons = {
                        Text = "󰉿",
                        Method = "󰆧",
                        Function = "󰊕",
                        Constructor = "",
                        Field = "󰜢",
                        Variable = "󰀫",
                        Class = "󰠱",
                        Interface = "",
                        Module = "",
                        Property = "󰜢",
                        Unit = "󰑭",
                        Value = "󰎠",
                        Enum = "",
                        Keyword = "󰌋",
                        Snippet = "",
                        Color = "󰏘",
                        File = "󰈙",
                        Reference = "󰈇",
                        Folder = "󰉋",
                        EnumMember = "",
                        Constant = "󰏿",
                        Struct = "󰙅",
                        Event = "",
                        Operator = "󰆕",
                        TypeParameter = "",
                    }

                    -- Icône selon le type
                    vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or "", vim_item.kind)

                    -- Source du menu avec couleur pour distinguer
                    local source_names = {
                        luasnip = "[Snip]",
                        nvim_lsp = "[LSP]",
                        buffer = "[Buf]",
                        path = "[Path]",
                    }
                    vim_item.menu = source_names[entry.source.name] or "[?]"

                    -- Limiter la longueur pour éviter les débordements
                    if string.len(vim_item.abbr) > 50 then
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. "..."
                    end

                    return vim_item
                end,
            },

            -- Performance et filtrage
            performance = {
                debounce = 60,
                throttle = 30,
                fetching_timeout = 500,
                confirm_resolve_timeout = 80,
                async_budget = 1,
                max_view_entries = 200,
            },
        })
    end,
}
