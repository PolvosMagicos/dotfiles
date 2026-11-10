# systemd user files

Saved user service files for the optional [MPD setup](../mpd/README.md).
These files are separate from the application configs linked by the
companion Home Manager configuration; see the [repository setup](../../README.md).

## Included files and portability

[user/mpd.service](user/mpd.service) starts MPD with `Type=notify` and
`ExecStart=/usr/bin/mpd --systemd`. It defines runtime limits and sandbox
settings and declares `WantedBy=default.target`.

`user/default.target.wants/mpd.service` is an old absolute symlink to
`/home/minion/.config/systemd/user/mpd.service`. Do not use that saved
enablement link for a different account.

## NixOS setup

Define MPD through the service configuration you manage in Nix, using its
Nix store executable path. Create the runtime directories listed in the
MPD guide and ensure the service loads the intended `mpd.conf`. Avoid
starting both a manual MPD process and a service on the same socket.

The saved unit and enablement link need adaptation before deployment;
linking the rest of this repository does not activate them.

## Inspect a configured service

Once you have installed a user service, inspect it with:

```bash
systemctl --user status mpd.service
journalctl --user -u mpd.service
```

These commands inspect the active machine. The tracked files alone do not
establish that a service has been installed, enabled or started.
