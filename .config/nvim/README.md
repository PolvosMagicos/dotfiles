# Neovim Config

Personal Neovim configuration from my dotfiles, written in Lua and organized around `lazy.nvim`.

This setup is focused on my daily development workflow: web development, TypeScript/JavaScript, React, Rust, Python, Flutter/Dart, QML, Markdown, HTML/ISML, and general terminal-based development.

## Overview

Main goals of this config:

- Fast Lua-based Neovim setup
- Modular plugin configuration
- Lazy-loaded plugin management with `lazy.nvim`
- Native LSP configuration
- Completion with `blink.cmp`
- Telescope-based navigation and search
- Catppuccin Mocha with transparent background
- Rust, TypeScript, Python, Flutter, QML, Tailwind and ISML support
- Terminal integrations for tools like LazyGit and ATAC

## Structure

```txt
.config/nvim
├── init.lua
├── lazy-lock.json
├── .luarc.json
└── lua
    └── polvos-magicos
        ├── lazy.lua
        ├── colorscheme.lua
        ├── core
        │   ├── init.lua
        │   ├── maps.lua
        │   ├── options.lua
        │   ├── utils.lua
        │   └── filetypes.lua
        └── plugins
            ├── lsp
            │   ├── lsp-config.lua
            │   ├── none-ls.lua
            │   └── servers
            │       ├── basedpyright.lua
            │       ├── clangd.lua
            │       ├── html.lua
            │       ├── lua_ls.lua
            │       ├── marksman.lua
            │       ├── qmlls.lua
            │       └── tailwindcss.lua
            ├── telescope.lua
            ├── telescope-extensions.lua
            ├── blink-cmp.lua
            ├── treesitter.lua
            ├── typescript-tools.lua
            ├── rust.lua
            ├── flutter-tools.lua
            ├── neo-tree.lua
            ├── toggleterm.lua
            ├── debugger.lua
            ├── git-signs.lua
            ├── lualine.lua
            ├── mini.lua
            ├── yanky.lua
            ├── comment.lua
            ├── better-escape.lua
            ├── todo-comments.lua
            ├── markdown-preview.lua
            ├── package-info.lua
            ├── ts-autotag.lua
            ├── dressing.lua
            ├── focus.lua
            └── wich-key.lua
```

## Entry point

`init.lua` loads two modules:

```lua
require("polvos-magicos.core")
require("polvos-magicos.lazy")
```

The `core` module loads:

- Keymaps
- Editor options
- Utility functions
- Custom filetype rules

The `lazy` module bootstraps `lazy.nvim` and imports:

- `polvos-magicos.plugins`
- `polvos-magicos.plugins.lsp`
- `polvos-magicos.colorscheme`

## Plugin manager

This config uses `lazy.nvim`.

If `lazy.nvim` is missing, it is automatically cloned into Neovim's data directory:

```txt
stdpath("data")/lazy/lazy.nvim
```

Useful commands:

```vim
:Lazy
:Lazy sync
:Lazy update
:Lazy clean
```

Plugin versions are locked in:

```txt
lazy-lock.json
```

Commit this file when updating plugins so the setup remains reproducible.

## Theme

The colorscheme is:

```txt
catppuccin mocha
```

Theme details:

- Transparent background enabled
- Transparent floating windows enabled
- End-of-buffer `~` characters hidden
- Inactive window dimming disabled

## Editor options

Important defaults:

- Relative numbers enabled
- Absolute number shown on cursor line
- Two-space indentation
- Tabs expanded to spaces
- Smart indentation enabled
- Line wrapping disabled
- Swap files disabled
- Backup files disabled
- Persistent undo enabled
- System clipboard enabled through `unnamedplus`
- True color enabled
- Splits open to the right and below
- Search ignores case unless uppercase is used
- Diagnostics use virtual lines
- Diagnostic floats open on `CursorHold`

Persistent undo directory:

```txt
~/.vim/undodir
```

## Language support

### Lua

Configured through `lua_ls`.

Features:

- LuaJIT runtime
- `vim` recognized as a global
- Neovim runtime files added to the Lua workspace
- Telemetry disabled

### Python

Configured through `basedpyright`.

Features:

- Uses `pyright-langserver --stdio`
- Strict type checking
- Workspace diagnostics
- Root detection through `pyproject.toml`, `setup.py`, or `.git`

### C / C++

Configured through `clangd`.

Supported filetypes:

- `c`
- `cpp`
- `objc`
- `objcpp`
- `cuda`
- `proto`

