vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up with cursor centered" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting the clipboard" })

-- System clipboard
vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Move line / selection up and down
vim.keymap.set("n", "<M-k>", ":m -2<CR>==", { silent = true, desc = "Move line up" })
vim.keymap.set("n", "<M-j>", ":m +1<CR>==", { silent = true, desc = "Move line down" })
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
vim.keymap.set("n", "<M-Up>", ":m -2<CR>==", { silent = true, desc = "Move line up" })
vim.keymap.set("n", "<M-Down>", ":m +1<CR>==", { silent = true, desc = "Move line down" })
vim.keymap.set("v", "<M-Up>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
vim.keymap.set("v", "<M-Down>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })

vim.keymap.set("n", "<leader>bd", "<CMD>bd<CR>", { desc = "Delete the current buffer" })
vim.keymap.set("n", "<leader>ba", "<CMD>%bd<CR>", { desc = "Delete all buffers" })
vim.keymap.set("n", "<leader>bo", "<CMD>%bd|e#|bd#<CR>", { desc = "Delete all other buffers" })

vim.keymap.set({ "n", "x", "o" }, "ö", "[", { remap = true, desc = "[ prefix" })
vim.keymap.set({ "n", "x", "o" }, "ä", "]", { remap = true, desc = "] prefix" })

vim.keymap.set("n", "<A-+>", "<C-a>", { desc = "Increment" })
vim.keymap.set("n", "<A-->", "<C-x>", { desc = "Decrement" })
