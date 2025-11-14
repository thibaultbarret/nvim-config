return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
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
    },

    event = { "InsertEnter", "CmdlineEnter" },

    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local types = require("luasnip.util.types")

        -- =================================================================
        -- CONFIGURATION LUASNIP
        -- =================================================================

        luasnip.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI",
            enable_autosnippets = true,
            delete_check_events = "TextChanged",
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
            -- AJOUT : active le mode de sélection visuelle pour les choiceNodes
            region_check_events = "CursorMoved,CursorHold,InsertEnter",
            store_selection_keys = "<Tab>",
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
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),

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
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                -- MODIFICATION : Mappings pour naviguer dans les choiceNodes
                ["<C-n>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<C-p>"] = cmp.mapping(function(fallback)
                    if luasnip.choice_active() then
                        luasnip.change_choice(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            }),

            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip", priority = 900, option = { show_autosnippets = true } },
                { name = "buffer", priority = 500 },
                {
                    name = "path",
                    priority = 200,
                    option = {
                        show_hidden_files_by_default = false,
                        trailing_slash = true,
                        label_trailing_slash = true,
                        get_cwd = function(params)
                            return vim.fn.expand(("#%d:p:h"):format(params.context.bufnr))
                        end,
                    },
                },
                { name = "vimtex" },
            }),

            experimental = {
                ghost_text = false,
            },

            duplicates = {
                nvim_lsp = 1,
                luasnip = 1,
                buffer = 1,
                path = 1,
            },

            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = function(entry, vim_item)
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

                    if entry.source.name == "path" then
                        local item = entry:get_completion_item()
                        local path = item.label
                        local cwd = vim.fn.expand(("#%d:p:h"):format(vim.api.nvim_get_current_buf()))
                        local resolved_path = vim.fn.fnamemodify(cwd .. "/" .. path, ":p")

                        local stat = nil
                        local success, result = pcall(vim.loop.fs_stat, resolved_path)
                        if success then
                            stat = result
                        end

                        if stat and stat.type == "directory" then
                            vim_item.kind = "󰉋 Folder"
                            vim_item.menu = "[Dir]"
                            local handle = vim.loop.fs_scandir(resolved_path)
                            if handle then
                                local count = 0
                                while vim.loop.fs_scandir_next(handle) do
                                    count = count + 1
                                    if count > 10 then
                                        break
                                    end
                                end
                                if count > 0 then
                                    vim_item.menu =
                                        string.format("[Dir %s items]", count > 10 and "10+" or tostring(count))
                                end
                            end
                        else
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
                        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
                        if entry.completion_item.detail then
                            vim_item.menu = entry.completion_item.detail
                        else
                            local source_names = {
                                luasnip = "[Snip]",
                                nvim_lsp = "[LSP]",
                                buffer = "[Buf]",
                                path = "[Path]",
                                vimtex = "[VimTeX]",
                            }
                            vim_item.menu = source_names[entry.source.name] or "[?]"
                        end
                    end

                    if string.len(vim_item.abbr) > 50 then
                        vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. "..."
                    end

                    return vim_item
                end,
            },

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

        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

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

        -- AJOUT : Fenêtre flottante pour afficher les choiceNodes
        local choice_popup = nil
        local choice_popup_buffer = nil

        local function show_choices_popup()
            if not luasnip.choice_active() then
                return
            end

            local choices = luasnip.get_current_choices()
            if not choices then
                return
            end

            -- Fermer la fenêtre précédente si elle existe
            if choice_popup and vim.api.nvim_win_is_valid(choice_popup) then
                vim.api.nvim_win_close(choice_popup, true)
            end

            -- Créer le buffer
            choice_popup_buffer = vim.api.nvim_create_buf(false, true)

            -- Préparer les lignes avec numérotation
            local lines = { "╭─ Choix disponibles ─╮" }
            for idx, choice in ipairs(choices) do
                local prefix = idx == 1 and "▶ " or "  "
                table.insert(lines, string.format("%s%d. %s", prefix, idx, choice))
            end
            table.insert(lines, "╰──────────────────────╯")
            table.insert(lines, "")
            table.insert(lines, "Ctrl+n/p pour naviguer")

            vim.api.nvim_buf_set_lines(choice_popup_buffer, 0, -1, false, lines)

            -- Calculer la largeur
            local width = 0
            for _, line in ipairs(lines) do
                width = math.max(width, vim.fn.strdisplaywidth(line))
            end
            width = math.min(width + 2, vim.o.columns - 4)

            -- Position de la fenêtre (au-dessus du curseur)
            local cursor_pos = vim.api.nvim_win_get_cursor(0)
            local row = cursor_pos[1] - #lines - 1
            if row < 0 then
                row = cursor_pos[1] + 1 -- En dessous si pas de place au-dessus
            end

            -- Créer la fenêtre flottante
            choice_popup = vim.api.nvim_open_win(choice_popup_buffer, false, {
                relative = "win",
                row = row,
                col = 0,
                width = width,
                height = #lines,
                style = "minimal",
                border = "rounded",
                focusable = false,
                zindex = 50,
            })

            -- Styling
            vim.api.nvim_win_set_option(choice_popup, "winblend", 10)
            vim.api.nvim_buf_set_option(choice_popup_buffer, "modifiable", false)

            -- Highlights
            vim.api.nvim_buf_add_highlight(choice_popup_buffer, -1, "Title", 0, 0, -1)
            vim.api.nvim_buf_add_highlight(choice_popup_buffer, -1, "Comment", #lines - 2, 0, -1)
            for i = 1, #choices do
                if i == 1 then
                    vim.api.nvim_buf_add_highlight(choice_popup_buffer, -1, "String", i, 0, -1)
                end
            end

            -- Fermer automatiquement après 3 secondes
            vim.defer_fn(function()
                if choice_popup and vim.api.nvim_win_is_valid(choice_popup) then
                    vim.api.nvim_win_close(choice_popup, true)
                end
            end, 3000)
        end

        -- Fonction pour fermer la popup manuellement
        local function close_choices_popup()
            if choice_popup and vim.api.nvim_win_is_valid(choice_popup) then
                vim.api.nvim_win_close(choice_popup, true)
                choice_popup = nil
            end
        end

        -- Keymap pour afficher la popup
        vim.keymap.set({ "i", "s" }, "<C-l>", show_choices_popup, { desc = "Afficher les choix LuaSnip" })

        -- Fermer la popup quand on change de choix
        vim.keymap.set({ "i", "s" }, "<C-n>", function()
            close_choices_popup()
            if luasnip.choice_active() then
                luasnip.change_choice(1)
                vim.defer_fn(show_choices_popup, 50)
            end
        end, { desc = "Choix suivant" })

        vim.keymap.set({ "i", "s" }, "<C-p>", function()
            close_choices_popup()
            if luasnip.choice_active() then
                luasnip.change_choice(-1)
                vim.defer_fn(show_choices_popup, 50)
            end
        end, { desc = "Choix précédent" })
    end,
}
