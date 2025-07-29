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

-- Commentaires
map("n", "<C-q>", "gcc", { desc = "toggle comment", remap = true })
map("v", "<C-q>", "gc", { desc = "toggle comment", remap = true })

-- Recherche centree
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Supprimer sans copier
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
