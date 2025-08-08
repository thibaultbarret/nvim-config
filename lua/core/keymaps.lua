local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Nouveau buffer
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "buffer new" })

-- Buffer suivant / précédent
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer goto next" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer goto prev" })

-- Fermer le buffer courant
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "buffer close" })

-- Supprimer le surlignage
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

-- Copie complete du fichier
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

-- Copie du texte selectionne dans le clipboard
map("v", "<C-c>", function()
	vim.cmd('normal! "+y')
end, { desc = "copy selection to clipboard" })

-- Coller du texte depuis le clipboard
local function smart_paste_below()
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then -- modes visual
		vim.cmd('normal! "+p')
	else -- mode normal
		vim.cmd('normal! "+p')
	end
end

local function smart_paste_above()
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then -- modes visual
		vim.cmd('normal! "+p') -- en visual, P et p font la même chose
	else -- mode normal
		vim.cmd('normal! "+P')
	end
end

map({ "n", "v" }, "<C-v>", smart_paste_below, { desc = "paste from clipboard below" })
map({ "n", "v" }, "<C-V>", smart_paste_above, { desc = "paste from clipboard above" })

-- Commentaires
map("n", "<C-q>", "gcc", { desc = "toggle comment", remap = true })
map("v", "<C-q>", "gc", { desc = "toggle comment", remap = true })

-- Recherche centree
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Supprimer sans copier
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Tout selectionner
map({ "n" }, "<leader>aa", "ggVG", { desc = "Select all" })
