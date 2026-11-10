# Neovim

Lua configuration for web, Rust, Python, Flutter and terminal development.
See the [repository setup](../../README.md) for this branch's installation steps.

## Requirements and first launch

The [Brewfile](../../Brewfile) installs Neovim, language servers, formatters
and build tools. Apple's Command Line Tools supply `make`, a C compiler and
`clangd`. Follow the repository's Stow setup to link `~/.config/nvim`.

On macOS, Homebrew manages those executables and `lazy.nvim` manages editor
plugins. Mason is archived and does not install language servers. Server
definitions resolve commands from Neovim's `PATH`; the tables below list command
names, which can differ from Homebrew formula names.

Use Neovim 0.12 or newer for the plugin stack documented by this repository.
Install the external commands for the features you use:

| Feature | Commands |
| --- | --- |
| Plugin downloads and native builds | `git`, `make`, a C compiler |
| Tree-sitter parser installation | `tree-sitter`, a C compiler |
| Telescope text search | `rg` |
| TypeScript and Markdown preview | Node.js, TypeScript, `yarn` |
| Formatters and linting | `stylua`, `prettierd`, `clang-format`, `ruff`, `markdownlint` |
| Floating tool terminals | `lazygit`, `atac` |
| Rust | `rust-analyzer`, `cargo`, Rust toolchain |
| Flutter | `flutter`, `dart` |

Launch `nvim` after linking. [lazy.lua](lua/polvos-magicos/lazy.lua) clones
`lazy.nvim` into Neovim's data directory when missing, then loads the plugins.
Initial setup needs network access for plugin and parser downloads. Plugin
revisions are recorded in [lazy-lock.json](lazy-lock.json).

## Files to edit

| File or directory | Responsibility |
| --- | --- |
| [init.lua](init.lua) | Load core settings and Lazy |
| [core/maps.lua](lua/polvos-magicos/core/maps.lua) | General shortcuts; Space is the leader |
| [core/options.lua](lua/polvos-magicos/core/options.lua) | Indentation, diagnostics, clipboard and undo |
| [core/utils.lua](lua/polvos-magicos/core/utils.lua) | LSP shortcuts, save formatting and terminal helpers |
| [core/filetypes.lua](lua/polvos-magicos/core/filetypes.lua) | ISML filetype and HTML parser association |
| [plugins/](lua/polvos-magicos/plugins) | Plugin specifications |
| [lsp/servers/](lua/polvos-magicos/plugins/lsp/servers) | Native language server definitions |
| [colorscheme.lua](lua/polvos-magicos/colorscheme.lua) | Transparent Catppuccin Mocha theme |

Core defaults include two-space indentation, relative line numbers, no wrapping,
system clipboard, persistent undo in `~/.vim/undodir`, virtual-line diagnostics
and diagnostic floats on `CursorHold`. Clipboard access needs a working platform
provider (`wl-clipboard` in a Wayland session, or macOS clipboard tools).

## Language servers and formatting

[lsp-config.lua](lua/polvos-magicos/plugins/lsp/lsp-config.lua) loads each Lua file
in `servers/`, defines it with `vim.lsp.config`, and enables it with `vim.lsp.enable`.

| Language | Command or integration |
| --- | --- |
| Lua | `lua-language-server` |
| Python types | `pyright-langserver --stdio` (config name: `basedpyright`) |
| C/C++/Objective-C/CUDA/Proto | `clangd` |
| HTML and ISML | `vscode-html-language-server --stdio` |
| Markdown/MDX | `marksman server` |
| Tailwind CSS | `tailwindcss-language-server --stdio` |
| Python lint/format/actions | `ruff server` |
| TypeScript/JavaScript/React | `typescript-tools.nvim` |
| Rust and Cargo manifests | `rustaceanvim`, `crates.nvim` |
| Flutter/Dart | `flutter-tools.nvim` |

