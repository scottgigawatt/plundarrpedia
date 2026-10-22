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
| `plundarr` | Movies, television, subtitles, ebooks, requests, monitoring, and VPN-protected downloads | Privateerr, Gluetun, FlareSolverr, Prowlarr, Radarr, Sonarr, Bazarr, Seerr, Homepage, Duplicati, Speedtest Tracker, Apprise | qBittorrent, Calibre-Web Automated, Cleanuparr, Watchtower, Tracearr |
| `boudoirr` | Whisparr automation with adult requests, playback, and VPN downloads | Privateerr, Gluetun, FlareSolverr, Prowlarr, Whisparr | qBittorrent, Velvarr, Jellyfin, Cleanuparr, Watchtower |
| `jellyfin` | One focused Jellyfin media server | Jellyfin | None |
| `plex` | One focused Plex Media Server | Plex | None |
| `calibre-web-automated` | Ebook library and automatic ingest | Calibre-Web Automated | None |
| `duplex` | Plex curation, Plex/Jellyfin theme songs, and maintenance | Kometa, ImageMaid, Themerr | PATTRMM Neo, Notifiarr |
| `watchtower` | Persistent or one-shot updates for eligible host containers | Watchtower | None |
| `portainer` | Docker host management through Portainer Community Edition | Portainer | None |
| `custom` | A deployment assembled service by service | None | None |

Preset core services cannot be removed. Defaults are preselected conveniences that you may remove interactively or with `REMOVE_SERVICES`. Maraudarr resolves required companions before writing the final project.

## Generate and inspect a preset

```sh
make presets
make services
make ship PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Complete [generator setup](../plundarr/quick-start.md#choose-the-generator) first. Replace `YOUR-PRESET` with a preset ID from the table. Review `dist/YOUR-PRESET/.env` before running `make up PRESET=YOUR-PRESET`.

## Add or remove services

`ADD_SERVICES` and `REMOVE_SERVICES` accept comma-separated service IDs:

```sh
make ship PRESET=duplex ADD_SERVICES=watchtower
make ship PRESET=plundarr REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=nzbget
make ship PRESET=plundarr REMOVE_SERVICES=calibre-web-automated
```

Keep your complete `ADD_SERVICES` and `REMOVE_SERVICES` selection when regenerating; preserving environment values does not preserve a previous service selection. Tracearr is the default Plundarr monitor; Tautulli and Overlay Reset are optional. See [media monitoring](../plundarr/monitoring.md) and the [Duplex guide](duplex.md).

Generator architecture support is not service support. Boudoirr's default official Velvarr image requires amd64; remove it or independently verify another image for arm64. Duplex's required Themerr supports amd64/arm64, not arm/v7. Review the [service catalog](../plundarr/services.md) and each selected image before launch.

## Run presets side by side

Each preset has its own Compose project and `dist/<preset>/` directory. Bridge-network defaults run from `172.20.0.0/16` through `172.28.0.0/16`: Watchtower uses `172.26.0.0/16`, Portainer uses `172.27.0.0/16`, and Custom uses `172.28.0.0/16`. Some presets offset host ports; always check the generated values before running projects together.

Change a subnet when it overlaps your local-area network, another Docker network, or a route reached through a virtual private network. Plex uses host networking and is the main exception to the bridge-network pattern.

## Update without losing state

Regeneration preserves known environment assignments and application state, but it does not stop containers omitted from the selection or move external data. Back up databases, private keys, and external settings separately; inspect image pins, mounts, service choices, and Compose orphans before recreating the project. Follow [update and backup checks](../plundarr/upgrading.md).

[Generate the default Plundarr stack](../plundarr/quick-start.md){ .md-button .md-button--primary }
[Read the configuration guide](../plundarr/configuration.md){ .md-button }
