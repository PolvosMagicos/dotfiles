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

## Platform differences

These are the differences in the checked-in branches. Individual guides below
cover the setup and machine-specific paths for each config.

| Area | NixOS | macOS |
| --- | --- | --- |
| Packages and config links | Nix packages; Home Manager links application configs | Homebrew/Brewfile; Stow with `--no-folding` |
| Nushell config location | `~/.config/nushell` | Native Application Support directory linked to `~/.config/nushell` |
| Nushell development paths | Java resolved from `javac`; Android set to `~/Android/Sdk` | Registered macOS JDK discovery; preserves `JAVA_HOME`/`ANDROID_HOME`; Android SDK or Homebrew fallback |
| Nushell startup and helpers | Nix rebuild/update/cleanup commands; banner called by `env.nu` | Homebrew PATH initialized first; interactive banner with Kitty checks; no Nix helpers |
| Kitty | `nu` resolved from the Nix-provided PATH | Adds Apple Silicon and Intel Homebrew executable search paths |
| MPD | `pulse` output for PulseAudio/PipeWire compatibility; saved systemd unit needs adaptation | `osx` output for CoreAudio; installer starts no service |
| Cava | Build-selected capture backend for the Linux audio setup | Build-selected capture backend; system audio capture may need a loopback device |
| rmpc | Same socket, FIFO and client settings as macOS | Same socket, FIFO and client settings as NixOS |
| MPV | Same active playback settings as macOS; decoding depends on the installed build/GPU | Same active playback settings as NixOS; decoding depends on the installed build/GPU |
| Yazi | Custom `M` mount manager; archive Git link needs separate initialization | Archive submodule; no custom mount manager or `M` binding |
| Desktop and system configs | Niri, Quickshell, Fuzzel, container settings and saved systemd files | Those configs are omitted |
| Keyboard layouts | Vial installed through Nix; shared layout exports | Vial installed separately; same layout exports |

## Configuration guides

Each config has its own setup, dependencies and usage notes:

| Config | Guide |
| --- | --- |
| [cava](.config/cava/README.md) | Standalone audio visualizer |
| [containers](.config/containers/README.md) | Podman registry and image-signature policy |
| [fuzzel](.config/fuzzel/README.md) | Wayland application launcher |
| [kitty](.config/kitty/README.md) | Terminal, font, shell and background |
| [mpd](.config/mpd/README.md) | Local music server and visualizer FIFO |
| [mpv](.config/mpv/README.md) | Video rendering and playback |
| [niri](.config/niri/README.md) | Desktop outputs, layout and shortcuts |
| [nushell](.config/nushell/README.md) | Shell startup, paths and helper commands |
| [nvim](.config/nvim/README.md) | Editor plugins, language tools and shortcuts |
| [quickshell](.config/quickshell/README.md) | Desktop bar, wallpaper and device controls |
| [rmpc](.config/rmpc/README.md) | Music client and embedded visualizer |
| [systemd](.config/systemd/README.md) | Saved MPD user service and portability notes |
| [yazi](.config/yazi/README.md) | File manager, plugins and archive shortcuts |

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
