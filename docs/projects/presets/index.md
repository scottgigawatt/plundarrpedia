---
title: Choose a Preset
description: Compare the maintained Plundarr presets and select the smallest generated deployment that fits the job.
icon: material/view-grid-plus
status: updated
---

# Choose a Plundarr preset

Maraudarr generates every normal deployment under `dist/<preset>/` with one commented `docker-compose.yml`, one editable `.env`, and the selected service configuration directories. Choose the smallest preset that owns the job, then add or remove optional services deliberately.

## Compare the presets

| Preset | Primary purpose | Required core | Removable defaults |
| --- | --- | --- | --- |
| `plundarr` | Movies, television, subtitles, ebooks, requests, monitoring, and VPN-protected downloads | Privateerr, Gluetun, Prowlarr, Radarr, Sonarr, Bazarr, Seerr, Homepage, Duplicati, and monitoring services | qBittorrent, Calibre-Web Automated, Cleanuparr, Watchtower |
| `boudoirr` | Whisparr-focused automation through the same VPN lane | Privateerr, Gluetun, FlareSolverr, Prowlarr, Whisparr | qBittorrent, Cleanuparr, Watchtower |
| `jellyfin` | One focused Jellyfin media server | Jellyfin | None |
| `plex` | One focused Plex Media Server | Plex | None |
| `calibre-web-automated` | Ebook library and automatic ingest | Calibre-Web Automated | None |
| `duplex` | Plex metadata, artwork, monitoring, notifications, and recovery | Kometa, ImageMaid, Tautulli | PATTRMM, Notifiarr, Overlay Reset |
| `watchtower` | Persistent or one-shot updates for eligible host containers | Watchtower | None |
| `custom` | A deployment assembled service by service | None | None |

Preset core services cannot be removed. Defaults are preselected conveniences that you may remove interactively or with `REMOVE_SERVICES`. Maraudarr resolves required companions before writing the final project.

## Generate and inspect a preset

```sh
make presets
make services
make ship PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Replace `YOUR-PRESET` with a preset ID from the table. Review `dist/YOUR-PRESET/.env` before running `make up PRESET=YOUR-PRESET`.

## Add or remove services

`ADD_SERVICES` and `REMOVE_SERVICES` accept comma-separated service IDs:

```sh
make ship PRESET=duplex ADD_SERVICES=watchtower
make ship PRESET=plundarr REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=nzbget
make ship PRESET=plundarr REMOVE_SERVICES=calibre-web-automated
```

The old `OPTIONAL_SERVICES` interface has been removed. Maraudarr fails fast when it appears so an old automation command cannot silently generate the wrong fleet.

## Run presets side by side

Each preset has a separate Compose project, network allocation, host-port range, and `dist/<preset>/` directory. The generated defaults occupy a predictable sequence from `172.20.0.0/16` through `172.28.0.0/16`, with `172.26.0.0/16` reserved for the separately deployed Paperless project.

Change a subnet when it overlaps your local-area network, another Docker network, or a route reached through a virtual private network. Plex uses host networking and is the main exception to the bridge-network pattern.

## Move from an older standalone chart

Use the matching Plundarr preset as a migration target, not an in-place Compose replacement:

1. Back up the old environment and application state.
2. Generate the matching preset with the services you intend to keep.
3. Map old values into the generated `.env` and verify every host path.
4. Move persistent state only while the related containers are stopped.
5. Validate the generated Compose model, then cut over one project at a time.

The older repositories can remain useful as historical references, but the generated Plundarr routes keep current deployment behavior, dependency updates, and documentation in one maintained catalog.

[Generate the default Plundarr stack](../plundarr/quick-start.md){ .md-button .md-button--primary }
[Read the configuration guide](../plundarr/configuration.md){ .md-button }
