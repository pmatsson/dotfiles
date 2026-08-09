-- Parser/query installer only — highlighting itself is native, enabled by the
-- FileType autocmd below. Needs the tree-sitter CLI and a C compiler.
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

require("nvim-treesitter").install({
	"c",
	"lua",
	"vim",
	"vimdoc",
	"markdown",
	"query",
	"typescript",
	"tsx",
	"javascript",
	"json",
	"bash",
	"angular",
	"html",
	"cpp",
	"rust",
	"zig",
	"python",
	"java",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"lua",
		"c",
		"vim",
		"markdown",
		"query",
		"typescript",
		"typescriptreact",
		"javascript",
		"javascriptreact",
		"json",
		"sh",
		"html",
		"htmlangular",
		"cpp",
		"rust",
		"zig",
		"python",
		"java",
	},
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
