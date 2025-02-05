return {
    -- Mason for managing LSP servers
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = true, -- Uses the default configuration
    },

    -- Mason integration with LSPConfig
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright" },
                automatic_installation = false,
            })
        end,
    },
}
