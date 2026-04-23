-- ~/.config/nvim/lsp/ltex.lua

local language_id_mapping = {
    plaintex = "tex",
    tex = "latex",
}

local filetypes = {
    "markdown",
    "plaintex",
    "tex",
}

local function get_language_id(_, filetype)
    return language_id_mapping[filetype] or filetype
end

---@type vim.lsp.Config
return {
    cmd = { "ltex-ls" },
    filetypes = filetypes,
    root_markers = { ".git" },
    get_language_id = get_language_id,
    settings = {
        ltex = {
            language = "fr",
            enabled = { "markdown", "latex", "tex" },
            latex = {
                commands = {
                    ["\\tikzsetnextfilename{}"] = "ignore",
                    ["\\qty[]{}"] = "ignore",
                    ["\\num[]{}"] = "ignore",
                    ["\\num{}"] = "ignore",
                    ["\\qtyrange{}{}{}"] = "ignore",
                    ["\\doubleCite{}"] = "ignore",
                    ["\\draw[]"] = "ignore",
                    ["\\pgfplotsset{}"] = "ignore",
                    ["\\pgfplotsset"] = "ignore",
                    ["\\usepgfplotslibrary{}"] = "ignore",
                    ["\\tikzexternalize"] = "ignore",
                    ["\\tikzexternalize[]"] = "ignore",
                    ["\\tikzset{}"] = "ignore",
                    ["\\pgfdeclareplotmark{}"] = "ignore",
                    ["\\addplot[]{}"] = "ignore",
                    ["\\addplot"] = "ignore",
                    ["\\draw"] = "ignore",
                    -- ["\"] = "ignore",
                },
                environments = {
                    ["axis"] = "ignore",
                    ["tikzpicture"] = "ignore",
                    ["tikzpicturenocompress"] = "ignore",
                },
            },
        },
    },
}
