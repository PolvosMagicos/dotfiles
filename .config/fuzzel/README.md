# Fuzzel

Wayland application launcher, opened by `Mod+D` in the
[Niri configuration](../niri/README.md). The active settings are in
[fuzzel.ini](fuzzel.ini).

## Setup

Install `fuzzel`, `kitty`, JetBrainsMono Nerd Font and an icon theme providing
`hicolor` icons, then link this directory through Home Manager. See the
[repository setup](../../README.md).

In a Wayland session, run:

```bash
fuzzel
```

## Configured appearance and behavior

The launcher uses a 13 pt font, application icons, 12 result lines, a width
of 45 characters and Catppuccin-style colors. Results search application
names, generic names, comments, categories and desktop filenames.
Terminal applications open in Kitty. The window uses the overlay layer and
closes when it loses keyboard focus.

Edit `[main]` for layout and search fields, `[colors]` for the palette and
`[border]` for its two-pixel border and 12-pixel radius. Missing icons or
glyphs should be checked against the installed theme and font first.
