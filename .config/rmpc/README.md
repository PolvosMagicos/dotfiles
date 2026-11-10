# rmpc

Terminal client for [MPD](../mpd/README.md), with album art, a queue and an
embedded Cava visualizer. Install `rmpc` and `cava`, and link this directory
using the [repository setup](../../README.md).

## NixOS setup

Install `rmpc` and `cava` through Nix and link this directory with Home Manager.
The rmpc config files are identical on `macos`: both use `/tmp/mpd_socket` and
`/tmp/mpd.fifo`. The platform-specific audio output is configured in MPD;
this branch uses its `pulse` output for PulseAudio/PipeWire compatibility.

## Configuration

[config.ron](config.ron) is the main config; [config.debug.ron](config.debug.ron)
is an alternate file and is not loaded by the normal `rmpc` command.

The client connects to `/tmp/mpd_socket` and stores its cache under
`/tmp/rmpc/cache`. The Queue tab splits album art, the queue and the visualizer;
the other tabs browse directories, artists, albums, playlists and tags.
Mouse support and config hot reload are enabled.

Start MPD using its setup guide, then run:

```bash
rmpc
```

## Configured controls

| Key | Action |
| --- | --- |
| `p` | Pause/resume |
| `s` | Stop |
| `<` / `>` | Previous/next track |
| `,` / `.` | Lower/raise volume by five |
| `b` / `f` | Seek backward/forward |
| `Tab` / `Shift+Tab` | Next/previous tab |
| `1` through `7` | Select a tab |
| `a` / `A` | Add selected/all browser items to the queue |
| `Enter` in Queue | Play the selected track |
| `d` / `D` in Queue | Delete selected track / clear the queue |
| `u` / `U` | Update/rescan the library |
| `O` | Show MPD outputs |
| `~` | Show help |
| `q` | Quit the client |

## Visualizer and troubleshooting

The `cava` section reads `/tmp/mpd.fifo` as stereo 44.1 kHz, 16-bit PCM.
MPD must be playing with its FIFO output enabled. These settings belong to
rmpc and are separate from the [standalone Cava config](../cava/README.md).

If connection fails, check MPD's log and the matching socket paths. Album
art uses automatic terminal protocol detection; Kitty supports image display.
HTTP/HTTPS album-art protocols are disabled in this config.
