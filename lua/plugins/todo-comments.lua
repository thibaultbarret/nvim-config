return {
	"folke/todo-comments.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {
		{ "<leader>tdt", "<cmd>TodoTelescope<CR>", { desc = "Todo Telescope" } },
		{ "<leader>tdl", "<cmd>TodoQuickFix<CR>", { desc = "Todo QuickFix" } },
		{
			"]t",
			function()
				require("todo-comments").jump_next()
			end,
			desc = "Next todo",
		},
		{
			"[t",
			function()
				require("todo-comments").jump_prev()
			end,
			desc = "Previous todo",
		},
	},

	config = function()
		local todo_comments = require("todo-comments")

		todo_comments.setup({
			signs = true,
		})
		--
		-- -- set keymaps
		-- local map = vim.keymap.set -- for conciseness
		--
		-- map.set("n", "]t", function()
		-- 	todo_comments.jump_next()
		-- end, { desc = "Next todo comment" })
		--
		-- map.set("n", "[t", function()
		-- 	todo_comments.jump_prev()
		-- end, { desc = "Previous todo comment" })

		-- Mapping :
		-- map({ "n", "<leader>tdt", "<cmd>TodoTelescope<CR>", { desc = "Todo Telescope", silent = true, noremap = true } })
		-- map({ "n", "<leader>tdl", "<cmd>TodoQui<CR>", { desc = "Todo Telescope" } })
	end,
}
