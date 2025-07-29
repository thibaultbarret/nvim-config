return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				python = { "ruff_format", "ruff_organize_imports" },
			},
			formatters = {
				prettier = {
					prepend_args = {
						"--tab-width",
						"4",
						"--use-tabs",
						"false", -- << ça force les espaces
					},
					stylua = {
						prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
					},
				},
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>mp", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 500,
			})
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
