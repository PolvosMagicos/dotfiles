# macOS dotfiles

The `macos` branch shares the Nushell, Neovim, Kitty, Yazi, MPV, music and asset
updates from `nixos`. It excludes Quickshell, Niri, Fuzzel, systemd services, Linux
container settings, Nix commands and the QML/Nix desktop editor tooling.

## Install dependencies

Install Apple's Command Line Tools (`xcode-select --install`) and
[Homebrew](https://brew.sh), then run:

```bash
git clone --branch macos --recurse-submodules https://github.com/PolvosMagicos/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/install-macos.sh
```

For an existing checkout, switch to `macos` and run
`git submodule update --init` before installing.

The script installs the [Brewfile](Brewfile) with
[`brew bundle install --no-upgrade`](https://docs.brew.sh/Brew-Bundle-and-Brewfile).
It installs missing packages without requesting upgrades to existing packages.
Homebrew may still update dependencies required by a new package. It works with
Homebrew on Apple Silicon and Intel, and also accepts `brew` already on `PATH`.
It does not link configs or start services.

The Brewfile includes terminal apps, shell tools, Neovim's configured language
servers and formatters, Rust, Yazi's preview/archive tools, music/video players,
Java 17, Android command-line tools and Flutter. Apple's tools provide `make`,
the C compiler and `clangd`. Neovim requires 0.12 or newer; Lazy restores the
shared plugin lockfile, and Tree-sitter downloads its parsers on first launch.
Ruff uses its native language server for Python diagnostics, formatting and code
actions; the removed none-ls Ruff sources are no longer referenced.

Android SDK platforms/build tools, Android license acceptance, Xcode/iOS setup
and the ESP32 toolchain remain project-specific setup. The `esp-env` command
expects your own `~/export-esp.sh`. The `jb`/`jl` aliases expect Jupyter in your
Python environment. Vial is installed separately from
[its releases](https://github.com/vial-kb/vial-gui/releases); its Homebrew cask is
currently disabled. Import the keyboard layouts from `vial-layouts/` manually.
The `nixos` and `macos` branches share the updated `vial-layouts/colemak.vil`
profile; load it in Vial to apply the Colemak mapping to the keyboard.

## Link configs

Preview and apply the Stow package from your home directory:

```bash
cd ~
stow -nv --no-folding dotfiles
stow --no-folding dotfiles
```

Move aside any conflicting configs before applying. Stow excludes the Brewfile,
scripts, tests, assets, keyboard layout exports, shell backups, and generated
MPD state. Assets stay in the checkout; the Nushell banner finds its image there.
Use `--no-folding` so exclusions inside config directories are respected.

Nushell on macOS also needs the native Application Support link. Follow the
[Nushell setup guide](.config/nushell/README.md), which preserves an existing
configuration before linking it.

Kitty finds Homebrew's `nu` on either architecture. Nushell initializes Homebrew
before zoxide and fnm, uses registered macOS JDKs, and preserves an existing
`JAVA_HOME` or `ANDROID_HOME`. Android defaults to `~/Library/Android/sdk` when
present, otherwise Homebrew's `share/android-commandlinetools` SDK.
Homebrew's Node works immediately; use `fnm install --lts` and `fnm default lts-latest`
if you want fnm to manage a separate Node installation.

## Music

MPD uses macOS CoreAudio and keeps the FIFO output used by rmpc's visualizer.
Create its runtime directories and start it explicitly after linking:

```bash
mkdir -p ~/.config/mpd/{playlists,database,log,state}
mpd ~/.config/mpd/mpd.conf
rmpc
```

This does not install a background service. The standalone Cava config uses its
platform default input; system audio capture may need a separately configured
loopback device.

## Checks

```bash
bash -n scripts/install-macos.sh
python3 -m unittest discover -s tests -v
nvim --headless -u NONE -i NONE -l tests/nvim-check.lua
brew bundle check --file=Brewfile
```

The automated installer tests use a fake `brew`; they do not install packages.
A real macOS run is still needed to verify package installation, Kitty's GUI,
audio output and mobile tooling.
