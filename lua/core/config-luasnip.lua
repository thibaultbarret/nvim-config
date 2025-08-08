-- Modification automatique des entetes des fichiers python
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.py",
	callback = function()
		local current_datetime = os.date("%d/%m/%Y à %H:%M")
		local bufnr = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

		for i, line in ipairs(lines) do
			-- Cherche le pattern "Dernière modification:" suivi d'une date optionnelle
			if line:match("Dernière modification:%s*") then
				local new_line = line:gsub("(Dernière modification:%s*).*", "%1" .. current_datetime)
				vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_line })
				break
			end
		end
	end,
})

-- Detection des fichiers .mfront
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.mfront",
	callback = function()
		vim.bo.filetype = "mfront"
	end,
})

-- Modification de la date des fichiers .mtest
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.mfront",
	callback = function()
		local current_date = os.date("%d/%m/%Y")
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

		for i, line in ipairs(lines) do
			-- Cherche la ligne @Date et la remplace
			if line:match("^@Date%s+") then
				local new_line = line:gsub("(%d%d?/%d%d?/%d%d%d%d)", current_date)
				vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line })
				break
			end
		end
	end,
	-- desc = "Mise à jour automatique de la date dans les fichiers MFront"
})

vim.filetype.add({
	filename = {
		[".zshrc"] = "zsh",
		[".bashrc"] = "bash",
		[".profile"] = "sh",
	},
})
