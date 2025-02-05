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

vim.lsp.enable('luals')
vim.lsp.enable('tsls')
vim.lsp.enable('htmlls')
vim.lsp.enable('cssls')

require 'lspconfig'.eslint.setup {}
require 'lspconfig'.angularls.setup {}
