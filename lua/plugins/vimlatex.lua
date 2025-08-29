return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	config = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_method = "skim"
		vim.g.vimtex_view_skim_sync = 1
		vim.g.vimtex_view_skim_activate = 1

		-- Configuration du compilateur
		vim.g.vimtex_compiler_method = "latexmk"
		vim.g.vimtex_compiler_latexmk = {
			build_dir = "",
			callback = 1,
			continuous = 1,
			executable = "latexmk",
			hooks = {},
			options = {
				"--shell-escape",
				"-verbose",
				"-file-line-error",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}

		-- Options générales
		vim.g.vimtex_quickfix_mode = 1
		vim.g.vimtex_mappings_enabled = 1
		vim.g.vimtex_indent_enabled = 1
		vim.g.vimtex_syntax_enabled = 1

		-- Mappings personnalisés (optionnel)
		vim.keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<CR>", { desc = "VimTeX Compile" })
		vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<CR>", { desc = "VimTeX View" })
		vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<CR>", { desc = "VimTeX TOC Toggle" })
		vim.keymap.set("n", "<leader>lk", "<cmd>VimtexStop<CR>", { desc = "VimTeX Stop" })
		vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<CR>", { desc = "VimTeX Errors" })
	end,
}
