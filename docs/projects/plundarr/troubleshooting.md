---
title: Troubleshoot Plundarr
description: Diagnose generation, Compose, permissions, VPN, ports, imports, and Synology problems by layer.
icon: material/lifebuoy
---

# Troubleshoot Plundarr

Start at the lowest failing layer. A red Radarr health indicator cannot tell
you whether Docker failed to mount a path, Gluetun never became healthy, or the
download client simply lacks a category.

## Generator problems

```console
make test-maraudarr
make services
make presets
```

If generation fails, inspect the first error before the summary. Maraudarr may
have failed to find a local image, pull the published one, or build a fallback.
Do not confuse a registry/Docker-daemon failure with a bad generated Compose
model.

If generation succeeds but the resulting chart lacks behavior from a newer
release, refresh the generator before rebuilding:

```console
make update-maraudarr
make configure
make config
```

## Compose problems

```console
make config
docker compose ps
docker compose logs --tail=100 SERVICE
```

Common causes:

- `.env` is missing or not beside `docker-compose.yml`;
- a host port is already in use;
- a path is relative to a different project directory than expected;
- the custom subnet overlaps another route;
- a service references an optional companion that was not selected.

## Permission problems

Symptoms include `permission denied`, an app that cannot import downloads, or a
database that repeatedly resets. Compare numeric ownership on the host with the
configured `DEFAULT_PUID`, `DEFAULT_PGID`, and `DEFAULT_GROUP`, then test the
exact mounted directory rather than its parent.

Apprise or Seerr startup failures on Synology can also indicate an old generated
chart. Plundarr v1.0.2 runs both services through the shared rootless identity.
Run `make update-maraudarr`, regenerate the Compose file, and inspect
`make config` before changing host ownership or weakening a read-only
filesystem.

## VPN lane never becomes healthy

Check in order:

1. Privateerr logs show successful configuration generation.
2. `config/gluetun/wireguard/wg0.conf` exists and is non-empty.
3. `privateerr.env` contains the selected endpoint metadata.
4. Gluetun reads the shared directory and starts with `custom` WireGuard.
5. The selected PIA region supports port forwarding when `PIA_PF=true`.
6. The host provides the capabilities/devices required by Gluetun.

```console
make test-vpn
```

## The Web UI is unreachable

When a download client shares `service:gluetun`, publish its UI port on
Gluetun. Connecting to the download-client container's nonexistent independent
IP will fail by design.

On Synology, also confirm the DSM firewall allows the host port and, when
needed, traffic sourced from the Compose subnet.

## NZBGet is healthy but managers cannot connect

- Use `gluetun:6789` from Radarr or Sonarr; do not use the browser-facing host
  port between containers.
- Keep SSL disabled unless you intentionally configured it inside NZBGet.
- Copy `NZBGET_USER` and `NZBGET_PASS` from the generated `.env`.
- Confirm Radarr uses category `radarr` and Sonarr uses category `sonarr`.
- Keep NZBGet's internal control port at `6789`; changing it also requires
  coordinated Compose, healthcheck, Homepage, and manager updates.

## Downloads finish but never import

- Use the same container path for the shared download root.
- Match categories between Radarr/Sonarr and the download client.
- Confirm the manager can read the completed file and write the final library.
- Check whether cross-filesystem moves prevent hardlinks.
- Do not point Plex or Jellyfin at the incomplete download directory.

## Safe reset

Back up `config/` before changing application state. `make down` stops the
stack; it should not be treated as permission to remove volumes or configuration
directories. Use destructive cleanup targets only when you intentionally want
a fresh deployment.
