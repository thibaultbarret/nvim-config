return {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"pyrightconfig.json",
		"setup.py",
		"requirements.txt",
		".git",
	},
	settings = {
		pyright = {
			-- Désactive l'organisation des imports (Ruff s'en charge)
			disableOrganizeImports = true,
			-- Désactive le language server pour les imports (Ruff plus performant)
			disableLanguageServices = false,
			-- Utilise le pyrightconfig.json ou pyproject.toml si présent
			useLibraryCodeForTypes = true,
		},
		python = {
			analysis = {
				-- Recherche automatique des chemins Python
				autoSearchPaths = true,

				diagnosticMode = "workspace",
				--
				-- Utilise les types des bibliothèques installées
				useLibraryCodeForTypes = true,
				--
				-- Mode de vérification des types (basic/standard/strict)
				typeCheckingMode = "basic",

				-- Completions automatiques
				autoImportCompletions = true,
				completeFunctionParens = true,
				includePackageImportsInAutoImports = true,

				-- NOUVELLES OPTIMISATIONS
				-- Indexation plus rapide
				indexing = true,
			},
		},
	},
}
