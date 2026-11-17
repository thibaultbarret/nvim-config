local MAX_ABBR_WIDTH = 50
local MAX_MENU_WIDTH = 30
local MAX_BUFFER_SIZE = 1024 * 1024 -- 1 Mo : au-delà, le buffer n'alimente pas la source "buffer"

local KIND_ICONS = {
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

local SOURCE_NAMES = {
    luasnip = "[Snip]",
    nvim_lsp = "[LSP]",
    buffer = "[Buf]",
    path = "[Path]",
}

local function truncate(text, max_width)
    if vim.fn.strdisplaywidth(text) <= max_width then
        return text
    end
    return vim.fn.strcharpart(text, 0, max_width - 1) .. "…"
end

-- Buffers listés et de taille raisonnable (exclut terminaux, logs, nofile…)
local function completion_buffers()
    return vim.tbl_filter(function(bufnr)
        if not vim.bo[bufnr].buflisted or vim.bo[bufnr].buftype ~= "" then
            return false
        end
        local size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
        return size <= MAX_BUFFER_SIZE
    end, vim.api.nvim_list_bufs())
end

local function format_entry(entry, vim_item)
    local detail = entry.source.name == "nvim_lsp" and entry.completion_item.detail or nil
    vim_item.kind = string.format("%s %s", KIND_ICONS[vim_item.kind] or "", vim_item.kind or "")
    vim_item.menu = truncate(detail or SOURCE_NAMES[entry.source.name] or "[?]", MAX_MENU_WIDTH)
    vim_item.abbr = truncate(vim_item.abbr, MAX_ABBR_WIDTH)
    return vim_item
end

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "L3MON4D3/LuaSnip", -- configuré dans lua/plugins/luasnip.lua
        "saadparwaiz1/cmp_luasnip",
    },

    event = { "InsertEnter", "CmdlineEnter" },

    -- Déclare les capacités de complétion de cmp à tous les serveurs LSP.
    -- Fait dans `init` (au démarrage) pour que les serveurs lancés avant la
    -- première entrée en insertion en profitent aussi. Ne charge pas nvim-cmp.
    init = function()
        vim.lsp.config("*", {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })
    end,

    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local choice_popup = require("config.luasnip_choice_popup")

        -- <C-n>/<C-p> : change le choix LuaSnip actif, sinon navigue dans le menu
        local function choice_or_select(direction)
            return cmp.mapping(function(fallback)
                if luasnip.choice_active() then
                    choice_popup.change(direction)
                elseif cmp.visible() then
                    if direction > 0 then
                        cmp.select_next_item()
                    else
                        cmp.select_prev_item()
                    end
                else
                    fallback()
                end
            end, { "i", "s" })
        end

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

                -- <Tab>/<S-Tab> : uniquement LuaSnip (expansion + sauts), jamais le menu.
                -- Menu : <C-j>/<C-k> pour naviguer, <CR> pour valider.
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.expandable() then
                        cmp.close()
                        luasnip.expand()
                    elseif luasnip.locally_jumpable(1) then
                        cmp.close()
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if luasnip.locally_jumpable(-1) then
                        cmp.close()
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),

                ["<C-n>"] = choice_or_select(1),
                ["<C-p>"] = choice_or_select(-1),
            }),

            sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip", priority = 900, option = { show_autosnippets = true } },
                {
                    name = "buffer",
                    priority = 500,
                    option = { get_bufnrs = completion_buffers },
                },
                {
                    name = "path",
                    priority = 200,
                    option = {
                        trailing_slash = true,
                        label_trailing_slash = true,
                        get_cwd = function(params)
                            return vim.fn.expand(("#%d:p:h"):format(params.context.bufnr))
                        end,
                    },
                },
            }),

            experimental = {
                ghost_text = false,
            },

            formatting = {
                fields = { "abbr", "kind", "menu" },
                format = format_entry,
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

        cmp.setup.cmdline({ "/", "?" }, {
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
    end,
}
