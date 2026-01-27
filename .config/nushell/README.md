# Nushell macOS Config Symlink Guide

This guide is **macOS-only**.

It explains how to make Nushell on macOS use `~/.config/nushell`
by symlinking it to the native macOS Nushell config location.

This setup assumes:
- You use a **separate branch for macOS**
- Linux is handled independently
- You want reproducibility for future machines

## Background (macOS)

On macOS, Nushell loads its configuration from:

```
$HOME/Library/Application Support/nushell
```

On Linux, Nushell uses:

```
~/.config/nushell
```

Nushell **does not allow changing** `$nu.default-config-dir`.

The correct and supported solution on macOS is to create a **symlink**
from the macOS directory to `~/.config/nushell`.

## One-time setup (macOS only)

### 1. Ensure the Nushell config exists in `~/.config`

```bash
mkdir -p ~/.config/nushell
```

### 2. Ensure macOS Application Support exists

```bash
mkdir -p "$HOME/Library/Application Support"
```

### 3. Remove any existing Nushell config directory (if present)

⚠️ This removes only the macOS directory, not your actual config.

```bash
rm -rf "$HOME/Library/Application Support/nushell"
```

### 4. Create the symlink

```bash
ln -s ~/.config/nushell "$HOME/Library/Application Support/nushell"
```

## Verification

Run:

```bash
nu -c '$nu.default-config-dir'
```

Expected output:

```
/Users/<you>/Library/Application Support/nushell
```

Then verify the symlink:

```bash
ls "$HOME/Library/Application Support/nushell"
```

You should see the contents of `~/.config/nushell`.

Inside Nushell, these commands should open the correct files:

```nu
config nu
config env
```

## Result

- macOS Nushell uses `~/.config/nushell`
- Config layout matches Linux-style XDG layout
- No environment variable hacks
- No wrapper scripts
- Fully reproducible on fresh macOS installs

## Reverting (if ever needed)

```bash
rm "$HOME/Library/Application Support/nushell"
mkdir -p "$HOME/Library/Application Support/nushell"
```

## Notes

- This guide applies **only to macOS**
- Linux does not require this setup
- Intended for dotfiles managed with Git + Stow

