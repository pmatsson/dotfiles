vim.g.mapleader = " "

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up with cursor centered" })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting the clipboard" })
vim.keymap.set("n", "<leader>ke", "<cmd>lua vim.diagnostic.open_float()<cr>")

vim.api.nvim_set_keymap("n", "<M-k>", ":m -2<CR>==", { noremap = true, silent = true }) -- Move line up
vim.api.nvim_set_keymap("n", "<M-j>", ":m +1<CR>==", { noremap = true, silent = true }) -- Move line down
vim.api.nvim_set_keymap("v", "<M-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true }) -- Move selection up
vim.api.nvim_set_keymap("v", "<M-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true }) -- Move selection down

vim.api.nvim_set_keymap("n", "<M-Up>", ":m -2<CR>==", { noremap = true, silent = true }) -- Move line up
vim.api.nvim_set_keymap("n", "<M-Down>", ":m +1<CR>==", { noremap = true, silent = true }) -- Move line down
vim.api.nvim_set_keymap("v", "<M-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true }) -- Move selection up
vim.api.nvim_set_keymap("v", "<M-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true }) -- Move selection

vim.api.nvim_set_keymap("n", "<Tab>", "<CMD>lua vim.cmd('bnext')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Tab>", "<CMD>lua vim.cmd('bprevious')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>bd", "<CMD>bd<CR>", { noremap = true, silent = true })

-- Plugins
vim.keymap.set("n", "<leader>ff", "<CMD>FzfLua files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<CMD>FzfLua live_grep<CR>", { desc = "Grep files" })
vim.keymap.set("n", "<leader>fb", "<CMD>FzfLua buffers<CR>", { desc = "Search buffers" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
