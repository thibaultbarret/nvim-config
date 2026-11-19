return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},

	config = function()
		local noice = require("noice")

		noice.setup({
			lsp = {
				-- Hover (K) laissé au natif de Neovim : noice ne parse que markdown_inline,
				-- donc les titres « ### » de clangd restaient visibles. Le natif parse le
				-- markdown complet et applique queries/markdown/highlights.scm (conceal).
				hover = { enabled = false },
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = true, -- cadre arrondi autour de la doc (cohérent avec winborder)
			},
			views = {
				-- Doc de signature (gérée par noice) : lignes plus courtes, plus lisibles
				hover = { size = { max_width = 80, max_height = 20 } },
			},
		})

		-- Fait défiler la fenêtre de hover native (K) sans déplacer le curseur.
		-- Neovim l'enregistre dans vim.b.lsp_floating_preview du buffer d'origine.
		local function scroll_native_hover(delta)
			local win = vim.b.lsp_floating_preview
			if not (win and vim.api.nvim_win_is_valid(win)) then
				return false
			end
			-- On ne rentre jamais dans la fenêtre flottante (le hover natif se ferme dès
			-- qu'on change de fenêtre) : on déplace son curseur interne, ce qui la fait
			-- défiler. Différé : un mapping `expr` interdit de toucher une autre fenêtre.
			vim.schedule(function()
				if not vim.api.nvim_win_is_valid(win) then
					return
				end
				local info = vim.fn.getwininfo(win)[1]
				local last_line = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(win))
				local target = delta > 0 and math.min(last_line, info.botline + delta)
					or math.max(1, info.topline + delta)
				vim.api.nvim_win_set_cursor(win, { target, 0 })
			end)
			return true
		end

		-- <C-f>/<C-b> : font défiler la doc ouverte (signature noice ou hover natif),
		-- sinon gardent leur rôle normal (nvim-cmp garde la main quand son menu est ouvert).
		local DOC_SCROLL_LINES = 4
		local function scroll_docs(delta, fallback)
			if require("noice.lsp").scroll(delta) or scroll_native_hover(delta) then
				return
			end
			return fallback
		end
		vim.keymap.set({ "n", "s" }, "<C-f>", function()
			return scroll_docs(DOC_SCROLL_LINES, "<C-f>")
		end, { silent = true, expr = true, desc = "Défiler la doc LSP vers le bas" })
		-- En insertion, sans doc à défiler, <C-f> ouvre un picker qui insère le chemin du fichier choisi
		-- (path_completion : ../ dans la recherche remonte d'un dossier).
		vim.keymap.set("i", "<C-f>", function()
			if scroll_docs(DOC_SCROLL_LINES, false) == false then
				-- Différé : un mapping `expr` ne peut pas ouvrir de fenêtre.
				vim.schedule(function()
					require("path_completion").project({ kind = "file" })
				end)
			end
			return ""
		end, { silent = true, expr = true, desc = "Défiler la doc LSP ou insérer un chemin de fichier" })
		vim.keymap.set({ "n", "i", "s" }, "<C-b>", function()
			return scroll_docs(-DOC_SCROLL_LINES, "<C-b>")
		end, { silent = true, expr = true, desc = "Défiler la doc LSP vers le haut" })
	end,
}
