vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            }
        }
    },
    root_markers = { '.git' },
})

-- vim.lsp.enable('luals')
-- vim.lsp.enable('tsls')
--vim.lsp.enable('htmlls')
-- vim.lsp.enable('cssls')
-- vim.lsp.enable('eslint')
--vim.lsp.enable('angularls')
require'lspconfig'.lua_ls.setup{}
require'lspconfig'.html.setup{}
require'lspconfig'.cssls.setup{}
require'lspconfig'.eslint.setup{}
require'lspconfig'.ts_ls.setup{}
require'lspconfig'.angularls.setup{}
