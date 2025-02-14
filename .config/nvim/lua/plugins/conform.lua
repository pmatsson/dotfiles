return {
	"stevearc/conform.nvim",
	event = "LspAttach",
	opts = {
		formatters_by_ft = {
			lua = { "stylua", lsp_format = "fallback" },
			python = { "isort", "black", lsp_format = "fallback" },
			["*"] = { "prettierd" },
		},
	},
	config = function(_, opts)
		local conform = require("conform")
		conform.setup(opts)
		vim.keymap.set("n", "<leader>kd", function()
			conform.format()
		end, { silent = true, noremap = true, desc = "Format document" })
	end,
}
