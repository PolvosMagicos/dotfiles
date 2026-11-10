# MPD

Local music server configured by [mpd.conf](mpd.conf). This optional stack feeds
[rmpc](../rmpc/README.md); it is independent of the shell and editor.
See the [repository setup](../../README.md) for config linking.

## Platform setup

The audio output is `pulse`; it needs a PulseAudio server or PipeWire with
PulseAudio compatibility. Install `mpd` separately if your Nix configuration
does not provide it. The saved [systemd unit](../systemd/README.md) needs
NixOS-specific adaptation before use.

## Paths and outputs

| Purpose | Path |
| --- | --- |
| Music library | `~/Music` |
| Saved playlists | `~/.config/mpd/playlists` |
| Database | `~/.config/mpd/database/mpd.db` |
| Log | `~/.config/mpd/log/mpd.log` |
| PID | `~/.config/mpd/pid` |
| Playback state | `~/.config/mpd/state/mpd.state` |
| Client socket | `/tmp/mpd_socket` |
| Visualizer FIFO | `/tmp/mpd.fifo` |

The FIFO is stereo, 44.1 kHz, 16-bit PCM, matching rmpc's Cava input. Keep both
configs aligned if you change its path or format.

## Start and use

After linking, create the runtime directories and start a single MPD instance:

```bash
mkdir -p ~/.config/mpd/{playlists,database,log,state}
mpd ~/.config/mpd/mpd.conf
rmpc update
rmpc
```

Put music in `~/Music` before scanning. `rmpc update` refreshes MPD's library;
it does not add tracks to the playback queue. Use rmpc's browser to queue them.

If the client cannot connect, check that MPD started, inspect `mpd.log`, and
compare the socket address with rmpc's config. If the visualizer is silent,
check that the FIFO output is enabled and audio is playing.

Runtime data belongs to each machine. The existing database is tracked by Git,
even though `.gitignore` excludes newly generated state; review database changes
before committing.
