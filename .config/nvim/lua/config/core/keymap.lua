vim.g.mapleader = " "

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up with cursor centered" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting the clipboard" })
vim.keymap.set("n", "<C-z>", "<CMD>undo<CR>", { desc = "Undo" })
vim.keymap.set("n", "<C-S-z>", "<CMD>redo<CR>", { desc = "Redo" })

-- Plugins
vim.keymap.set("n", "<leader>ff", "<CMD>FzfLua files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep<CR>", { desc = "Grep files" })
vim.keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>", { desc = "Search buffers" })

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })