return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = { "williamboman/mason.nvim" },
	config = function()
		require("mason-lspconfig").setup({
			automatic_enable = true,
			automatic_setup = false,
			ensure_installed = {
				"pyright",
				"ruff",
				"lua_ls",
			},
		})
	end,
}
