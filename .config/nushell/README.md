# Nushell on macOS

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