The macOS [none-ls config](lua/polvos-magicos/plugins/lsp/none-ls.lua) provides
Stylua, prettierd and clang-format formatting, plus Markdownlint diagnostics.
Python linting, formatting and code actions use the native
[Ruff server](lua/polvos-magicos/plugins/lsp/servers/ruff.lua), alongside Pyright
for type checking. This branch omits QML server setup and KDL/Nix/QML parsers.

The shared `on_attach` function enables formatting before save when the attached
client supports it, with a one-second timeout. `<leader>f` formats manually;
`<leader>gf` is also defined by none-ls. If formatting or diagnostics are missing,
check the server command on PATH and the project root markers in its definition.

## Configured shortcuts

`<leader>` means Space. Grouped suffixes in a table row share the first
prefix: `<leader>sv / sh` means Space-s-v / Space-s-h. Bindings come from the
core and plugin files.

| Key | Action |
| --- | --- |
| `<leader>ev` | Open netrw |
| `Ctrl+n` in normal mode | Toggle Neo-tree on the left and reveal the file |
| `<leader>bf` | Show Neo-tree buffers in a float |
| `Alt+Arrow` | Focus an adjacent window |
| `<leader>sv` / `sh` / `se` / `sx` | Vertical split / horizontal split / equalize / close |
| `<leader>to` / `tx` / `tn` / `tp` / `tf` | New tab / close / next / previous / current file in new tab |
| `<leader>ff` / `fh` | Find files / include hidden and ignored files |
| `<leader>fg` / `fc` | Live grep with arguments / grep with the configured code glob |
| `<leader>fb` / `fs` / `fo` / `fw` | Buffers / document symbols / old files / word under cursor |
| `<leader>gc` / `gb` | Git commits / current file's commits |
| `<leader>u` / `y` | Telescope undo / yank history |
| `[y` / `]y` | Cycle yank history |
| `<leader>G` / `A` | LazyGit / ATAC in a floating terminal |
| `<leader>dt` / `dc` / `dx` / `do` | Breakpoint / continue / terminate / step over |

LSP shortcuts are attached when a server connects:

| Key | Action |
| --- | --- |
| `K` / `Ctrl+k` | Hover / signature help |
| `gD` / `gd` / `gi` / `gr` | Declaration / definition / implementation / references |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>q` | Diagnostics in the location list |
| `<leader>ca` / `rn` / `f` | Code action / rename / format |
| `<leader>wa` / `wr` / `wl` | Add / remove / list workspace folders |
| `<leader>lh` | Toggle inlay hints |

Blink completion uses its `default` preset with LSP, path, snippets and buffer
sources. The normal-mode `Ctrl+n` tree binding is separate from completion in
insert mode. Better Escape configures `jk`/`jj` in insert mode.

## Other integrations and limits

Telescope includes live-grep arguments, native FZF, undo and UI selection.
Neo-tree shows hidden and Git-ignored files. ToggleTerm supplies floating
terminals. Markdown preview builds with Yarn and opens through
`:MarkdownPreview` when requested. Gitsigns, Yanky, mini.nvim modules,
Comment.nvim and TODO highlighting provide additional editing tools.

The DAP plugin supplies controls and UI, but [debugger.lua](lua/polvos-magicos/plugins/debugger.lua)
does not define language adapters or launch configurations; configure those for
your project before using Continue. Copilot is disabled. `noice.lua` returns an
empty spec, so the `<leader>nd` NoiceDismiss mapping has no enabled Noice plugin.
Files in `plugins/archived/` are retained for reference.

## Maintenance and checks

Use these inside Neovim:

```vim
:Lazy
:Lazy restore
:checkhealth
```

`:Lazy restore` uses the committed lockfile. `:Lazy update` intentionally changes
plugin revisions; review and commit `lazy-lock.json` with those updates.
For a missing parser, confirm `tree-sitter` is available and inspect the parser
list in [treesitter.lua](lua/polvos-magicos/plugins/treesitter.lua).

The repository also includes a headless syntax, ISML and save-formatting check.
Run it from `~/dotfiles`; it does not install plugins or verify a full UI session:

```bash
nvim --headless -u NONE -i NONE -l tests/nvim-check.lua
```
