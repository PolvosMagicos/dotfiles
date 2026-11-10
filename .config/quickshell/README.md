# Quickshell

QML desktop shell for the [Niri session](../niri/README.md), providing a bar,
wallpaper, notifications, hardware statistics and device controls.
Follow the [repository setup](../../README.md) for Home Manager linking.

## Dependencies

Use Quickshell with the QML Niri module (`import Niri 0.1`) and Qt Multimedia,
as configured in the companion NixOS package definition. The widgets also use:

| Feature | Runtime dependency |
| --- | --- |
| Workspaces | Running Niri session and its IPC connection |
| Volume and output selection | PipeWire |
| Wi-Fi status | Quickshell Networking / NetworkManager |
| Bluetooth | BlueZ; Blueman's pairing agent, reached through `busctl` |
| Battery | UPower |
| Brightness | Linux backlight sysfs, logind or `brightnessctl` |
| CPU and memory | `/proc/stat`, `free`, `awk` and shell tools |
| AMD / NVIDIA utilization | AMD DRM sysfs / `nvidia-smi` |
| Icons and text | Papirus icons and JetBrainsMono Nerd Font |

Niri starts the shell automatically. For a manual launch after linking:

```bash
quickshell --no-duplicate --path ~/dotfiles/.config/quickshell
```

## Files to edit

| File or directory | Purpose |
| --- | --- |
| [shell.qml](shell.qml) | Load wallpaper and bar |
| [layout/Bar.qml](layout/Bar.qml) | Per-screen panel, widget arrangement and Niri service |
| [layout/Wallpaper.qml](layout/Wallpaper.qml) | Wallpaper path and placement |
| [Theme.qml](Theme.qml) | Fonts and sizes |
| [style/theme.js](style/theme.js) | Catppuccin Mocha palette |
| [Config.qml](Config.qml) | Notification timeout |
| [widgets/](widgets) | Hardware indicators, popups and controls |
| [services/Time.qml](services/Time.qml) | Shared clock |
| [qmldir](qmldir) | Exported QML types and singletons |

The wallpaper has an absolute `/home/polvos-magicos/dotfiles/...` path;
change it for a different user or checkout. Notifications are attached to
the first screen, while the bar is created for each screen.

## Controls

Click a workspace to focus it. Bluetooth opens a discovery/connection popup.
Brightness opens a slider for the detected internal backlight. Left-click
volume for its slider and output selector; right-click volume to mute.
Widgets depend on the services and devices above being available.

## Editor setup and checks

[.qmlls.ini](.qmlls.ini) contains machine-specific Nix store and runtime build
paths. Refresh them when package revisions change; the NixOS Neovim config
launches `qmlls -E --build-dir build`.

The checked-in fixtures exercise Bluetooth states and volume behavior. Run
them from a suitable Qt/Quickshell environment:

```bash
quickshell --path ~/dotfiles/.config/quickshell/bluetooth-check.qml
quickshell --path ~/dotfiles/.config/quickshell/volume-check.qml
```

These fixture checks do not prove physical pairing, audio routing, display
placement or backlight control. Verify those in the running Niri session.
