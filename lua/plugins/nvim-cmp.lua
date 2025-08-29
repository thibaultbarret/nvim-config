return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        -- "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-cmdLine",
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
            dependencies = {
                "rafamadriz/friendly-snippets",
            },
        },
        "saadparwaiz1/cmp_luasnip",
        -- Optionnel : pour une meilleure navigation de fichiers
        -- "nvim-telescope/telescope-file-browser.nvim",
    },

    event = { "InsertEnter", "CmdlineEnter" },

    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local types = require("luasnip.util.types")
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
                        virt_text = { { " <- Choix actuel ", "Comment" } },
                        -- Optionnel: surligner le choix actuel
                        hl_group = "Visual",
                    },
                    passive = {
                        virt_text = { { " (choix disponible)", "Comment" } },
                    },
                },
                [types.insertNode] = {
                    active = {
                        virt_text = { { " <- Tapez ici", "NonTest" } },
                    },
                },
            },
        })

        -- Chargement des snippets
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").load({
            paths = "~/.config/nvim/lua/snippets/",
        })

        cmp.setup({
            completion = {
                completeopt = "menu,menuone,noinsert",
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
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                -- Complete
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

                -- Navigation spéciale pour les dossiers
                ["<C-t>"] = cmp.mapping(function(fallback)
                    local entry = cmp.get_selected_entry()
                    if entry and entry.source.name == "path" then
                        -- Si Telescope est disponible, l'utiliser
                        local ok, _ = pcall(require, "telescope")
                        if ok then
                            local path = entry:get_completion_item().label
                            -- Vérifier si c'est un dossier
                            local stat = vim.loop.fs_stat(path)
                            if stat and stat.type == "directory" then
                                vim.cmd("Telescope file_browser path=" .. vim.fn.shellescape(path))
                            else
                                -- Si c'est un fichier, ouvrir le dossier parent
                                local parent = vim.fn.fnamemodify(path, ":h")
                                vim.cmd("Telescope file_browser path=" .. vim.fn.shellescape(parent))
                            end
                        else
                            fallback()
                        end
                    else
                        fallback()
                    end
                end, { "i" }),

                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif require("luasnip").jumpable(-1) then
                        require("luasnip").jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                -- Mappings spécifiques pour les choice_node
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(1) -- Choix suivant
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<C-p>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(-1) -- Choix précédent
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip", priority = 900, option = { show_autosnippets = true } },
                -- { name = "nvim_lsp_signature_help" },
                { name = "buffer", priority = 500 },
                {
                    name = "path",
                    priority = 200,
                    option = {
                        -- Affiche les fichiers cachés (optionnel)
                        show_hidden_files_by_default = false,
                        -- Ajoute un slash pour les dossiers
                        trailing_slash = true,
                        label_trailing_slash = true,
                        -- Fonction pour obtenir le répertoire de travail
                        get_cwd = function(params)
                            return vim.fn.expand(("#%d:p:h"):format(params.context.bufnr))
                        end,
                    },
                },
                { name = "vimtex" },
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
                fields = { "abbr", "kind", "menu" }, -- Ordre d'affichage
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

                    -- Gestion spéciale pour les chemins de fichiers
                    if entry.source.name == "path" then
                        local item = entry:get_completion_item()
                        local path = item.label

                        -- CORRECTION : Résoudre le chemin avant de vérifier s'il existe
                        local resolved_path = vim.fn.resolve(vim.fn.expand(path))

                        -- Protection contre les erreurs de fs_stat
                        local stat = nil
                        local success, result = pcall(vim.loop.fs_stat, resolved_path)
                        if success then
                            stat = result
                        end

                        if stat and stat.type == "directory" then
                            vim_item.kind = "󰉋 Folder"
                            vim_item.menu = "[Dir]"
                            -- Ajouter info sur le contenu du dossier avec protection d'erreur
                            local handle = vim.loop.fs_scandir(resolved_path)
                            if handle then
                                local count = 0
                                while vim.loop.fs_scandir_next(handle) do
                                    count = count + 1
                                    if count > 10 then
                                        break
                                    end -- Limiter le comptage
                                end
                                if count > 0 then
                                    vim_item.menu = string.format("[Dir %d items]", count > 10 and "10+" or count)
                                end
                            end
                        else
                            -- C'est un fichier, détecter le type par extension
                            local ext = vim.fn.fnamemodify(path, ":e"):lower()
                            local file_icons = {
                                lua = "󰢱",
                                js = "󰌞",
                                ts = "󰛦",
                                py = "󰌠",
                                html = "󰌝",
                                css = "󰌜",
                                json = "󰘦",
                                md = "󰍔",
                                txt = "󰈙",
                                pdf = "󰈦",
                                png = "󰋩",
                                jpg = "󰋩",
                                gif = "󰋩",
                                tex = "󰙩",
                            }

                            local file_icon = file_icons[ext] or "󰈙"
                            vim_item.kind = file_icon .. " File"
                            vim_item.menu = "[File]"
                        end
                    else
                        -- Icône selon le type pour les autres sources
                        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)

                        if entry.completion_item.detail then
                            vim_item.menu = entry.completion_item.detail
                        else
                            local source_names = {
                                luasnip = "[Snip]",
                                nvim_lsp = "[LSP]",
                                -- nvim_lsp_signature_help = "[Sig]",
                                buffer = "[Buf]",
                                path = "[Path]",
                                vimtex = "[VimTeX]",
                            }
                            vim_item.menu = source_names[entry.source.name] or "[?]"
                        end
                    end

                    -- Limiter la longueur
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
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
        })
        -- `/` complétion
        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

        -- `:` complétion avec path amélioré
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                {
                    name = "path",
                    option = {
                        trailing_slash = true,
                        label_trailing_slash = true,
                    },
                },
            }, {
                {
                    name = "cmdline",
                    option = {
                        ignore_cmds = { "Man", "!" },
                    },
                },
            }),
        })

        -- Mappings globaux utiles pour la navigation de fichiers
        vim.keymap.set("n", "<leader>fb", function()
            local ok, telescope = pcall(require, "telescope")
            if ok then
                vim.cmd("Telescope file_browser")
            else
                vim.cmd("edit .")
            end
        end, { desc = "File browser" })

        vim.keymap.set("n", "<leader>fB", function()
            local ok, telescope = pcall(require, "telescope")
            if ok then
                vim.cmd("Telescope file_browser path=%:p:h select_buffer=true")
            else
                vim.cmd("edit %:p:h")
            end
        end, { desc = "File browser (current directory)" })
    end,
}
