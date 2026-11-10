# Nushell on macOS

Shell environment shared with the terminal setup. Install Nushell, zoxide,
fnm and Neovim with the [Brewfile](../../Brewfile), then follow the
[repository setup](../../README.md) to link configs with Stow.

## Native macOS config location

After installing dependencies and linking this repo with Stow, point Nushell's
native macOS config location to `~/.config/nushell`:

```bash
mkdir -p "$HOME/Library/Application Support"
```

If `~/Library/Application Support/nushell` already exists, inspect it first. Keep
it if it is already the correct symlink. Otherwise move it to an unused backup
path before creating the link, for example:

```bash
mv "$HOME/Library/Application Support/nushell" "$HOME/Library/Application Support/nushell.backup"
```

Choose a different backup name if that one already exists. Then create the link:

```bash
ln -s "$HOME/.config/nushell" "$HOME/Library/Application Support/nushell"
```

Launch `nu`, then check `config nu` and `config env`. They should open this repo's
configuration through the macOS link. `env.nu` makes Homebrew available and
generates `~/.zoxide.nu` on first startup before `config.nu` sources it.

## Files and startup

| File | Role |
| --- | --- |
| [env.nu](env.nu) | Early environment setup, zoxide initialization and banner |
| [config.nu](config.nu) | PATH helpers, commands, aliases and editor defaults |
| [banner.nu](banner.nu) | System information and Kitty image banner |
| [scripts/esp-commands.nu](scripts/esp-commands.nu) | `esp-env` command |

`env.nu` creates `~/.zoxide.nu` if missing, before `config.nu` sources it.
Both `zoxide` and `fnm` are called during startup and must already be installed.
`EDITOR` and `VISUAL` are set to `nvim`.

## Commands and optional tools

| Command | Behavior | Needs |
| --- | --- | --- |
| `y [args]` | Open Yazi and follow its last working directory on exit | `yazi`, `mktemp` |
| `cd` | zoxide-backed navigation | `zoxide` |
| `pls` | Alias for `sudo` | `sudo` |
| `jb` / `jl` | Launch Jupyter Notebook / Lab through Bash | Jupyter in that environment |
| `esp-env` | Import the ESP toolchain environment into this shell | Your `~/export-esp.sh`, Bash |

The config adds existing user bin directories, Cargo, Bun, Android tools and
Flutter paths. Loading a PATH entry does not install the corresponding toolchain.

## Check your setup

Start a new `nu` session after changing startup files. Inside Nushell, use:

```nu
config nu
config env
which zoxide
which fnm
```

`config nu` and `config env` should open this checkout's files. For a startup
failure, check those locations and the missing external command first. Files
named `oldconfig-*` and `oldenv-*` are backups, not active startup files; history
and `~/.zoxide.nu` are generated locally.

## Homebrew, Java and mobile tools

Homebrew's Apple Silicon and Intel paths are added in `env.nu` before zoxide
and fnm run. `JAVA_HOME` is preserved when set; otherwise the config asks
`/usr/libexec/java_home` for a registered JDK. `ANDROID_HOME` is also preserved;
its default is `~/Library/Android/sdk`, or Homebrew's
`share/android-commandlinetools` when that directory is absent.

Homebrew Node is usable directly. To let fnm manage a separate Node installation,
run `fnm install --lts` and `fnm default lts-latest`. Android platforms, licenses,
Xcode/iOS and ESP setup remain project-specific.

The banner runs only in interactive sessions and uses Kitty image display when
available. Its image is resolved relative to `banner.nu`; the NixOS branch uses
a fixed path under `~/dotfiles/assets` and calls the banner without these guards.
This branch has no NixOS rebuild or cleanup commands.
