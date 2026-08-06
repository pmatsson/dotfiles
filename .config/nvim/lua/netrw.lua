vim.g.netrw_banner = 0 -- hide the top banner
vim.g.netrw_list_hide = [[^\.\.\=/\=$]] -- hide the ./ and ../ entries

vim.keymap.set("n", "-", "<CMD>Explore<CR>", { desc = "Open netrw in the current file's directory" })