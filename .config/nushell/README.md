# Nushell on NixOS

Shell environment for Kitty, zoxide navigation and development tools. Install
`nushell`, `zoxide`, `fnm` and `neovim` through Nix, then let Home Manager link this
directory to `~/.config/nushell`. See the [repository setup](../../README.md).

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

## NixOS paths and commands

Java is discovered by resolving the `javac` executable, assigning `JAVA_HOME`
when it is found. Android is assigned `~/Android/Sdk`; unlike the macOS branch,
these assignments do not preserve existing SDK environment overrides.
Flutter is looked up under `~/flutter`, and the config sets
`CHROME_EXECUTABLE` to `/usr/bin/chromium-browser`. Adjust these paths when your
tools live elsewhere. The banner's image is under `~/dotfiles/assets` and uses
Kitty's image helper. `env.nu` calls the banner without the macOS branch's
interactive-session and Kitty availability checks. Tools such as zoxide and fnm
must be on the Nix-provided PATH before startup; this branch does not perform
the macOS branch's early Homebrew initialization.

[scripts/nixos-commands.nu](scripts/nixos-commands.nu) targets the personal flake
`~/nixos-config#nixos-btw`:

| Command | Behavior |
| --- | --- |
| `nsw` | Build and switch |
| `nboot` | Build for the next boot |
| `ntest` | Activate for testing |
| `nupdate` | Update flake inputs, update pinned GitHub releases, rebuild and switch |
| `nclean` | Keep five system generations, refresh boot entries, garbage collect |

Adapt the flake path and host before reusing these helpers. `nclean` deletes
older rollback generations and unreferenced store data; run it when those are
no longer needed.