Root detection:

- `compile_commands.json`
- `compile_flags.txt`
- `.git`

### HTML and ISML

Configured through the HTML language server.

Supported filetypes:

- `html`
- `isml`

The config also registers `.isml` files as `isml` and maps ISML to the HTML Treesitter parser.

This is useful for Salesforce Commerce Cloud / SFRA template work.

### Markdown

Configured through `marksman`.

Supported filetypes:

- `markdown`
- `markdown.mdx`

### QML

Configured through `qmlls`.

Supported filetypes:

- `qml`
- `qmljs`

The command uses:

```txt
qmlls -E --build-dir build
```

### Tailwind CSS

Configured through `tailwindcss-language-server`.

Supported filetypes include:

- `html`
- `css`
- `scss`
- `javascript`
- `javascriptreact`
- `typescript`
- `typescriptreact`
- `vue`
- `svelte`

### TypeScript / JavaScript

Configured with `typescript-tools.nvim`.

Features:

- Separate diagnostic server enabled
- Code lens disabled
- Inlay parameter name hints enabled
- Auto import completions enabled
- JSX close tag support for React filetypes

### Rust

Configured with:

- `rustaceanvim`
- `crates.nvim`

Rust-specific features:

- Rust plugin loads for Rust files
- `crates.nvim` loads for `Cargo.toml`
- Crate version hints
- Update warnings
- Crate popup metadata
- LSP integration for crate information

### Flutter / Dart

Configured with:

- `flutter-tools.nvim`

This integrates Flutter tooling into Neovim and also loads the Telescope Flutter extension.

## Formatting and diagnostics

Formatting and extra diagnostics are handled through `none-ls.nvim`.

Configured formatters:

- `stylua`
- `prettierd`
- `clang_format`
- `ruff`

Configured diagnostics:

- `markdownlint`
- `ruff`

Configured code actions:

- `ruff`

There is also shared LSP formatting-on-save logic in `core/utils.lua`. When an attached LSP client supports formatting, a `BufWritePre` autocommand formats the buffer before saving.

## Completion

Completion is provided by:

```txt
blink.cmp
```

Configured sources:

- LSP
- Path
- Snippets
- Buffer

The config uses the default `blink.cmp` keymap preset and the Rust fuzzy matcher when available.

## Search and navigation

Telescope is configured as the main search/navigation tool.

Features:

- Hidden files included
- `.git` directory excluded
- FZF native extension enabled
- Live grep args extension enabled
- Undo extension enabled
- UI select extension enabled
- Flutter extension enabled
- Multi-select support that opens selected files

## File explorer

File explorer support is provided by:

```txt
neo-tree.nvim
```

Configured behavior:

- Opens on the right side
- Width: `40`
- Hidden files visible
- Dotfiles visible
- Gitignored files visible
- Buffer view available in a floating window

## Git integration

Git features are provided by:

```txt
gitsigns.nvim
```

Configured features:

- Git signs in the sign column
- Staged signs enabled
- Custom symbols for add/change/delete/untracked lines
- Git directory watching
- Preview windows with a single border

LazyGit can also be opened in a floating terminal.

## Terminal integration

Terminal windows are handled by:

```txt
toggleterm.nvim
```

Configured behavior:

- Floating terminal by default
- Starts in insert mode
- Keeps terminal open after command exit
- Horizontal and vertical terminal size: 40% of screen

Custom floating terminal helpers are defined for:

- `lazygit`
- `atac`

## Debugging

Debugging is configured with:

- `nvim-dap`
- `nvim-dap-ui`
- `nvim-nio`

DAP UI opens automatically when debugging starts and closes when debugging exits or terminates.

DAP keymaps:

| Keymap | Action |
| --- | --- |
| `dt` | Toggle breakpoint |
| `dc` | Continue |
| `dx` | Terminate |
| `do` | Step over |

## UI and editing plugins

This config also includes:

- `lualine.nvim` for the statusline
- `dressing.nvim` for improved UI prompts/selects
- `focus.nvim` for window focus/layout behavior
- `mini.nvim` modules:
  - `mini.ai`
  - `mini.splitjoin`
  - `mini.operators`
  - `mini.surround`
  - `mini.move`
  - `mini.cursorword`
