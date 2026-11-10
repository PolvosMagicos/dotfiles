# Cava

Standalone terminal audio visualizer. See the [repository setup](../../README.md)
for package installation and config linking.

## macOS setup

The [Brewfile](../../Brewfile) installs `cava`; link this directory with Stow.
The file is identical on `nixos`, but capture depends on the macOS build and
available audio devices. This config does not set up system-output capture;
a loopback device may be needed to capture that audio.

## Configuration

[config](config) is a commented reference configuration: only section headers
are active, so Cava uses its compiled defaults for input, output and colors.
The GLSL files in [shaders/](shaders) are available examples; no shader is
selected by this config.

After installing `cava`, launch it with:

```bash
cava
```

Choose the capture backend and source in the `[input]` section if the default
is silent. Available backends depend on the installed Cava build.

## Relationship to the music setup

[rmpc](../rmpc/README.md) has its own Cava settings inside `config.ron` and
reads the FIFO created by [MPD](../mpd/README.md). Editing this standalone
config does not change rmpc's embedded visualizer.
