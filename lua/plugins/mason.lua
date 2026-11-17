return {
	"williamboman/mason.nvim",
	cmd = "Mason",
	event = "BufReadPre",
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
			-- mason.nvim n'a pas d'option ensure_installed : la liste des outils
			-- (LSP, formatters, linters) est dans mason-tool-installer.lua.
		})
	end,
}
