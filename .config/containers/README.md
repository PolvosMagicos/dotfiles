# Containers

User-level image registry and trust settings for Podman and related
containers/image tools. Follow the [repository setup](../../README.md) to
install Podman and link this directory to `~/.config/containers`.

## Files

| File | Behavior |
| --- | --- |
| [registries.conf](registries.conf) | Resolve unqualified image names through `docker.io` |
| [policy.json](policy.json) | Accept images without requiring signature verification |

The policy uses `insecureAcceptAnything` as its default and for the
`docker-daemon` transport. This is an image-signature policy, not a setting
that disables registry TLS. Use fully qualified image names when choosing
a registry explicitly, and configure a stricter trust policy if signatures
are required for your environment.

## Usage and local state

Podman reads these files when resolving and checking images. Inspect the
active environment with:

```bash
podman info
```

Registry login credentials and container storage are machine-specific and
are not supplied by these files. Configure credentials with the container
tool rather than adding them to this directory.
