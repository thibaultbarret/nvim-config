local M = {}
--
-- Table des accents commune
local accent_map = {
    ["à"] = "a",
    ["á"] = "a",
    ["â"] = "a",
    ["ã"] = "a",
    ["ä"] = "a",
    ["å"] = "a",
    ["è"] = "e",
    ["é"] = "e",
    ["ê"] = "e",
    ["ë"] = "e",
    ["ì"] = "i",
    ["í"] = "i",
    ["î"] = "i",
    ["ï"] = "i",
    ["ò"] = "o",
    ["ó"] = "o",
    ["ô"] = "o",
    ["õ"] = "o",
    ["ö"] = "o",
    ["ù"] = "u",
    ["ú"] = "u",
    ["û"] = "u",
    ["ü"] = "u",
    ["ý"] = "y",
    ["ÿ"] = "y",
    ["ñ"] = "n",
    ["ç"] = "c",
    -- Majuscules
    ["À"] = "A",
    ["Á"] = "A",
    ["Â"] = "A",
    ["Ã"] = "A",
    ["Ä"] = "A",
    ["Å"] = "A",
    ["È"] = "E",
    ["É"] = "E",
    ["Ê"] = "E",
    ["Ë"] = "E",
    ["Ì"] = "I",
    ["Í"] = "I",
    ["Î"] = "I",
    ["Ï"] = "I",
    ["Ò"] = "O",
    ["Ó"] = "O",
    ["Ô"] = "O",
    ["Õ"] = "O",
    ["Ö"] = "O",
    ["Ù"] = "U",
    ["Ú"] = "U",
    ["Û"] = "U",
    ["Ü"] = "U",
    ["Ý"] = "Y",
    ["Ÿ"] = "Y",
    ["Ñ"] = "N",
    ["Ç"] = "C",
}

-- Fonction privée pour la logique commune
local function process_text(text)
    -- Remplacer les caractères accentués
    for accented, plain in pairs(accent_map) do
        text = text:gsub(accented, plain)
    end

    -- Convertir en minuscules
    text = text:lower()

    -- Remplacer tout ce qui n'est pas alphanumérique par des tirets
    text = text:gsub("[^%w]", "-")

    -- Remplacer les tirets multiples par un seul
    text = text:gsub("-+", "-")

    -- Supprimer les tirets au début et à la fin
    text = text:gsub("^-+", ""):gsub("-+$", "")

    return text
end

function M.sanitize_label(args, snip)
    local text = args[1][1] or ""
    return process_text(text)
end

-- Transforme un texte libre en nom de fichier (capitalisé)
function M.title_from_text(text)
    text = process_text(text or "")

    -- Capitaliser la première lettre
    if text:len() > 0 then
        text = text:sub(1, 1):upper() .. text:sub(2)
    end

    return text
end

function M.sanitize_title(args, snip)
    return M.title_from_text(args[1][1])
end

-- Transforme un texte libre en nom de fichier : accents retirés, casse conservée,
-- séparateurs remplacés par "_" ("Calcul sur un incrément" → "Calcul_sur_un_increment")
function M.filename_from_text(text)
    text = text or ""
    for accented, plain in pairs(accent_map) do
        text = text:gsub(accented, plain)
    end
    text = text:gsub("[^%w]", "_"):gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", "")
    return text
end

function M.sanitize_filename(args, snip)
    return M.filename_from_text(args[1][1])
end

-- Préfixes des dossiers de premier niveau du manuscrit (chapitres, annexes)
local SECTION_DIR_PATTERNS = { "^CHAPITRE", "^ANNEXE" }
local TIKZ_DIR = "Tikz"

local function is_section_dir(name)
    for _, pattern in ipairs(SECTION_DIR_PATTERNS) do
        if name:match(pattern) then
            return true
        end
    end
    return false
end

-- Remonte depuis le fichier courant jusqu'au dossier de chapitre/annexe
-- (CHAPITRE-*, ANNEXE-*). Si aucun n'est trouvé, utilise le dossier du fichier courant.
-- Renvoie : chemin absolu du chapitre, nom du dossier
function M.find_chapter_dir()
    local file_dir = vim.fn.expand("%:p:h")
    for dir in vim.fs.parents(vim.fn.expand("%:p")) do
        local name = vim.fs.basename(dir)
        if is_section_dir(name) then
            return dir, name
        end
    end
    return file_dir, vim.fs.basename(file_dir)
end

