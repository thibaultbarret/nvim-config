local TAGS_ICON = "󰓹  " -- icône des tags dans l'aperçu papis
local TAGS_NS = vim.api.nvim_create_namespace("papis_preview_tags")
local TYPE_COLUMN = { "type", "%-13s ", "@type" } -- 13 = longueur de « inproceedings »

-- Tags d'une entrée sous forme de liste (papis accepte aussi une chaîne dans info.yaml)
local function tag_list(entry)
    if type(entry.tags) == "table" then
        return entry.tags
    end
    return entry.tags and { entry.tags } or {}
end

-- Champs exposés à la recherche snacks : « tags:mouchetis type:!software grédiac »
local function add_search_fields(item)
    local entry = item.entry or {}
    return vim.tbl_extend("force", item, { tags = table.concat(tag_list(entry), " "), type = entry.type })
end

-- Ligne après laquelle placer les tags : celle de la clé ref, sinon la fin de l'aperçu.
-- Recherche depuis la fin : la ligne ref suit auteur/titre, qui peuvent finir par la ref (MatchID)
local function tags_row(buf, ref)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i = #lines, 1, -1 do
        if ref and vim.endswith(lines[i], ref) then
            return i
        end
    end
    return #lines
end

-- Ajoute les tags, un par ligne, à l'aperçu déjà rendu par papis
local function show_tags(ctx)
    local buf = ctx.buf
    vim.api.nvim_buf_clear_namespace(buf, TAGS_NS, 0, -1)
    local tags = tag_list(ctx.item.entry)
    if #tags == 0 then
        return
    end
    local indent = string.rep(" ", vim.fn.strdisplaywidth(TAGS_ICON))
    local lines = {}
    for i, tag in ipairs(tags) do
        lines[i] = (i == 1 and TAGS_ICON or indent) .. tag
    end
    local row = tags_row(buf, ctx.item.entry.ref)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
    vim.bo[buf].modifiable = false
    vim.api.nvim_buf_set_extmark(buf, TAGS_NS, row, 0, { end_col = #TAGS_ICON, hl_group = "PapisPreviewKey" })
    for i, line in ipairs(lines) do
        local start = i == 1 and #TAGS_ICON or #indent
        -- PapisPreviewTag (gras seul) empilé sur la couleur de PapisPreviewValue
        local hl = { "PapisPreviewValue", "PapisPreviewTag" }
        vim.api.nvim_buf_set_extmark(buf, TAGS_NS, row + i - 1, start, { end_col = #line, hl_group = hl })
    end
end

-- Aperçu papis puis tags. Fonction fixe et non enveloppe : snacks peut appliquer `config` deux fois
local function preview_with_tags(ctx)
    require("papis.search.snacks").preview(ctx)
    show_tags(ctx)
end

-- Picker papis (mêmes actions que <leader>pp) limité aux documents portant exactement ce tag
local function search_tag(tag)
    Snacks.picker("Papis search", vim.tbl_extend("force", require("papis.search.snacks").opts, {
        title = "Papis · " .. tag,
        transform = function(item)
            return vim.list_contains(tag_list(item.entry), tag) and add_search_fields(item)
        end,
    }))
end

-- Liste des tags de la bibliothèque (nombre de documents entre parenthèses) ; Entrée → search_tag
local function pick_tag()
    local counts = {}
    for _, entry in ipairs(require("papis.search.picker_common").load_entries()) do
        for _, tag in ipairs(tag_list(entry)) do
            counts[tag] = (counts[tag] or 0) + 1
        end
    end
    local items = {}
    for tag, count in pairs(counts) do
        items[#items + 1] = { text = tag, count = count }
    end
    table.sort(items, function(a, b)
        return a.text < b.text
    end)
    Snacks.picker.pick({
        title = "Tags papis",
        items = items,
        matcher = { fuzzy = false },
        layout = { preset = "select" },
        format = function(item)
            return { { item.text }, { " (" .. item.count .. ")", "Comment" } }
        end,
        confirm = function(picker, item)
            picker:close()
            if item then
                search_tag(item.text)
            end
        end,
    })
end

return {
    {
        "jghauser/papis.nvim",
        dependencies = {
            "kkharji/sqlite.lua",
            "MunifTanjim/nui.nvim",
            "folke/snacks.nvim",
        },
        config = function()
            require("papis").setup({
                enable_keymaps = true,
                -- Bibliothèque d'essai ; remettre { "papis" } pour revenir à `these` (défaut papis),
                -- puis :Papis reload config et :Papis reload data
                papis_cmd_base = { "papis", "-l", "these-test" },
                init_filetypes = { "markdown", "norg", "yaml", "typst", "tex" },
            })
            -- setup() fusionne les listes indice par indice (restes du défaut) : on les remplace après coup.
            -- Liste : type en tête ; aperçu : tags retirés, ajoutés un par ligne par show_tags
            local search = require("papis.config").search
            local results = search.results_format
            search.results_format = { results[1], results[2], TYPE_COLUMN, unpack(results, 3) }
            search.preview_format = vim.tbl_filter(function(line)
                return line[1] ~= "tags"
            end, search.preview_format)
            -- Colonne notes : le défaut @comment.warning a un fond orange dans catppuccin,
            -- appliqué même aux lignes sans notes → trait orange vertical dans la liste
            vim.api.nvim_set_hl(0, "PapisResultsNotes", { link = "DiagnosticWarn" })
            vim.api.nvim_set_hl(0, "PapisPreviewTag", { bold = true }) -- tags de l'aperçu en gras
            -- Avec les raccourcis papis : mêmes buffers que <leader>pp (types de init_filetypes)
            require("papis.keymaps"):add_keymaps({
                search_tag = { mode = "n", lhs = "<leader>pt", rhs = pick_tag, opts = { desc = "Papis: chercher par tag" } },
            })
        end,
    },
    {
        "folke/snacks.nvim",
        opts = {
            picker = {
                sources = {
                    -- nom donné par papis à Snacks.picker("Papis search", …), pas son opts.source
                    ["Papis search"] = {
                        -- Recherche exacte : en floue, tags:mouchetis trouvait ces lettres
                        -- éparpillées dans les tags d'autres documents
                        matcher = { fuzzy = false },
                        transform = add_search_fields,
                        -- papis passe son propre preview (prioritaire sur la source) : on le remplace après fusion
                        config = function(opts)
                            return vim.tbl_extend("force", opts, { preview = preview_with_tags })
                        end,
                    },
                },
            },
        },
    },
}
