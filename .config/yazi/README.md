# Yazi

Terminal file manager with custom archive shortcuts in [keymap.toml](keymap.toml).
Follow the [repository setup](../../README.md) to install and link the config.

## Dependencies and plugins

Install Yazi, archive commands and preview tools through Nix, and link this
directory with Home Manager. The archive shortcuts match `macos`; its Homebrew
setup and archive submodule initialization differ from this branch.

This branch includes a checked-in mount plugin and a Git link for
`compress.yazi`. The archive plugin has no `.gitmodules` entry on this branch.
If its directory is empty in a fresh checkout, clone it separately and select
the revision recorded by this repository:

```bash
git clone https://github.com/KKV9/compress.yazi.git ~/dotfiles/.config/yazi/plugins/compress.yazi
git -C ~/dotfiles/.config/yazi/plugins/compress.yazi checkout c2646395394f22b6c40bff64dc4c8c922d210570
```

Run that only for an empty plugin directory. The mount plugin revision is also
recorded in [package.toml](package.toml); its Linux dependencies are `udisksctl`,
`lsblk` and `eject`. See its [own README](plugins/mount.yazi/README.md).

Archive tools depend on the format: for example `zip`, `tar`, or a supported
7-Zip command (`7z`, `7zz`, `7za`). Header encryption needs a format that supports
it, such as 7z. Image/video/PDF previews depend on the installed preview tools.
This directory does not define a separate theme
or `yazi.toml`, so other behavior uses Yazi's defaults.

## Configured shortcuts

Press the keys in each sequence one after another:

| Sequence | Action |
| --- | --- |
| `c a a` | Archive selected files |
| `c a p` | Archive with a password |
| `c a h` | Archive with password and encrypted header |
| `c a l` | Choose compression level |
| `c a u` | Password, encrypted header and compression level |
| `M` | Open the mount manager |

Run `yazi` directly, or use `y` in [Nushell](../nushell/README.md) to change the
shell's working directory to the location selected when Yazi exits. If an
archive shortcut cannot load `compress`, check that the plugin directory is
populated before changing the keymaps.
