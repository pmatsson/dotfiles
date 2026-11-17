local M = {}

-- User-configurable: filetype -> shell command (stdin/stdout)
M.formatters = {
	lua = "stylua -",
	javascript = "prettier --stdin-filepath %",
	typescript = "prettier --stdin-filepath %",
	typescriptreact = "prettier --stdin-filepath %",
	json = "prettier --stdin-filepath %",
}

function M.format(bufnr)
	local ft = vim.bo[bufnr].filetype
	local cmd = M.formatters[ft]

	if cmd then
		-- Replace % with actual buffer path for tools that need it,
		-- shell-quoted, with % escaped so gsub doesn't eat it
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		local resolved = cmd:gsub("%%", (vim.fn.shellescape(bufname):gsub("%%", "%%%%")))

		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local input = table.concat(lines, "\n")

		local output = vim.fn.system(resolved, input)

		if vim.v.shell_error ~= 0 then
			vim.notify("formatter failed: " .. resolved .. "\n" .. output, vim.log.levels.WARN)
			return
		end

		local formatted = vim.split(output, "\n", { plain = true })
		-- Remove trailing empty line that shell commands often append
		if formatted[#formatted] == "" then
			table.remove(formatted)
		end
		-- Only touch the buffer when something changed, and keep the view
		if not vim.deep_equal(formatted, lines) then
			local view = vim.fn.winsaveview()
			vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
			vim.fn.winrestview(view)
		end
	else
		-- No external formatter: try LSP
		for _, cl in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if cl:supports_method("textDocument/formatting") then
				vim.lsp.buf.format({ bufnr = bufnr, async = false })
				break
			end
		end
	end
end

-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(args)
		M.format(args.buf)
	end,
})

vim.keymap.set("n", "<leader>F", function()
	M.format(vim.api.nvim_get_current_buf())
end, { desc = "Format buffer" })

return M