-- Racine du manuscrit : parent du dossier CHAPITRE-*/ANNEXE-*,
-- sinon dossier contenant main.tex, sinon dossier de travail.
function M.find_manuscript_root()
    for dir in vim.fs.parents(vim.fn.expand("%:p")) do
        if is_section_dir(vim.fs.basename(dir)) then
            return vim.fs.dirname(dir)
        end
    end
    return vim.fs.root(0, "main.tex") or vim.fn.getcwd()
end

-- Chemin de `dir` relatif à la racine du manuscrit, avec "/" final ("" si racine)
local function dir_from_root(dir)
    local rel = vim.fs.relpath(M.find_manuscript_root(), dir)
    if rel == nil or rel == "." or rel == "" then
        return ""
    end
    return rel .. "/"
end

-- Dossier du fichier courant depuis la racine
-- (ex : "ANNEXE-Implementation_LDC_MFront/Exemple_retour_radial/")
function M.current_dir_from_root()
    return dir_from_root(vim.fn.expand("%:p:h"))
end

-- Écrit un nouveau fichier (et ses dossiers). Ne remplace jamais un fichier existant.
local function write_new_file(path, content)
    if vim.uv.fs_stat(path) then
        vim.notify("Fichier déjà existant : " .. path, vim.log.levels.INFO)
        return
    end

    local dir = vim.fs.dirname(path)
    if vim.fn.mkdir(dir, "p") == 0 then
        vim.notify("Impossible de créer le dossier : " .. dir, vim.log.levels.ERROR)
        return
    end

    if vim.fn.writefile(content, path) ~= 0 then
        vim.notify("Impossible d'écrire : " .. path, vim.log.levels.ERROR)
        return
    end

    vim.notify("Fichier créé : " .. path, vim.log.levels.INFO)
end

-- Crée <dossier courant>/<Nom_du_fichier>.tex (vide)
function M.create_sibling_file(raw_name)
    local name = M.filename_from_text(raw_name)
    if name == "" then
        return
    end
    write_new_file(vim.fs.joinpath(vim.fn.expand("%:p:h"), name .. ".tex"), {})
end

local SECTION_ENTRY_FILE = "Premiere_page.tex"

-- Niveau de titre selon la profondeur du dossier sous CHAPITRE-*/ANNEXE-*
-- (mêmes préfixes de label que snippets/tex/title.lua)
local SECTION_LEVELS = {
    { command = "section", label = "sec" },
    { command = "subsection", label = "sub" },
    { command = "subsubsection", label = "ssub" },
}

-- Profondeur de `dir` sous le dossier du chapitre (1 = section directe)
local function depth_below_chapter(dir)
    local rel = vim.fs.relpath(M.find_chapter_dir(), dir) or ""
    local depth = 0
    for _ in rel:gmatch("[^/]+") do
        depth = depth + 1
    end
    return depth
end

