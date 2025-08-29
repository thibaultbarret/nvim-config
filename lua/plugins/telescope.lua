return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"nvim-telescope/telescope-file-browser.nvim", -- Nouvelle dépendance
		"nvim-telescope/telescope-media-files.nvim", -- Pour prévisualiser les images
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local telescope_builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				-- Parce que c'est joli
				prompt_prefix = " ",
				selection_caret = " ",
				path_display = { "smart" },
				file_ignore_patterns = { ".git/", "node_modules", "__pycache__", ".DS_Store" },

				mappings = {
					i = {
						["<C-j>"] = actions.move_selection_next,
						["<C-k>"] = actions.move_selection_previous,
					},
				},
				hidden = true,
			},
			pickers = {
				find_files = {
					hidden = true,
					-- Vous pouvez aussi utiliser cette option pour find_files spécifiquement
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/__pycache__/**" },
				},
			},
			-- Configuration des extensions
			extensions = {
				file_browser = {
					theme = "ivy", -- Peut aussi être "dropdown", "cursor", ou omis
					-- Masquer les fichiers dot par défaut
					hidden = false,
					-- Respecter .gitignore
					respect_gitignore = true,
					-- Pas de préview par défaut (pour économiser l'espace)
					previewer = false,
					-- Commencer en mode normal (pas insert)
					initial_mode = "normal",
					-- Grouper les dossiers en premier
					grouped = true,
					-- Configuration simplifiée sans mappings personnalisés pour éviter les erreurs
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("file_browser") -- Charger l'extension file_browser
		telescope.load_extension("media_files") -- Charger l'extension media_files

		local map = vim.keymap.set
		map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })

		-- Git
		map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
		map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })

		-- Files
		map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
		map(
			"n",
			"<leader>fa",
			"<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
			{ desc = "telescope find all files" }
		)

		-- File Browser - nouveaux mappings
		map("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", { desc = "telescope file browser" })
		map(
			"n",
			"<leader>fB",
			"<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
			{ desc = "telescope file browser (current file directory)" }
		)

		-- Media files - pour prévisualiser images/vidéos/PDFs
		map("n", "<leader>fm", "<cmd>Telescope media_files<CR>", { desc = "telescope media files" })

		map("n", "<leader>fh", function()
			telescope_builtin.find_files({
				cwd = vim.fn.expand("$HOME"),
				prompt_title = "Find Files in $HOME",
				hidden = true, -- Inclure les fichiers cachés
				no_ignore = false, -- Respecter .gitignore
				follow = true, -- Suivre les liens symboliques
			})
		end, { desc = "Find files in $HOME directory" })

		-- File browser pour la thèse (adapté de votre mapping existant)
		map("n", "<leader>bt", function()
			telescope.extensions.file_browser.file_browser({
				cwd = vim.fn.expand("$HOME/Documents/THESE/"),
				prompt_title = "Browse THESE Directory",
				hidden = false,
				respect_gitignore = false,
			})
		end, { desc = "Browse files in THESE directory" })

		map("n", "<leader>ft", function()
			telescope_builtin.find_files({
				cwd = vim.fn.expand("$HOME/Documents/THESE/"),
				prompt_title = "Find Files in THESE",
				hidden = false, -- Inclure les fichiers cachés
				no_ignore = false, -- Respecter .gitignore
				follow = true, -- Suivre les liens symboliques
			})
		end, { desc = "Find files in THESE directory" })

		map("n", "<leader>fd", function()
			telescope_builtin.find_files({
				cwd = vim.fn.input("Directory: ", vim.fn.getcwd() .. "/", "dir"),
			})
		end, { desc = "Find files in directory" })

		-- File browser pour un répertoire personnalisé
		map("n", "<leader>bd", function()
			local dir = vim.fn.input("Browse Directory: ", vim.fn.getcwd() .. "/", "dir")
			if dir and dir ~= "" then
				telescope.extensions.file_browser.file_browser({
					cwd = dir,
					prompt_title = "Browse " .. dir,
				})
			end
		end, { desc = "Browse custom directory" })
	end,
}
