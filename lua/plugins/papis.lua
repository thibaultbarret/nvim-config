local TAGS_ICON = "󰓹  " -- icône des tags dans l'aperçu papis
local TAGS_NS = vim.api.nvim_create_namespace("papis_preview_tags")
-- Étiquette de chaque type BibTeX dans la liste : libellé et groupe du thème dont on prend la couleur
local TYPE_LABELS = {
    article = { "Article", "Function" },
    phdthesis = { "Thèse", "Statement" },
    thesis = { "Thèse", "Statement" },
    mastersthesis = { "Mémoire", "Statement" },
    inproceedings = { "Conférence", "String" },
    conference = { "Conférence", "String" },
    proceedings = { "Actes", "String" },
    book = { "Livre", "Type" },
    inbook = { "Chapitre", "Type" },
    incollection = { "Chapitre", "Type" },
    software = { "Logiciel", "Constant" },
    dataset = { "Données", "Constant" },
    techreport = { "Rapport", "Special" },
    report = { "Rapport", "Special" },
    manual = { "Manuel", "Special" },
    patent = { "Brevet", "Special" },
    online = { "Web", "Comment" },
    misc = { "Divers", "Comment" },
    unpublished = { "Inédit", "Comment" },
}
local TYPE_WIDTH = 11 -- « Conférence » + une espace

-- Libellé et groupe de couleur d'un type ; type inconnu : son nom en gris ; type absent : vide
local function type_info(type_name)
    local known = TYPE_LABELS[type_name]
    if known then
        return known[1], "PapisType" .. known[2]
    end
    return type_name or "", "PapisTypeComment"
end

-- Couleur seule d'un groupe du thème, sans son gras ni son italique
local function fg_of(group)
    return vim.api.nvim_get_hl(0, { name = group, link = false }).fg
end

-- Tags d'une entrée sous forme de liste (papis accepte aussi une chaîne dans info.yaml)
local function tag_list(entry)
    if type(entry.tags) == "table" then
        return entry.tags
    end
    return entry.tags and { entry.tags } or {}
end

-- Champs exposés à la recherche snacks : « tags:mouchetis type:thèse type:!software grédiac »
local function add_search_fields(item)
    local entry = item.entry or {}
    local type_field = entry.type and entry.type .. " " .. type_info(entry.type) -- type BibTeX et étiquette
    return vim.tbl_extend("force", item, { tags = table.concat(tag_list(entry), " "), type = type_field })
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
        vim.api.nvim_buf_set_extmark(buf, TAGS_NS, row + i - 1, start, { end_col = #line, hl_group = "PapisPreviewTag" })
    end
end

-- Aperçu papis puis tags. Fonction fixe et non enveloppe : snacks peut appliquer `config` deux fois
local function preview_with_tags(ctx)
    require("papis.search.snacks").preview(ctx)
    show_tags(ctx)
end

-- Liste papis avec l'étiquette du type après les icônes fichiers/notes (toujours présentes : force_space)
local function format_with_type(item, picker)
    local segments = require("papis.search.snacks").format(item, picker)
    local label, hl = type_info(item.entry.type)
    -- largeur d'affichage et non d'octets : « Thèse » contient un caractère sur 2 octets
    local cell = { label .. string.rep(" ", TYPE_WIDTH - vim.fn.strdisplaywidth(label)), hl }
    return { segments[1], segments[2], cell, unpack(segments, 3) }
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
            -- Aperçu : tags retirés du format papis, show_tags les ajoute un par ligne
            local search = require("papis.config").search
            search.preview_format = vim.tbl_filter(function(line)
                return line[1] ~= "tags"
            end, search.preview_format)
            -- Colonne notes : le défaut @comment.warning a un fond orange dans catppuccin,
            -- appliqué même aux lignes sans notes → trait orange vertical dans la liste
            vim.api.nvim_set_hl(0, "PapisResultsNotes", { link = "DiagnosticWarn" })
            vim.api.nvim_set_hl(0, "PapisPreviewTag", { fg = fg_of("Statement"), bold = true }) -- tags : mauve, gras
            for _, label in pairs(TYPE_LABELS) do -- couvre aussi PapisTypeComment (types inconnus)
                vim.api.nvim_set_hl(0, "PapisType" .. label[2], { fg = fg_of(label[2]) })
            end
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
                        -- papis passe ses propres preview/format (prioritaires sur la source) : remplacés après fusion
                        config = function(opts)
                            return vim.tbl_extend("force", opts, { preview = preview_with_tags, format = format_with_type })
                        end,
                    },
                },
            },
        },
    },
}