-- Choisit section/subsection/subsubsection pour un dossier de section
function M.section_level(section_dir)
    local depth = depth_below_chapter(section_dir)
    return SECTION_LEVELS[math.min(math.max(depth, 1), #SECTION_LEVELS)]
end

-- Crée <dossier courant>/<Nom_de_section>/Premiere_page.tex
-- contenant le titre au bon niveau et son label
function M.create_section_file(raw_title)
    local name = M.filename_from_text(raw_title)
    if name == "" then
        return
    end

    local section_dir = vim.fs.joinpath(vim.fn.expand("%:p:h"), name)
    local level = M.section_level(section_dir)
    write_new_file(vim.fs.joinpath(section_dir, SECTION_ENTRY_FILE), {
        "\\" .. level.command .. "{" .. raw_title .. "}",
        "\\label{" .. level.label .. ":" .. process_text(raw_title) .. "}",
        "",
    })
end

function M.chapter_name()
    local _, name = M.find_chapter_dir()
    return name
end

local FOLDER_FIGURE_FILE = "figure.tex"

-- Crée un tikzpicture vide dans le dossier du chapitre :
--   in_folder = false : <chapitre>/Tikz/<Nom>.tex
--   in_folder = true  : <chapitre>/Tikz/<Nom>/figure.tex
-- Ne remplace jamais un fichier existant.
function M.create_tikz_file(raw_name, in_folder)
    local name = M.title_from_text(raw_name)
    if name == "" then
        return
    end

    local tikz_dir = vim.fs.joinpath(M.find_chapter_dir(), TIKZ_DIR)
    local path = in_folder and vim.fs.joinpath(tikz_dir, name, FOLDER_FIGURE_FILE)
        or vim.fs.joinpath(tikz_dir, name .. ".tex")

    write_new_file(path, { "\\begin{tikzpicture}", "    ", "\\end{tikzpicture}" })
end

-- ─── Snippet \input relatif au dossier courant ─────────────────────────────

-- % <Titre>
-- \input{<prefix_fn()><Nom>.<suffix>}  + appel de create_fn(titre) en quittant le titre
local function input_snippet(trigger, placeholder, prefix_fn, suffix, create_fn)
    local ls = require("luasnip")
    local events = require("luasnip.util.events")
    local t, i, f = ls.text_node, ls.insert_node, ls.function_node
    return ls.snippet(trigger, {
        t("% "),
        i(1, placeholder),
        t({ "", "\\input{" }),
        f(prefix_fn),
        f(M.sanitize_filename, { 1 }),
        t(suffix .. "}"),
        t({ "", "" }),
        i(0),
    }, {
        callbacks = {
            [1] = {
                [events.leave] = function(node)
                    create_fn(node:get_text()[1])
                end,
            },
        },
    })
end

-- \input{<dossier courant>/<Nom_du_fichier>.tex} + création du fichier
function M.input_here_snippet(trigger)
    return input_snippet(trigger, "Titre du fichier", M.current_dir_from_root, ".tex", M.create_sibling_file)
end

-- \input{<dossier courant>/<Nom_de_section>/Premiere_page.tex}
-- + création du dossier et du fichier avec \section/\subsection/\subsubsection + label
function M.input_section_snippet(trigger)
    return input_snippet(
        trigger,
        "Titre de la section",
        M.current_dir_from_root,
        "/" .. SECTION_ENTRY_FILE,
        M.create_section_file
    )
end

-- ─── Constructeurs de snippets TikZ liés au chapitre ───────────────────────

-- Options LuaSnip : crée le fichier TikZ en quittant le nœud de nom (1)
local function tikz_file_opts(in_folder)
    local events = require("luasnip.util.events")
    return {
        callbacks = {
            [1] = {
                [events.leave] = function(node)
                    M.create_tikz_file(node:get_text()[1], in_folder)
                end,
            },
        },
    }
end

-- Nœuds \tikzsetnextfilename + \input{<CHAPITRE>/Tikz/<Nom>...}
local function tikz_input_nodes(indent, in_folder)
    local ls = require("luasnip")
    local t, f = ls.text_node, ls.function_node
    local suffix = in_folder and ("/" .. FOLDER_FIGURE_FILE) or ".tex"
    return {
        t({ "", indent .. "\\tikzsetnextfilename{" }),
        f(M.sanitize_title, { 1 }),
        t({ "}", indent .. "\\input{" }),
        f(M.chapter_name),
        t("/" .. TIKZ_DIR .. "/"),
        f(M.sanitize_title, { 1 }),
        t(suffix .. "}"),
    }
end

-- Snippet simple : commentaire + inclusion du fichier TikZ
function M.tikz_input_snippet(trigger, in_folder)
    local ls = require("luasnip")
    local t, i = ls.text_node, ls.insert_node
    local nodes = { t("% "), i(1, "TikZ name") }
    vim.list_extend(nodes, tikz_input_nodes("", in_folder))
    vim.list_extend(nodes, { t({ "", "" }), i(0) })
    return ls.snippet(trigger, nodes, tikz_file_opts(in_folder))
end

-- Snippet d'environnement flottant (figure, schema…) incluant le fichier TikZ
function M.tikz_float_snippet(trigger, env, label_prefix, in_folder)
    local ls = require("luasnip")
    local t, i, f = ls.text_node, ls.insert_node, ls.function_node
    local rep = require("luasnip.extras").rep
    local nodes = { t("\\begin{" .. env .. "}[h!] % "), i(1) }
    vim.list_extend(nodes, tikz_input_nodes("    ", in_folder))
    vim.list_extend(nodes, {
        t({ "", "    \\centering" }),
        t({ "", "    \\caption{", "        \\label{" .. label_prefix .. ":" }),
        f(M.sanitize_label, { 1 }),
        t({ "}", "        " }),
        rep(1),
        t({ "", "    }" }),
        t({ "", "\\end{" .. env .. "}" }),
    })
    return ls.snippet(trigger, nodes, tikz_file_opts(in_folder))
end

return M
