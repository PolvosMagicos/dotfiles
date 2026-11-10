# Yazi

Terminal file manager with custom archive shortcuts in [keymap.toml](keymap.toml).
Follow the [repository setup](../../README.md) to install and link the config.

## Dependencies and plugins

The [Brewfile](../../Brewfile) installs Yazi, archive tools and preview
helpers. The archive plugin is a submodule. Initialize it from the repo root:

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

This branch has no custom mount plugin or `M` mapping.

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

Run `yazi` directly, or use `y` in [Nushell](../nushell/README.md) to change the
shell's working directory to the location selected when Yazi exits. If an
archive shortcut cannot load `compress`, check that the plugin directory is
populated before changing the keymaps.
