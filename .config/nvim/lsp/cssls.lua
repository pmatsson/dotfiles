return {
    cmd = { 'vscode-css-language-server', '--stdio' },
    filetypes = { 'css', 'scss', 'less' },
    root_markers = { 'package.json', '.git' },
    hint = { enable = true },
    settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
    },
    init_options = {
        provideFormatter = true,

    },
}
