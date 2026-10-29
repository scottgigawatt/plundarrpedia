---
title: Plundarr Service Catalog
description: Understand the current selectable Plundarr services, dependencies, and preset boundaries.
icon: material/view-grid-plus
status: updated
---

# Service catalog

Choose services for the tasks you need. `make services` and `make presets` report the catalog packaged in your selected Maraudarr image, including required companions and removable defaults. Use the [preset comparison](../presets/index.md) for deployment shapes.

## VPN and discovery

| Services | Purpose |
| --- | --- |
| Privateerr and Gluetun | Generate PIA settings and run the VPN tunnel respectively |
| Prowlarr | Share indexers across media managers |
| FlareSolverr | Handle supported challenges when a configured indexer requires it |

## Downloads and automation

| Services | Purpose |
| --- | --- |
| qBittorrent | Torrent downloads; the default downloader in Plundarr and Boudoirr |
| SABnzbd or NZBGet | Optional Usenet lanes; either or both may be selected |
| Radarr, Sonarr, Sonarr Anime, Lidarr | Movie, television, separate anime, or music management |
| Whisparr and Whisparr Alt | Independent adult-media instances with separate providers, state, and categories |
| Bazarr | Subtitles |
| Seerr or Velvarr | Media requests; Velvarr uses Jellyfin authentication |
| Cleanuparr | Policy-driven rejected/stalled download cleanup |
| Recyclarr | Explicit preview/apply of Radarr/Sonarr quality settings |

Lidarr supports amd64/arm64, not arm/v7. The default official Velvarr image requires amd64 and has provider-specific limits; complete [Boudoirr owner/provider setup](../presets/boudoirr.md) before use. See [NZBGet settings](configuration.md#nzbget-first-run-settings) and [Recyclarr commands](configuration.md#music-and-quality-synchronization) for application setup.

## Playback and ebooks

| Services | Purpose |
| --- | --- |
| Plex | Host-networked media server with read-only library mounts |
| Jellyfin | Media server with a writable `/data` root |
| Jellyfin Vue | Optional experimental browser client; requires a browser-reachable Jellyfin server |
| Calibre-Web Automated | Ebook library and automatic ingest |

Jellyfin and Velvarr/Vue can connect across projects; selecting a client does not force a local Jellyfin server. Vue and Calibre-Web Automated require amd64/arm64. Calibre's ingest directory removes processed files, and its image is excluded from Watchtower because updates can migrate databases. Follow [media-server and ebook setup](../presets/media-servers-and-books.md).

## Media curation utilities

| Services | Purpose |
| --- | --- |
| Kometa, ImageMaid, Themerr | Duplex core: collections/overlays, artwork maintenance, and Plex/Jellyfin theme songs |
| PATTRMM Neo and Notifiarr | Duplex removable defaults: generated collections and notifications |
| Tautulli | Optional Plex activity/history |
| Overlay Reset | Optional `tools`-profile repair, invoked explicitly |

Kometa uses external operator-owned configuration. Themerr requires amd64/arm64 and a separate token key paired with its state. Prepare Neo settings/output and verify every selected settings run. Overlay Reset has no undo; review its dry run and backups first. The [Duplex guide](../presets/duplex.md) covers those requirements.

## Operations

| Services | Purpose |
| --- | --- |
| Tracearr | Media monitoring with TimescaleDB/Redis companions; amd64/arm64 |
| Homepage | Dashboard with generated shared-password login |
| Duplicati | Encrypted configuration/host-data backups |
| Portainer | Docker management through the host socket |
| Speedtest Tracker and Apprise | Network history and notifications |
| Watchtower | Deliberate automatic or one-shot image updates |

Read [Tracearr setup and database exports](monitoring.md), [Homepage login](homepage.md), and [Portainer access](../presets/portainer.md) before launch.

> [!CAUTION]
> Image updates can introduce incompatible configuration or database migrations. Run only one persistent Watchtower daemon per host and keep coordinated services excluded until their upgrade path is tested.

## Inspect dependency resolution

After [choosing the generator](quick-start.md#choose-the-generator), replace the placeholders with catalog IDs:

```sh
make ship PRESET=YOUR-PRESET ADD_SERVICES=SERVICE-ID
make compose-services PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Keep your complete existing service selection on regeneration. Generator architecture support does not guarantee support for every selected application.
