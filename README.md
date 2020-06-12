>
> This Neovim plugin is WIP.
>

# clangd-nvim

'[clangd-nvim]()' uses [Neovim]()'s build- in [Language Server Protocol]() to enable '[clangd]()''s support for semantic highlighting.

## Roadmap

- [X] Implement basic semantic highlight support
- [ ] Implement highlight groups
- [ ] Allow higlight group changes

## Features

- Semantic Highlighting for 'c','cpp','objc','objcpp'

## Requirements

- clangd (Version >= 9.0)
- Neovim (Version >= 0.5)
- nvim-lsp

## Install

- With '[vim-plug]()':

'''vim
" Requires
Plug 'neovim/nvim-lsp'
" Install
Plug '...'
'''

## Setup

'''vim
lua require'nvim_lsp'.clangd.setup{on_init=require'clangd_nvim'.on_init}
'''

## Screenshots

