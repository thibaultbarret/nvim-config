return {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	settings = {
		pyright = {
			disableOrganizeImports = true,
		},
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "workspace",
				useLibraryCodeForTypes = true,
				typeCheckingMode = "basic",
				autoImportCompletions = true,
				completeFunctionParens = true,
				includePackageImportsInAutoImports = true,
			},
		},
	},
}
