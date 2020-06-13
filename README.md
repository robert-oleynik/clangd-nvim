# clangd-nvim

>
> Issues: see [gitlab](https://gitlab.com/robert-oleynik/clangd-nvim/-/issues/)
>

[clangd-nvim](https://gitlab.com/robert-oleynik/clangd-nvim/) uses [Neovim](https://github.com/neovim/neovim)'s build- in [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) to enable [clangd](https://clangd.llvm.org/)'s support for semantic highlighting.

![](screenshots/lsp_comparision.png)
Left: clangd-nvim + nvim-lsp; Right: no plugin

## Roadmap

- [X] Implement basic semantic highlight support
- [X] Implement highlight groups
- [ ] Enable/Disable semantic highlighting
- [X] Change highlight color

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

Add to init file:
```vim
lua << EOF
require'nvim_lsp'.clangd.setup{
    capabilities = {
        textDocument = {
            semanticHighlightingCapabilities = {
                semanticHighlighting = true
            }
        }
    },
    on_init=require'clangd_nvim'.on_init
}
EOF
```

## Change Colors

1. Add to init file (init.vim)
```vim
augroup ConfigSetup
    autocmd!
    autocmd VimEnter,ColorScheme * runtime syntax/custom_colors.vim
augroup END
```
2. Add to neovim config folder `syntax/custom_colors.vim`-File (on Linux `~/.config/nvim/syntax/custom_colors.vim`)
3. Change Colors by:
```vim
hi! default link <clangd-syntax-highlight-group> <vim-syntax-highlight-group>
" Example:
hi! default link ClangdClass Type
```

>
> Note: `:so $VIMRUNTIME/syntax/hitest.vim` lists all available syntax highlight groups with colors.
>

## Symbols And Syntax Highlight Groups

| Clangd Symbol | Highlight Group | Default Value |
| ------ | ------ | ----- |
| `entity.name.function.cpp` | `ClangdFunction` | Function |
| `entity.name.function.method.cpp` | `ClangdMemberFunction` | Function |
| `entity.name.function.method.static.cpp` | `ClangdStaticMemberFunction` | Function |
| `entity.name.function.preprocessor.cpp` | `ClangdPreprocessor` | Macro |
| `entity.name.namespace.cpp` | `ClangdNamespace` | Namespace |
| `entity.name.other.dependent.cpp` | `ClangdDependentName` | Function |
| `entity.name.type.class.cpp` | `ClangdClass` | Type |
| `entity.name.type.concept.cpp` | `ClangdConcept` | Type |
| `entity.name.type.dependent.cpp` | `ClangdDependentType` | Type |
| `entity.name.type.enum.cpp` | `ClangdEnum` | Type |
| `entity.name.type.typedef.cpp` | `ClangdTypedef` | Type |
| `entity.name.type.template.cpp` | `ClangdTemplateParameter` | Type |
| `storage.type.primitive.cpp` | `ClangdPrimitive` | Type |
| `variable.other.cpp` | `ClangdVariable` | Variable |
| `variable.other.local.cpp` | `ClangdLocalVariable` | Variable |
| `variable.parameter.cpp` | `ClangdParameter` | Variable |
| `variable.other.field.cpp` | `ClangdField` | Variable |
| `variable.other.static.field.cpp` | `ClangdStaticField` | Variable |
| `variable.other.enummember.cpp` | `ClangdEnumConstant` | Constant |
| `meta.disabled` | `ClangdInactiveCode` | Comment |

