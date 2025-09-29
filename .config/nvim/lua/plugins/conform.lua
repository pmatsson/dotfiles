return {
	"stevearc/conform.nvim",
	event = "LspAttach",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			go = { "goimports", "gofmt", stop_after_first = true },
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
	},
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)
		vim.keymap.set("n", "<leader>F", function()
			conform.format()
		end, { silent = true, noremap = true, desc = "Format document" })
	end,
}
