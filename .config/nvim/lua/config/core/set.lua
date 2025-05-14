vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

--vim.opt.colorcolumn = "90"
vim.opt.guicursor = { a = "blinkon0" }

vim.diagnostic.config({
	virtual_text = true, -- Show virtual text inline
	signs = true, -- Show signs in the gutter
	update_in_insert = false, -- Disable updates while typing
})

vim.o.completeopt = "menu,menuone,fuzzy,preview,noinsert" -- Fix auto inserted completions
vim.o.laststatus = 3

vim.cmd.colorscheme("catppuccin-frappe")

