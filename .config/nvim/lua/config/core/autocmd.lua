vim.api.nvim_create_autocmd('CompleteDone', {
    desc = 'Close completion preview after selection',
    callback = function()
        vim.cmd('pclose')
    end
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight yanked text',
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual', timeout = 600 })
    end,
})

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if client then
            if client:supports_method('textDocument/inlayHint') then
                vim.lsp.inlay_hint.enable(true)
            end

            if client:supports_method('textDocument/completion') then
                vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = false })
            end
        end
        local bufmap = function(mode, lhs, rhs)
            local opts = { buffer = args.buf }
            vim.keymap.set(mode, lhs, rhs, opts)
        end



        -- You can find details of these function in the help page
        -- see for example, :help vim.lsp.buf.hover()

        -- Trigger code completion
        bufmap('i', '<C-Space>', '<cmd>lua vim.lsp.completion.trigger()<cr>')

        -- Display documentation of the symbol under the cursor
        bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

        -- Jump to the definition
        bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

        -- Jump to declaration
        bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

        -- Lists all the implementations for the symbol under the cursor
        bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

        -- Jumps to the definition of the type symbol
        bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

        -- Lists all the references
        bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

        -- Displays a function's signature information
        bufmap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

        -- Renames all references to the symbol under the cursor
        bufmap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>')

        -- Format current file
        -- bufmap('n', '<leader>kd', '<cmd>lua conform.format()<cr>') -- Using conform for this

        -- Selects a code action available at the current cursor position
        bufmap('n', '<leader>ka', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    end
})
