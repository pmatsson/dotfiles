return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
	watch_for_changes = true,
        view_options = {
            show_hidden = true,
            is_always_hidden = function(name, _)
                return name == "node_modules" or name == ".git"
            end,
        },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
}
