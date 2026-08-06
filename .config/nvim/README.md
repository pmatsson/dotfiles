# nvim config

Minimal neovim config, plugins via built-in vim.pack. Needs a few external tools:

- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [fzf](https://github.com/junegunn/fzf)
- [tree-sitter cli](https://github.com/tree-sitter/tree-sitter/releases) and a C compiler (builds treesitter parsers)
- gdb 14+ (dap adapter for c/c++/rust/zig, distro package)
- lsp servers on $PATH (see lsp/)
- formatters (see lua/formatting.lua)
- a nerd font for the icons

Optional: [bat](https://github.com/sharkdp/bat) for nicer fzf previews.
