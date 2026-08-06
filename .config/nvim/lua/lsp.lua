-- lsp
vim.lsp.enable({ "lua_ls", "tsgo", "clangd", "html", "angularls", "pyright", "jdtls" })
vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client ~= nil and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})

vim.cmd("set completeopt+=noselect")

vim.keymap.set("i", "<C-Space>", function()
	vim.lsp.completion.get()
end, { desc = "Trigger LSP completion" })

-- Tab accepts the highlighted completion (or the first one if none is
-- highlighted); plain tab otherwise
vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		if vim.fn.complete_info({ "selected" }).selected == -1 then
			return "<C-n><C-y>"
		end
		return "<C-y>"
	end
	return "<Tab>"
end, { expr = true, desc = "Accept completion" })