vim.lsp.config("*", {
	capabilities = {
		workspace = {
			didChangeWatchedFiles = {
				dynamicRegistration = true,
				relativePatternSupport = true,
			},
		},
	},
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("gl", vim.diagnostic.open_float, "Open Diagnostic Float")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("gs", vim.lsp.buf.signature_help, "Signature Documentation")
		map("gd", vim.lsp.buf.definition, "Goto Definition")
		map("gD", vim.lsp.buf.declaration, "Goto Declaration")
		map("<leader>la", vim.lsp.buf.code_action, "Code Action")
		map("<leader>lr", vim.lsp.buf.rename, "Rename all references")
		map("<leader>lf", vim.lsp.buf.format, "Format")
		map("<leader>v", "<cmd>vsplit | lua vim.lsp.buf.definition()<cr>", "Goto Definition in Vertical Split")

		local function client_supports_method(client, method, bufnr)
			if vim.fn.has("nvim-0.11") == 1 then
				return client:supports_method(method, bufnr)
			else
				return client.supports_method(method, { bufnr = bufnr })
			end
		end

		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if
			client
			and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
		then
			local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

			-- When cursor stops moving: Highlights all instances of the symbol under the cursor
			-- When cursor moves: Clears the highlighting
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			-- When LSP detaches: Clears the highlighting
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
				end,
			})
		end
	end,
})

-- Fonction pour obtenir l'icône selon la source du diagnostic (pour virtual text seulement)
local function get_source_icon(diagnostic)
	local source = diagnostic.source or ""

	if source:lower():find("ruff") then
		return "⚡"
	elseif source:lower():find("pyright") then
		return "🐍"
	else
		return "" -- Pas d'icône spéciale pour les autres sources
	end
end

vim.diagnostic.config({
	virtual_lines = false,
	virtual_text = {
		-- Personnalise seulement le virtual text avec les icônes de source
		prefix = function(diagnostic)
			local source_icon = get_source_icon(diagnostic)
			if source_icon ~= "" then
				return source_icon .. " "
			else
				return "● " -- Puce standard pour les autres sources
			end
		end,
	},
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
		-- Affiche aussi la source dans les popups
		prefix = function(diagnostic)
			local source_icon = get_source_icon(diagnostic)
			local source = diagnostic.source or "Unknown"
			if source_icon ~= "" then
				return source_icon .. " [" .. source .. "] ", "DiagnosticFloatingPrefix"
			else
				return "[" .. source .. "] ", "DiagnosticFloatingPrefix"
			end
		end,
	},
	-- Garde les signes standards dans la colonne (pour voir le type de diagnostic)
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "ErrorMsg",
			[vim.diagnostic.severity.WARN] = "WarningMsg",
		},
	},
})

-- Commande pour débugger les diagnostics
vim.api.nvim_create_user_command("DiagnosticDebug", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local diagnostics = vim.diagnostic.get(bufnr)

	print("=== Diagnostics Debug ===")
	print("Buffer:", bufnr)
	print("Total diagnostics:", #diagnostics)

	for i, diagnostic in ipairs(diagnostics) do
		local source_icon = get_source_icon(diagnostic)
		local severity_name = vim.diagnostic.severity[diagnostic.severity]
		print(
			string.format(
				"[%d] Line %d: %s %s %s (source: %s)",
				i,
				diagnostic.lnum + 1,
				severity_name,
				source_icon ~= "" and source_icon or "●",
				diagnostic.message:sub(1, 50),
				diagnostic.source or "unknown"
			)
		)
	end
end, { desc = "Debug diagnostic information" })

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"ruff",
})
