return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"mfussenegger/nvim-dap-python",
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			-- Automatic installation and setup
			require("mason-nvim-dap").setup({
				automatic_installation = true,
				handlers = {},
				ensure_installed = { "debugpy" },
			})

			-- Python configuration with Mason path
			require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")

			-- UI and visualization setup
			dapui.setup()
			require("nvim-dap-virtual-text").setup()

			-- Automatic UI management
			dap.listeners.after.event_initialized["dapui_config"] = dapui.open
			dap.listeners.before.event_terminated["dapui_config"] = dapui.close
			dap.listeners.before.event_exited["dapui_config"] = dapui.close

			-- Essential keymaps
			vim.keymap.set("n", "<F5>", dap.continue)
			vim.keymap.set("n", "<F10>", dap.step_over)
			vim.keymap.set("n", "<F11>", dap.step_into)
			vim.keymap.set("n", "<F12>", dap.step_out)
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
			vim.keymap.set("n", "<leader>du", dapui.toggle)
		end,
	},
}
