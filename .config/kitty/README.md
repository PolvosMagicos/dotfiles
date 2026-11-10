# Kitty

Terminal configuration in [kitty.conf](kitty.conf), using [Nushell](../nushell/README.md)
as the shell and Neovim as the editor. Follow the [repository setup](../../README.md)
for installation and linking.

## Dependencies and paths

The [Brewfile](../../Brewfile) supplies Kitty, Nushell, Neovim and the font.
Stow links this directory to `~/.config/kitty`. `exe_search_path` includes
`/opt/homebrew/bin` and `/usr/local/bin`, so Kitty can find `nu` when
launched from Finder on Apple Silicon or Intel.

The background image is read from
`~/dotfiles/assets/wallpapers/Shinji-and-Kaworu-colorized-cropped.png`.
Keep the checkout at `~/dotfiles` or update `background_image` when moving it.

## Active settings

| Setting | Value |
| --- | --- |
| Font | JetBrainsMono Nerd Font, 12.5 pt |
| Shell | `nu` |
| Editor | `nvim` |
| Background layout | `cscaled` |
| Background tint | `0.8` |

Most of the file is Kitty's commented option reference. Change the active lines
for your own font, shell or background. `kitty.conf.save` is a backup.

Launch `kitty` after linking. The default `Ctrl+Shift+F5` binding reloads the
configuration; restart Kitty when changing the shell. A shell startup error
should be investigated in the [Nushell configuration](../nushell/README.md).
