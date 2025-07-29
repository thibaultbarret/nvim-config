return {
	cmd = { "ruff", "server" },
	root_markers = {
		"ruff.toml",
		"pyproject.toml",
		"uv.lock",
		".git",
	},
	filetypes = { "python" },
	capabilities = {
		-- Ruff ne fournit pas de hover (Pyright s'en charge)
		hoverProvider = false,
		-- Ruff ne fait pas de définitions (Pyright s'en charge)
		definitionProvider = false,
		-- Ruff ne fait pas de références (Pyright s'en charge)
		referencesProvider = false,
		-- Ruff ne fait pas de renommage (Pyright s'en charge)
		renameProvider = false,
		-- Garde les capacités importantes de Ruff
		codeActionProvider = {
			codeActionKinds = {
				"source.fixAll.ruff",
				"source.organizeImports.ruff",
				"quickfix.ruff",
			},
		},
		diagnosticProvider = true,
		documentFormattingProvider = true,
		documentRangeFormattingProvider = true,
	},
	-- Configuration avancée pour Ruff
	settings = {
		-- Configuration globale
		globalSettings = {
			-- Organisation automatique des imports
			organizeImports = true,
			-- Correction automatique quand possible
			fixAll = true,
		},
		-- Configuration par défaut si pas de fichier config
		lint = {
			-- Règles activées (sélection moderne et équilibrée)
			select = {
				"E", -- pycodestyle errors
				"W", -- pycodestyle warnings
				"F", -- pyflakes
				"I", -- isort (imports)
				"N", -- pep8-naming
				"UP", -- pyupgrade
				"B", -- flake8-bugbear
				"C4", -- flake8-comprehensions
				"SIM", -- flake8-simplify
				"ARG", -- flake8-unused-arguments
				"PTH", -- flake8-use-pathlib
				"ERA", -- eradicate (commented code)
				"PL", -- pylint
				"RUF", -- ruff-specific
			},

			-- Règles ignorées (équilibre entre strictness et praticité)
			ignore = {
				"E501", -- Line too long (formatter s'en charge)
				"E203", -- Whitespace before ':' (conflit avec formatters)
				"W503", -- Line break before binary operator
				"B008", -- Function calls in argument defaults
				"N806", -- Variable in function should be lowercase (pour les APIs externes)
				"PLR0913", -- Too many arguments (parfois nécessaire)
				"PLR0915", -- Too many statements (parfois nécessaire)
				"SIM108", -- Use ternary operator (pas toujours plus lisible)
			},
		},
	},
}
