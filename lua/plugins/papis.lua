-- Catégories de classement (tags abandonnés) : champs liste de info.yaml, déclarés aussi dans
-- ~/.config/papis/config (même ordre). Ordre d'affichage dans l'aperçu et les sélecteurs.
-- Familles : champs plats préfixés (essai_*, loi_*…), rangés sous le titre de leur groupe (à garder contigus)
local LOGICIEL = { title = "Logiciels", short = "Logiciel" }
local ESSAI = { title = "Essai", short = "Essai" }
local MESURE = { title = "Mesure de champs", short = "Mesure" }
local IDENTIF = { title = "Identification inverse", short = "Identif." }
local LOI = { title = "Loi de comportement", short = "Loi" }
local CATEGORIES = {
    { key = "etude_biblio", label = "Étude biblio" },
    { key = "apport", label = "Apport" },
    { key = "materiaux", label = "Matériau" },
    { key = "logiciels_ef", label = "Éléments finis", group = LOGICIEL },
    { key = "logiciels_cin", label = "CIN", group = LOGICIEL },
    { key = "logiciels_loi", label = "Lois", group = LOGICIEL },
    { key = "essai_homogene", label = "Homogène", group = ESSAI },
    { key = "essai_heterogene", label = "Hétérogène", group = ESSAI },
    { key = "essai_temperature", label = "Température", group = ESSAI },
    { key = "essai_vitesse", label = "Vitesse", group = ESSAI },
    { key = "essai_moyen", label = "Moyen", group = ESSAI },
    { key = "essai_trajet", label = "Trajet", group = ESSAI },
    { key = "mesure", label = "Méthode", group = MESURE },
    { key = "mesure_cin", label = "CIN", group = MESURE },
    { key = "identification", label = "Méthode", group = IDENTIF },
    { key = "identification_analyse", label = "Analyse", group = IDENTIF },
    { key = "loi_critere", label = "Critère", group = LOI },
    { key = "loi_ecrouissage", label = "Écrouissage", group = LOI },
    { key = "loi_vitesse", label = "Vitesse", group = LOI },
    { key = "loi_temperature", label = "Température", group = LOI },
    { key = "loi_trajet", label = "Trajet", group = LOI },
    { key = "loi_endommagement", label = "Endommagement", group = LOI },
    { key = "donnees", label = "Données" },
}

-- Raccourcis <leader>pc + touche : sélecteur limité à une famille (champ exact ou préfixe « famille_ »)
local CATEGORY_KEYMAPS = {
    { "b", "etude_biblio", "étude bibliographique" },
    { "a", "apport", "apport" },
    { "m", "materiaux", "matériaux" },
    { "s", "logiciels", "logiciels" },
    { "e", "essai", "essai" },
    { "c", "mesure", "mesure de champs" },
    { "i", "identification", "identification inverse" },
    { "l", "loi", "loi de comportement" },
    { "d", "donnees", "données extraites" },
}

-- Catégorie de la famille : mesure → mesure, mesure_cin ; loi → loi_* ; famille nil → toutes
local function in_family(cat, family)
    return family == nil or cat.key == family or vim.startswith(cat.key, family .. "_")
end

-- Libellé dans l'aperçu : sous-catégorie en retrait sous le titre du groupe
local function preview_label(cat)
    return cat.group and "  " .. cat.label or cat.label
end

-- Libellé dans le sélecteur, sans titre de groupe : « Loi · Vitesse » ≠ « Essai · Vitesse »
local function picker_label(cat)
    return cat.group and cat.group.short .. " · " .. cat.label or cat.label
end

-- Largeur d'affichage du plus long libellé + une espace (« É » occupe 2 octets pour 1 colonne)
local function label_width(label_of)
    local width = 0
    for _, cat in ipairs(CATEGORIES) do
        width = math.max(width, vim.fn.strdisplaywidth(label_of(cat)))
    end
    return width + 1
