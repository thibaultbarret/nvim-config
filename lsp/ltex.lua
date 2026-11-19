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

local last_version = {}

vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("LtexCheckOnSave", { clear = true }),
    pattern = { "*.tex", "*.md", "*.markdown" },
    callback = function(args)
        local bufnr = args.buf
        local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ltex" })
        if vim.tbl_isempty(clients) then
            return
        end

        local uri = vim.uri_from_bufnr(bufnr)
        local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")

        -- ltex-ls exige une version strictement croissante ; changedtick le garantit,
        -- avec un garde-fou si on sauvegarde deux fois sans modification
        local version = vim.api.nvim_buf_get_changedtick(bufnr)
        if last_version[uri] and version <= last_version[uri] then
            version = last_version[uri] + 1
        end
        last_version[uri] = version

        for _, client in ipairs(clients) do
            client:notify("textDocument/didChange", {
                textDocument = { uri = uri, version = version },
                contentChanges = { { text = text } },
            })
        end
    end,
})

---@type vim.lsp.Config
return {
    cmd = { "ltex-ls" },
    filetypes = filetypes,
    root_markers = { ".git" },
    get_language_id = get_language_id,
    on_init = function(client)
        client.server_capabilities.textDocumentSync = {
            openClose = true,
            change = vim.lsp.protocol.TextDocumentSyncKind.None, -- 0 : aucun didChange auto
        }
    end,
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
                    --
                    ["\\usepgfplotslibrary{}"] = "ignore",
                    ["\\tikzexternalize"] = "ignore",
                    ["\\tikzexternalize[]"] = "ignore",
                    ["\\tikzset{}"] = "ignore",
                    ["\\pgfdeclareplotmark{}"] = "ignore",
                    --
                    ["\\node"] = "ignore",
                    ["\\node at ()[]{}"] = "ignore",
                    ["\\node () at ()[]{}"] = "ignore",
                    --
                    ["\\addplot[]{}"] = "ignore",
                    ["\\addplot"] = "ignore",
                    ["\\addplot[]table[]{}"] = "ignore",
                    ["\\addplot+[]table[]{}"] = "ignore",
                    --
                    ["\\draw"] = "ignore",
                    -- ["\"] = "ignore",
                },
                environments = {
                    ["axis"] = "ignore",
                    ["tikzpicture"] = "ignore",
                    ["groupplot"] = "ignore",
                    ["tikzpicturenocompress"] = "ignore",
                    ["scope"] = "ignore",
                },
            },
        },
    },
}
