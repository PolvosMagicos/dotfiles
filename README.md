# NixOS dotfiles

Personal terminal, editor and Wayland desktop configuration for NixOS.

Branches: **nixos** · [macos](https://github.com/PolvosMagicos/dotfiles/tree/macos)
(Homebrew and Stow setup).

![Terminal screenshot](assets/screenshots/terminal.png)
![Neovim screenshot](assets/screenshots/neovim.png)

## What's included

| Area | Configuration |
| --- | --- |
| Desktop | Niri, Quickshell bar and wallpaper, Fuzzel launcher |
| Terminal and shell | Kitty, JetBrainsMono Nerd Font, Nushell, zoxide and fnm |
| Editor | Neovim, Lazy, Catppuccin, Tree-sitter, Telescope and language servers |
| Files and containers | Yazi and Podman registry/policy settings |
| Media | MPV, MPD, rmpc and Cava |
| Keyboard | Vial Colemak and QWERTY exports |

Application settings live in [`.config/`](.config). Wallpapers, profile pictures
and screenshots live in [`assets/`](assets), keyboard exports in
[`vial-layouts/`](vial-layouts), and retired configurations in
[`deprecated/`](deprecated).

## Setup

Clone this branch to the path used by the shell banner, Kitty backgrounds and
the companion Home Manager configuration:

```bash
git clone --branch nixos https://github.com/PolvosMagicos/dotfiles.git ~/dotfiles
```

Packages, hardware configuration and Home Manager integration live in
[`nixos-config`](https://github.com/PolvosMagicos/nixos-config).
Its [`home/xdg.nix`](https://github.com/PolvosMagicos/nixos-config/blob/HEAD/home/xdg.nix)
uses `mkOutOfStoreSymlink` to link these directories from `~/dotfiles/.config`
into `~/.config`:

```text
cava  containers  fuzzel  kitty  mpd  mpv  nushell  nvim  rmpc  yazi  niri  quickshell
```

Back up conflicting configs before activating Home Manager. If you already use
the companion configuration at `~/nixos-config`, apply it with:

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos-btw
```

That flake is specific to the `nixos-btw` machine. Adapt its user, hardware and
host settings before using it elsewhere. Use Home Manager for links on NixOS.

Install the applications you use through Nix. Nushell calls `zoxide` and `fnm`
during startup, and Kitty launches `nu`. Neovim also needs the language servers,
formatters and build tools referenced in its plugin configuration; Lazy manages
plugins, while Tree-sitter installs parsers when its CLI is available.

## Desktop

[Niri](.config/niri/config.kdl) starts Quickshell and provides these shortcuts:

| Shortcut | Action |
| --- | --- |
| `Mod+T` | Open Kitty |
| `Mod+D` | Open Fuzzel |
| `Super+Alt+L` | Lock with swaylock |
| `Mod+Shift+T` | Capture text with NormCap |

[Quickshell](.config/quickshell) supplies the bar, workspaces, hardware monitors,
notifications, Bluetooth and audio controls. The companion configuration adds
the QML Niri and Qt Multimedia modules. Review Niri's output names, resolutions
and startup monitor, plus the absolute wallpaper path in
[`Wallpaper.qml`](.config/quickshell/layout/Wallpaper.qml), for your machine.

## Shell and editor

[Nushell](.config/nushell) includes the `y` wrapper to follow Yazi's last directory,
zoxide navigation, fnm initialization, Java discovery and Android/Flutter paths.
The Android SDK defaults to `~/Android/Sdk`, Flutter to `~/flutter`, and
`esp-env` expects your own `~/export-esp.sh`. The `jb` and `jl` aliases require
Jupyter in your Python environment.

The [NixOS commands](.config/nushell/scripts/nixos-commands.nu) target
`~/nixos-config#nixos-btw`:

| Command | Action |
| --- | --- |
| `nsw` | Build and switch to the system configuration |
| `nboot` | Build the configuration for the next boot |
| `ntest` | Activate the configuration for testing |
| `nupdate` | Update flake inputs, update pinned GitHub releases, then rebuild and switch |
| `nclean` | Keep five system generations, refresh boot entries and collect unreferenced Nix data |

`nclean` also preserves generations newer than the active one after a rollback.
It removes older generations, so use it when those rollback points are no longer
needed.

[Neovim](.config/nvim) keeps plugins under `lua/polvos-magicos/plugins`, native
language server definitions under `plugins/lsp/servers`, and plugin revisions
in `lazy-lock.json`. It includes TypeScript, Rust, Flutter, QML/Nix tooling,
formatting on save and ISML filetype support.

Yazi's archive shortcuts use `compress.yazi`. This branch records that plugin as
a Git link without a `.gitmodules` entry, so a fresh clone needs it installed
separately. The mount plugin is listed in [Yazi's package file](.config/yazi/package.toml).

## Optional music setup

MPD reads `~/Music`, listens on `/tmp/mpd_socket`, and sends audio to PulseAudio
and `/tmp/mpd.fifo`. rmpc uses that FIFO for its Cava visualizer. After installing
`mpd`, `rmpc` and `cava`, create the runtime directories and start playback:

```bash
mkdir -p ~/.config/mpd/{playlists,database,log,state}
mpd ~/.config/mpd/mpd.conf
rmpc
```

The checked-in [systemd user unit](.config/systemd/user/mpd.service) uses
`/usr/bin/mpd` and is outside the companion Home Manager link list. Define a
service with the Nix package path before enabling it on NixOS.

## Keyboard and local data

Load [`vial-layouts/colemak.vil`](vial-layouts/colemak.vil) in Vial to apply the
Colemak profile shared with `macos`. A QWERTY export is also included. Layouts,
assets and deprecated files stay in the checkout and are used manually.

Nushell history and most MPD runtime files are covered by [`.gitignore`](.gitignore).
The existing MPD database is tracked, as are shell backup files, so review their
contents before committing local changes.
