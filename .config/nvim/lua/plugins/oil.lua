-- Oil: edit directories like buffers. Replaces netrw entirely.
vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

require("oil").setup({
	default_file_explorer = true,
	-- no icon column: avoids the devicons dependency
	columns = {},
	view_options = { show_hidden = true },
})

vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory (oil)" })
