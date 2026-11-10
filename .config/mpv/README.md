# MPV

Video player settings in [mpv.conf](mpv.conf). Install `mpv` and link this
directory using the [repository setup](../../README.md).

## NixOS setup

Install `mpv` through Nix and link this directory with Home Manager. Both branches
use the same active playback options; their config differences are comments and
whitespace. Hardware decoding support depends on the Linux MPV build and GPU
drivers. No backend-specific decoding method is forced by this file.

## Active settings

| Option | Purpose |
| --- | --- |
| `vo=gpu-next` | Use the gpu-next renderer |
| `hwdec=auto-safe` | Try supported hardware decoding |
| `video-sync=display-resample` | Synchronize playback to the display |
| `interpolation` | Enable motion interpolation |
| `tscale=oversample` | Select the interpolation filter |
| `save-position-on-quit` | Remember the playback position |

Launch a local video with:

```bash
mpv /path/to/video.mkv
```

Hardware decoding depends on the MPV build, GPU, drivers and media format.
If interpolation is unwanted, remove or comment out `interpolation` in
`mpv.conf`. Use `--no-config` to compare playback against MPV's defaults:

```bash
mpv --no-config /path/to/video.mkv
```
