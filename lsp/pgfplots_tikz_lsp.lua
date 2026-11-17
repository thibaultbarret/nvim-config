return {
    cmd = {
        "/Users/thibault/Documents/THESE/LaTeX/pgfplots_tikz_lsp/.venv/bin/python3",
        -- -E -s : ignore les variables PYTHON* (PYTHONPATH/PYTHONHOME) et le site
        -- utilisateur. Sans ça, le venv 3.14 charge la stdlib 3.12 d'Anaconda
        -- héritée du shell → "SRE module mismatch", le serveur meurt au démarrage.
        "-E",
        "-s",
        "-m",
        "pgfplots_tikz_lsp",
    },
    cmd_cwd = "/Users/thibault/Documents/THESE/LaTeX/pgfplots_tikz_lsp",
    filetypes = { "tex" },
    -- root_markers (et non root_dir calculé ici) : depuis Neovim 0.12, ce fichier
    -- est lu au démarrage, avant l'ouverture du buffer .tex.
    root_markers = { ".git" },
    -- Même encodage que texlab, ltex et Copilot sur les .tex : sinon ce serveur
    -- négocie UTF-8 et les positions divergent sur les lignes accentuées.
    capabilities = {
        general = { positionEncodings = { "utf-16" } },
    },
    on_attach = function(client, bufnr)
        vim.lsp.semantic_tokens.enable(true, { bufnr = bufnr, client_id = client.id })
    end,
}
