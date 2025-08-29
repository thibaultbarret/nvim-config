-- Configuration complète du Dashboard avec Alpha-nvim
-- Placez ceci dans votre gestionnaire de plugins (lazy.nvim, packer, etc.)

-- Si vous utilisez lazy.nvim, ajoutez ceci dans votre fichier de plugins :
return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Configuration du header (logo ASCII)
		dashboard.section.header.val = {
			"                                                     ",
			"  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
			"  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
			"  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
			"  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
			"  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
			"  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
			"                                                     ",
			"                 [ Welcome to Neovim ]               ",
			"                                                     ",
		}

		-- Configuration des boutons d'action
		dashboard.section.buttons.val = {
			dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
			dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<CR>"),
			dashboard.button("r", "  Recently used files", "<cmd>Telescope oldfiles<CR>"),
			dashboard.button("t", "  Find text", "<cmd>Telescope live_grep<CR>"),
			dashboard.button("c", "  Configuration", "<cmd>edit $MYVIMRC<CR>"),
			dashboard.button("s", "  Settings", "<cmd>e ~/.config/nvim/<CR>"),
			dashboard.button("l", "󰒲  Lazy (Plugin Manager)", "<cmd>Lazy<CR>"),
			dashboard.button("u", "  Update plugins", "<cmd>Lazy update<CR>"),
			dashboard.button("q", "󰅚  Quit Neovim", "<cmd>qa<CR>"),
		}

		-- Configuration du footer avec des informations dynamiques
		local function footer()
			local total_plugins = #vim.tbl_keys(require("lazy").plugins())
			local datetime = os.date("  %d-%m-%Y   %H:%M:%S")
			local version = vim.version()
			local nvim_version_info = "   v" .. version.major .. "." .. version.minor .. "." .. version.patch

			return {
				"⚡ " .. total_plugins .. " plugins loaded",
				datetime,
				nvim_version_info,
			}
		end

		dashboard.section.footer.val = footer()

		-- Styling et couleurs
		dashboard.section.header.opts.hl = "AlphaHeader"
		dashboard.section.buttons.opts.hl = "AlphaButtons"
		dashboard.section.footer.opts.hl = "AlphaFooter"

		-- Layout et espacement
		dashboard.config.layout = {
			{ type = "padding", val = 2 },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 1 },
			dashboard.section.footer,
		}

		-- Options générales
		dashboard.config.opts.noautocmd = true

		-- Raccourcis clavier personnalisés dans le dashboard
		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			desc = "disable status and tablines for alpha",
			callback = function()
				if vim.o.laststatus ~= 0 then
					vim.o.laststatus = 0
				end
				if vim.o.showtabline ~= 0 then
					vim.o.showtabline = 0
				end
			end,
		})

		vim.api.nvim_create_autocmd("BufUnload", {
			buffer = 0,
			desc = "enable status and tablines after alpha",
			callback = function()
				vim.o.laststatus = 3
				vim.o.showtabline = 2
			end,
		})

		-- Setup d'Alpha avec la configuration du dashboard
		alpha.setup(dashboard.config)

		-- Commande pour rouvrir le dashboard
		vim.api.nvim_create_user_command("Dashboard", function()
			alpha.start(true)
		end, { desc = "Open Alpha Dashboard" })

		-- Mapping pour ouvrir le dashboard rapidement
		vim.keymap.set("n", "<leader>DB", "<cmd>Dashboard<CR>", { desc = "Open Dashboard" })
	end,
}

-- Si vous n'utilisez PAS lazy.nvim, utilisez cette version alternative :
--[[
-- Installation avec packer.nvim ou autre :
use {
  'goolord/alpha-nvim',
  requires = { 'nvim-tree/nvim-web-devicons' },
  config = function ()
    -- Copiez tout le contenu de la section config = function() ci-dessus
    -- (de local alpha = require('alpha') jusqu'à la fin)
  end
}
--]]

-- Personnalisations de couleurs (optionnel)
-- Ajoutez ceci dans votre configuration de couleurs ou init.lua :
--[[
vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = '#7aa2f7' })      -- Bleu pour le header
vim.api.nvim_set_hl(0, 'AlphaButtons', { fg = '#9ece6a' })     -- Vert pour les boutons
vim.api.nvim_set_hl(0, 'AlphaFooter', { fg = '#565f89' })      -- Gris pour le footer
--]]
