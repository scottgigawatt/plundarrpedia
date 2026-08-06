---
title: Plundarr Quick Start
description: Generate, review, and launch the default Plundarr stack.
icon: material/rocket-launch
---

# Plundarr quick start

## 1. Clone the repository

```console
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
```

## 2. Generate the default voyage

```console
make ship
```

Maraudarr prefers an available local image, then a published image, then a
local build from the checkout. It writes the finished Compose project into the
repository root.

!!! important "Refresh Maraudarr before an upgrade"
    `make ship` reuses an available local Maraudarr image. Before regenerating
    an existing deployment to pick up a newer release, refresh the generator:

    ```console
    make update-maraudarr
    make configure
    ```

    Plundarr v1.0.2 requires regeneration to add the rootless identity shared
    by Apprise and Seerr. Existing `.env` values and application state are
    preserved; no data or mount migration is required.

For the interactive configurator instead:

```console
make configure
```

Useful discovery commands:

```console
make presets
make services
```

## 3. Edit `.env`

At minimum, review:

| Setting                             | Why it matters                                            |
| ----------------------------------- | --------------------------------------------------------- |
| `PIA_USER` / `PIA_PASS`             | Required when the Privateerr/Gluetun lane uses PIA.       |
| `DEFAULT_PUID` / `DEFAULT_PGID`     | Must match a host identity that can access mounted files. |
| `DEFAULT_GROUP`                     | Supplemental group used for shared host-path access.      |
| `HOST_DOWNLOADS_PATH`               | Shared download root used by clients and managers.        |
| `HOST_MOVIES_PATH` / `HOST_TV_PATH` | Final libraries seen by managers and playback servers.    |
| `TZ`                                | Keeps logs and schedules aligned with your location.      |
| `*_WEBUI_PORT`                      | Must not collide with another host service.               |

The checked-in defaults use Synology-shaped paths as examples. Linux and
Docker Desktop users should replace them with real absolute host paths.

## 4. Inspect before launch

```console
make config
```

This asks Docker Compose to resolve the project using `.env`. Warnings about
missing variables, invalid networks, or bad interpolation are cheaper to fix
before containers exist.

## 5. Launch

```console
make up
```

Then validate the VPN lane before configuring download clients or managers:

```console
make test-vpn
```

!!! warning
    VPN tests may use real PIA credentials and inspect live generated WireGuard
    material. Never commit `.env`, `wg0.conf`, `privateerr.env`, forwarded ports,
    or test logs.

## Common variations

```console
# Use SABnzbd instead of qBittorrent
make ship PRESET=plundarr OPTIONAL_SERVICES=sabnzbd

# Add Plex to the generated stack
make ship OPTIONAL_SERVICES=qbittorrent,cleanuparr,plex

# Generate the Boudoirr preset
make ship PRESET=boudoirr \
  OPTIONAL_SERVICES=qbittorrent,sabnzbd,cleanuparr,watchtower
```

Regeneration preserves known environment values by variable name. Still,
back up `config/` before a major migration and inspect the generated diff before
launching it.
