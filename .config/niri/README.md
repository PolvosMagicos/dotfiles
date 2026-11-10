# Niri

Personal Wayland desktop configuration in [config.kdl](config.kdl).
[Quickshell](../quickshell/README.md) provides the bar and wallpaper;
[Fuzzel](../fuzzel/README.md) is the application launcher.

## Setup and machine settings

Enable Niri in the companion NixOS configuration and link this directory
through Home Manager, following the [repository setup](../../README.md).
Startup launches `quickshell` and focuses the named ASUS monitor.

Review these values before using the config on another machine:

- Laptop outputs `eDP-1` and `eDP-2`: 1920×1200 at 165 Hz, position -1920,120.
- External output `ASUSTek COMPUTER INC PA278QV LCLMQS146583`: 2560×1440 at
  74.924 Hz, position 0,0; also used by the startup focus command.
- Mouse acceleration, natural touchpad scrolling and Caps Lock as Compose.
- Gaps of eight pixels and an initial column width of half the display.

In a running session, discover your outputs with:

```bash
niri msg outputs
```

## Configured shortcuts

`Mod` uses Niri's session modifier (normally Super on a TTY session).
`Mod+Shift+Slash` opens the hotkey overlay. Common bindings are:

| Shortcut | Action |
| --- | --- |
| `Mod+T` / `Mod+D` | Kitty / Fuzzel |
| `Mod+Shift+T` | NormCap text capture |
| `Super+Alt+L` | swaylock |
| `Super+Alt+S` | Toggle the `orca` process |
| `Mod+Q` / `Mod+O` | Close window / overview |
| `Mod+Arrow` or `Mod+H/J/K/L` | Focus an adjacent column/window |
| Add `Ctrl` to a focus binding | Move the column/window |
| `Mod+Shift+Arrow` | Focus another monitor |
| `Mod+1` through `Mod+9` | Select workspace |
| `Mod+Ctrl+1` through `Mod+Ctrl+9` | Move column to workspace |
| `Mod+U` / `Mod+I` | Next/previous workspace |
| `Mod+R` / `Mod+Shift+R` | Change column width / window height preset |
| `Mod+F` / `Mod+Shift+F` | Maximize column / fullscreen |
| `Mod+V` | Toggle floating |
| `Mod+W` | Toggle tabbed column display |
| `Mod+Shift+E` | Quit the session |
| `Mod+Shift+P` | Turn monitors off |

Media keys call `wpctl` and `playerctl`; backlight keys call `brightnessctl`.
Other launch bindings require their named applications on PATH. Locking,
text capture and Orca are provided by those programs, not by Niri itself.
Screenshot, layout and window-rule settings remain in `config.kdl`.

## Validate changes

```bash
niri validate --config ~/dotfiles/.config/niri/config.kdl
```

This checks configuration validity. Display modes, monitor placement,
shortcuts and external applications still need a running desktop session.
