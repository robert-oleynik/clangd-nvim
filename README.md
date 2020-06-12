>
> This Neovim plugin is WIP.
>

# clangd-nvim

[clangd-nvim](https://gitlab.com/robert-oleynik/clangd-nvim/) uses [Neovim](https://github.com/neovim/neovim)'s build- in [Language Server Protocol]() to enable [clangd](https://clangd.llvm.org/)'s support for semantic highlighting.

## Roadmap

- [X] Implement basic semantic highlight support
- [X] Implement highlight groups
- [ ] Enable/Disable semantic highlighting
- [ ] Allow custom higlight group

## Features

- Semantic Highlighting for `c`,`cpp`

## Requirements

- [clangd](https://clangd.llvm.org/) (Version >= 9.0)
- [Neovim](https://github.com/neovim/neovim) (Version >= 0.5)
- [nvim-lsp](https://github.com/neovim/nvim-lsp)

## Install

- With [vim-plug](https://github.com/junegunn/vim-plug):

```vim
" Required
Plug 'neovim/nvim-lsp'
" Plugin
Plug 'robert-oleynik/clangd-nvim'
```

## Setup

```vim
lua require'nvim_lsp'.clangd.setup{on_init=require'clangd_nvim'.on_init}
```

## Screenshots

![](screenshots/lsp_comparision.png)
Left: clangd-nvim + nvim-lsp; Right: no plugin