end
local PREVIEW_WIDTH = label_width(preview_label)
local PICKER_WIDTH = label_width(picker_label)
local CATEGORIES_NS = vim.api.nvim_create_namespace("papis_preview_categories")
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

-- Valeurs d'une catégorie sous forme de liste (papis accepte aussi une chaîne dans info.yaml)
local function field_list(entry, key)
    local value = entry[key]
    if type(value) == "table" then
        return value
    end
    return value and { value } or {}
end

-- Champs exposés à la recherche snacks : « etude_biblio:mouchetis loi_critere:Hill48 type:thèse type:!software grédiac ».
-- Les valeurs des catégories sont aussi ajoutées au texte cherché sans préfixe
local function add_search_fields(item)
    local entry = item.entry or {}
    local fields = { type = entry.type and entry.type .. " " .. type_info(entry.type) } -- type BibTeX et étiquette
    local text = { item.text or "", entry.ref } -- clé affichée dans la liste : cherchable aussi
    for _, cat in ipairs(CATEGORIES) do
        fields[cat.key] = table.concat(field_list(entry, cat.key), " ")
        text[#text + 1] = fields[cat.key]
    end
    fields.text = table.concat(text, " ")
    return vim.tbl_extend("force", item, fields)
end

-- Libellé complété à `width` colonnes (largeur d'affichage, pas en octets)
local function padded(label, width)
    return label .. string.rep(" ", width - vim.fn.strdisplaywidth(label))
end

-- Lignes d'aperçu, une par valeur ; libellé de la catégorie devant sa première valeur,
-- titre du groupe avant sa première sous-catégorie renseignée.
-- prefix_len[i] : longueur en octets du libellé, titre ou retrait de la ligne i
local function category_lines(entry)
    local lines, prefix_len = {}, {}
    local function add(prefix, value)
        lines[#lines + 1] = prefix .. value
        prefix_len[#prefix_len + 1] = #prefix
    end
    local shown_group
    for _, cat in ipairs(CATEGORIES) do
        local values = field_list(entry, cat.key)
        if #values > 0 and cat.group and cat.group ~= shown_group then
            add(cat.group.title, "")
            shown_group = cat.group
        end
        for i, value in ipairs(values) do
            add(i == 1 and padded(preview_label(cat), PREVIEW_WIDTH) or string.rep(" ", PREVIEW_WIDTH), value)
        end
    end
    return lines, prefix_len
end

-- Ajoute les catégories à la fin de l'aperçu déjà rendu par papis
local function show_categories(ctx)
    local buf = ctx.buf
    vim.api.nvim_buf_clear_namespace(buf, CATEGORIES_NS, 0, -1)
    local lines, prefix_len = category_lines(ctx.item.entry)
    if #lines == 0 then
        return
    end
    local row = vim.api.nvim_buf_line_count(buf)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
    vim.bo[buf].modifiable = false
    for i, line in ipairs(lines) do
        local r = row + i - 1
        vim.api.nvim_buf_set_extmark(
            buf,
            CATEGORIES_NS,
            r,
            0,
            { end_col = prefix_len[i], hl_group = "PapisPreviewKey" }
        )
        vim.api.nvim_buf_set_extmark(
            buf,
            CATEGORIES_NS,
            r,
            prefix_len[i],
            { end_col = #line, hl_group = "PapisPreviewCategory" }
        )
    end
end

-- Initiales d'un prénom : « Jean-Pierre » → « J.-P. », « Émile » → « É. », « F » → « F. »
-- (premier caractère UTF-8 de chaque partie, le reste de la partie jusqu'à l'espace ou au tiret est retiré)
local function initials(given)
    return (given:gsub("([^%s%-][\128-\191]*)[^%s%-]*", "%1."))
end

-- Auteurs « Nom I., Nom I. » depuis author_list ; champ author brut si la liste manque
local function short_authors(entry)
    if not entry.author_list or #entry.author_list == 0 then
        return entry.author
    end
    return table.concat(
        vim.tbl_map(function(a)
            local given = a.given and a.given ~= "" and " " .. initials(a.given) or ""
            return (a.family or "") .. given
        end, entry.author_list),
        ", "
    )
end

-- Aperçu papis puis catégories. Fonction fixe et non enveloppe : snacks peut appliquer `config` deux fois.
-- Champ authors_short (« author » serait réduit aux noms de famille par papis)
local function preview_with_categories(ctx)
    local entry = vim.tbl_extend("force", ctx.item.entry, { authors_short = short_authors(ctx.item.entry) })
    require("papis.search.picker_common").create_preview(entry, ctx.buf, ctx.win)
    show_categories(ctx)
end

-- Liste papis avec l'étiquette du type après les icônes fichiers/notes (toujours présentes : force_space)
local function format_with_type(item, picker)
    local segments = require("papis.search.snacks").format(item, picker)
    local label, hl = type_info(item.entry.type)
    -- largeur d'affichage et non d'octets : « Thèse » contient un caractère sur 2 octets
    local cell = { label .. string.rep(" ", TYPE_WIDTH - vim.fn.strdisplaywidth(label)), hl }
    return { segments[1], segments[2], cell, unpack(segments, 3) }
end

-- Picker papis (mêmes actions que <leader>pp) limité aux documents dont l'entrée vérifie keep
local function search_papis(title, keep)
    Snacks.picker(
        "Papis search",
        vim.tbl_extend("force", require("papis.search.snacks").opts, {
            title = "Papis · " .. title,
            transform = function(item)
                return keep(item.entry) and add_search_fields(item)
            end,
        })
    )
end

-- Documents ayant exactement cette valeur dans la catégorie
local function search_category(cat, value)
    search_papis(picker_label(cat) .. " · " .. value, function(entry)
        return vim.list_contains(field_list(entry, cat.key), value)
    end)
end

-- Sélecteur des types présents (Article, Thèse…) avec leur nombre ; Entrée → documents de ce type.
-- Regroupe par étiquette : thesis et phdthesis donnent « Thèse »
local function pick_type()
    local counts, hls = {}, {}
    for _, entry in ipairs(require("papis.search.picker_common").load_entries()) do
        local label, hl = type_info(entry.type)
        counts[label], hls[label] = (counts[label] or 0) + 1, hl
    end
    local labels = vim.tbl_keys(counts)
    table.sort(labels)
    Snacks.picker.pick({
        title = "Types papis",
        items = vim.tbl_map(function(label)
            return { text = label, label = label, count = counts[label], hl = hls[label] }
        end, labels),
        layout = { preset = "select" },
        format = function(item)
            return {
                { item.label == "" and "Sans type" or item.label, item.hl },
                { " (" .. item.count .. ")", "Comment" },
            }
        end,
        confirm = function(picker, item)
            picker:close()
            if item then
                search_papis(item.label == "" and "Sans type" or item.label, function(entry)
                    return type_info(entry.type) == item.label
                end)
            end
        end,
    })
end

-- Valeurs d'une catégorie dans la bibliothèque, triées, et leur nombre de documents
local function value_counts(entries, key)
    local counts = {}
    for _, entry in ipairs(entries) do
        for _, value in ipairs(field_list(entry, key)) do
            counts[value] = (counts[value] or 0) + 1
        end
    end
    local values = vim.tbl_keys(counts)
    table.sort(values)
    return values, counts
end

-- Paires (catégorie de la famille, valeur) présentes dans la bibliothèque avec leur nombre de
-- documents, triées dans l'ordre de CATEGORIES puis par valeur
local function category_items(family)
    local entries = require("papis.search.picker_common").load_entries()
    local items = {}
    for _, cat in
        ipairs(vim.tbl_filter(function(c)
            return in_family(c, family)
        end, CATEGORIES))
    do
        local values, counts = value_counts(entries, cat.key)
        for _, value in ipairs(values) do
            items[#items + 1] =
                { text = picker_label(cat) .. " " .. value, cat = cat, value = value, count = counts[value] }
        end
    end
    return items
end

-- Sélecteur « catégorie valeur (nombre) », filtrable (« essai », « loi swift ») ; Entrée → search_category.
-- family (facultatif) : famille de CATEGORY_KEYMAPS ; title : nom affiché de la famille
local function pick_category(family, title)
    Snacks.picker.pick({
        title = "Catégories papis" .. (title and " · " .. title or ""),
        items = category_items(family),
        matcher = { fuzzy = false },
        layout = { preset = "select" },
        format = function(item)
            return {
                { padded(picker_label(item.cat), PICKER_WIDTH), "PapisPreviewKey" },
                { item.value },
                { " (" .. item.count .. ")", "Comment" },
            }
        end,
        confirm = function(picker, item)
            picker:close()
            if item then
                search_category(item.cat, item.value)
            end
        end,
    })
end

-- Source cmp des info.yaml : en début de ligne, catégories absentes du fichier (« loi_ » → loi_ecrouissage…) ;
-- après « - » (ou « clé: ») sous une catégorie, valeurs déjà utilisées dans la bibliothèque pour celle-ci.
-- Valeurs lues dans la base papis.nvim : celles du fichier en cours y entrent à son enregistrement
local CATEGORY_BY_KEY = {}
for _, cat in ipairs(CATEGORIES) do
    CATEGORY_BY_KEY[cat.key] = cat
end

local function yaml_key(line)
    return line:match("^([%w_]+):")
end

-- Clé de premier niveau dont dépend la ligne row : elle-même ou la dernière clé au-dessus
local function owner_key(lines, row)
    for i = row, 1, -1 do
        local key = yaml_key(lines[i])
        if key then
            return key
        end
    end
end

local function key_items(lines)
    local present = {}
    for _, line in ipairs(lines) do
        present[yaml_key(line) or ""] = true
    end
    local kind = require("cmp").lsp.CompletionItemKind.Field
    return vim.iter(CATEGORIES)
        :filter(function(cat)
            return not present[cat.key]
        end)
        :map(function(cat)
            return { label = cat.key, insertText = cat.key .. ":\n  - ", kind = kind, detail = picker_label(cat) }
        end)
        :totable()
end

local function value_items(cat)
    local values, counts = value_counts(require("papis.search.picker_common").load_entries(), cat.key)
    local kind = require("cmp").lsp.CompletionItemKind.Value
    return vim.tbl_map(function(value)
        return { label = value, kind = kind, detail = picker_label(cat) .. " · " .. counts[value] .. " doc." }
    end, values)
end

local category_source = {}

function category_source:is_available()
    return vim.fs.basename(vim.api.nvim_buf_get_name(0)) == "info.yaml"
end

function category_source:get_trigger_characters()
    return { " " }
end

function category_source:complete(request, callback)
    local ctx = request.context
    local before = ctx.cursor_before_line
    local lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false)
    if before:match("^[%w_]*$") then
        return callback(key_items(lines))
    end
    local in_value = before:match("^%s*%-%s") or before:match("^[%w_]+:%s")
    local cat = in_value and CATEGORY_BY_KEY[owner_key(lines, ctx.cursor.row) or ""]
    callback(cat and value_items(cat) or {})
end

-- Après une catégorie insérée (avec « - » à la ligne suivante) : propose aussitôt ses valeurs
function category_source:execute(item, callback)
    callback(item)
    if item.kind == require("cmp").lsp.CompletionItemKind.Field then
        vim.schedule(require("cmp").complete)
    end
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
            -- Catégories stockées en liste dans la base papis.nvim ; après modification de CATEGORIES :
            -- :Papis reload data (sinon les nouveaux champs restent vides)
            local category_schema = {}
            for _, cat in ipairs(CATEGORIES) do
                category_schema[cat.key] = "luatable"
            end
            require("papis").setup({
                data_tbl_schema = category_schema,
                enable_keymaps = true,
                -- Bibliothèque d'essai ; remettre { "papis" } pour revenir à `these` (défaut papis),
                -- puis :Papis reload config et :Papis reload data
                papis_cmd_base = { "papis", "-l", "these" },
                init_filetypes = { "markdown", "norg", "yaml", "typst", "tex" },
            })
            -- Aperçu : titre, année, auteurs puis métadonnées ; ni clé, ni tags (abandonnés), ni résumé.
            -- show_categories ajoute les catégories à la fin
            local search = require("papis.config").search
            local function show_key(icon)
                return { fallback = { icon .. "  ", "%s: " } }
            end
            search.preview_format = {
                { "title", "%s", "PapisPreviewTitle" },
                { "year", "%s", "PapisPreviewYear" },
                { "authors_short", "%s", "PapisPreviewAuthor" },
                { "empty_line" },
                { "journal", "%s", "PapisPreviewValue", "show_key", show_key("󱀁"), "PapisPreviewKey" },
                { "related_to", "%s", "PapisPreviewValue", "show_key", show_key("󰌹"), "PapisPreviewKey" },
                { "type", "%s", "PapisPreviewValue", "show_key", show_key("󰀼"), "PapisPreviewKey" },
            }
            -- Liste : clé de citation à la place des auteurs
            search.results_format = vim.tbl_map(function(segment)
                return segment[1] == "author" and { "ref", "%s ", "PapisResultsAuthor" } or segment
            end, search.results_format)
            -- Colonne notes : le défaut @comment.warning a un fond orange dans catppuccin,
            -- appliqué même aux lignes sans notes → trait orange vertical dans la liste
            vim.api.nvim_set_hl(0, "PapisResultsNotes", { link = "DiagnosticWarn" })
            vim.api.nvim_set_hl(0, "PapisPreviewCategory", { fg = fg_of("Statement"), bold = true }) -- valeurs : mauve, gras
            for _, label in pairs(TYPE_LABELS) do -- couvre aussi PapisTypeComment (types inconnus)
                vim.api.nvim_set_hl(0, "PapisType" .. label[2], { fg = fg_of(label[2]) })
            end
            -- Avec les raccourcis papis : mêmes buffers que <leader>pp (types de init_filetypes)
            local keymaps = {
                search_category = {
                    mode = "n",
                    lhs = "<leader>pt",
                    rhs = pick_category,
                    opts = { desc = "Papis: chercher par catégorie" },
                },
                search_type = {
                    mode = "n",
                    lhs = "<leader>py",
                    rhs = pick_type,
                    opts = { desc = "Papis: chercher par type (article, thèse…)" },
                },
            }
            for _, map in ipairs(CATEGORY_KEYMAPS) do
                local key, family, title = unpack(map)
                keymaps["search_" .. family] = {
                    mode = "n",
                    lhs = "<leader>pc" .. key,
                    rhs = function()
                        pick_category(family, title)
                    end,
                    opts = { desc = "Papis: " .. title },
                }
            end
            require("papis.keymaps"):add_keymaps(keymaps)
            local has_cmp, cmp = pcall(require, "cmp")
            if has_cmp then
                cmp.register_source("papis_categories", category_source)
            end
            local has_wk, wk = pcall(require, "which-key")
            if has_wk then
                wk.add({ { "<leader>pc", group = "Papis catégories" } })
            end
        end,
    },
    {
        "folke/snacks.nvim",
        opts = {
            picker = {
                sources = {
                    -- nom donné par papis à Snacks.picker("Papis search", …), pas son opts.source
                    ["Papis search"] = {
                        -- Recherche exacte : en floue, etude_biblio:mouchetis trouvait ces lettres
                        -- éparpillées dans les études d'autres documents
                        matcher = { fuzzy = false },
                        transform = add_search_fields,
                        -- papis passe ses propres preview/format (prioritaires sur la source) : remplacés après fusion
                        config = function(opts)
                            return vim.tbl_extend(
                                "force",
                                opts,
                                { preview = preview_with_categories, format = format_with_type }
                            )
                        end,
                    },
                },
            },
        },
    },
}