- `Comment.nvim` for commenting
- `better-escape.nvim` for leaving insert/terminal/select modes with `jk` or `jj`
- `todo-comments.nvim` for TODO-style comments
- `markdown-preview.nvim` for Markdown preview
- `package-info.nvim` for `package.json` dependency information
- `nvim-ts-autotag` for auto-closing and renaming HTML/JSX/TSX tags
- `yanky.nvim` for yank history
- `which-key.nvim` for keymap discovery

## Disabled / inactive config

There is a `noice.lua` plugin file, but it currently returns an empty table:

```lua
return {}
```

So Noice is currently disabled unless that file is changed to return the `noice` plugin spec.

## Keymaps

Leader key:

```txt
Space
```

### Core

| Keymap | Action |
| --- | --- |
| `<leader>ev` | Open netrw explorer |
| `<A-Left>` | Move to left window |
| `<A-Down>` | Move to lower window |
| `<A-Up>` | Move to upper window |
| `<A-Right>` | Move to right window |

### Splits

| Keymap | Action |
| --- | --- |
| `<leader>sv` | Split window vertically |
| `<leader>sh` | Split window horizontally |
| `<leader>se` | Make splits equal size |
| `<leader>sx` | Close current split |

### Tabs

| Keymap | Action |
| --- | --- |
| `<leader>to` | Open new tab |
| `<leader>tx` | Close current tab |
| `<leader>tn` | Go to next tab |
| `<leader>tp` | Go to previous tab |
| `<leader>tf` | Open current buffer in new tab |

### Telescope

| Keymap | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fh` | Find hidden files |
| `<leader>fg` | Live grep with args |
| `<leader>fc` | Live grep code, excluding spec/test glob |
| `<leader>fb` | Find buffers |
| `<leader>fs` | Find document symbols |
| `<leader>fo` | Find old files |
| `<leader>fw` | Find word under cursor |
| `<leader>gc` | Search Git commits |
| `<leader>gb` | Search Git commits for current buffer |
| `<leader>u` | Telescope undo history |

### Yank history

| Keymap | Action |
| --- | --- |
| `<leader>y` | Open Yanky ring history |
| `y` | Yank through Yanky |
| `p` | Put after through Yanky |
| `P` | Put before through Yanky |
| `[y` | Previous yank |
| `]y` | Next yank |

### Tools

| Keymap | Action |
| --- | --- |
| `<leader>G` | Open LazyGit in floating terminal |
| `<leader>A` | Open ATAC in floating terminal |
| `?` | Show buffer-local keymaps with Which Key |

### Neo-tree

| Keymap | Action |
| --- | --- |
| `<leader>e` | Toggle filesystem tree and reveal current file |
| `<leader>bf` | Show buffers in floating Neo-tree window |

### LSP

These are attached when an LSP server connects to the buffer.

| Keymap | Action |
| --- | --- |
| `K` | Hover information |
| `gD` | Go to declaration |
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `gr` | List references |
| `<C-k>` | Signature help |
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |
| `<leader>q` | Send diagnostics to location list |
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>f` | Format buffer |
| `<leader>lh` | Toggle inlay hints |

### Better escape

| Mode | Mapping |
| --- | --- |
| Insert | `jk`, `jj` |
| Command | `jk`, `jj` |
| Terminal | `jk` |
| Select | `jk` |

## External command requirements

Some plugins or mappings expect these commands to be available in `$PATH`:

### General

```txt
git
make
rg
```

### Tool integrations

```txt
lazygit
atac
```

### Language servers

```txt
lua-language-server
pyright-langserver
clangd
vscode-html-language-server
marksman
qmlls
tailwindcss-language-server
```

### Formatters and linters

```txt
stylua
prettierd
clang-format
ruff
markdownlint
```

### Optional / language-specific

```txt
rust-analyzer
cargo
flutter
dart
```

## Installation

Clone the dotfiles repository:

```bash
git clone -b nixos https://github.com/PolvosMagicos/dotfiles.git ~/dotfiles
```

Link the Neovim config:

```bash
mkdir -p ~/.config
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
```

Open Neovim:

```bash
nvim
```

On first launch, `lazy.nvim` will bootstrap itself and install the configured plugins.

## Updating plugins

Inside Neovim:

```vim
:Lazy update
```

After updating, commit the lockfile:

```bash
git add .config/nvim/lazy-lock.json
git commit -m "chore(nvim): update plugins"
```

## Notes

This config is personal and optimized for my workflow. It assumes several external tools and language servers are installed by the system package manager, usually through my NixOS configuration.

For a fresh machine, install the required language servers and CLI tools first, then launch Neovim and run:

```vim
:Lazy sync
```
