---
title: Plundarr Service Catalog
description: Understand the current selectable Plundarr services, dependencies, and preset boundaries.
icon: material/view-grid-plus
status: updated
---

# Service catalog

Maraudarr distinguishes preset core services, removable defaults, optional services, and required companions. Use `make services` for the live catalog and `make presets` for the exact current preset selections.

## VPN and discovery

| Service | Role | Select it when |
| --- | --- | --- |
| Privateerr | Generates PIA WireGuard configuration and endpoint metadata. | A PIA-backed Gluetun lane needs repeatable configuration. |
| Gluetun | Establishes the VPN tunnel and coordinates port forwarding. | Selected download clients need a protected network namespace. |
| Prowlarr | Centralizes indexer configuration. | Radarr, Sonarr, or Whisparr should share indexers. |
| FlareSolverr | Handles supported anti-bot challenges for Prowlarr. | A configured indexer explicitly needs it. |

Privateerr and Gluetun are separate responsibilities: Privateerr writes the files, and Gluetun carries traffic.

## Downloads and automation

| Service | Role | Select it when |
| --- | --- | --- |
| qBittorrent | Torrent download client. | You use torrent sources and the VPN lane. |
| SABnzbd | Usenet download client. | You use Usenet sources. |
| NZBGet | Lean Usenet download client. | You prefer NZBGet or want a separate Usenet queue. |
| Radarr | Movie acquisition and organization. | You manage a movie library. |
| Sonarr | Television acquisition and organization. | You manage episodic television. |
| Sonarr Anime | A second Sonarr with independent rules. | Anime needs distinct naming, profiles, or indexers. |
| Whisparr | Adult media acquisition and organization. | You use the Boudoirr preset or add its service deliberately. |
| Bazarr | Subtitle acquisition. | Movies or shows need automated subtitles. |
| Seerr | Request portal. | Other people should request media without entering a manager. |
| Cleanuparr | Rejected-download cleanup. | Stalled or blocked downloads need policy-driven removal. |

qBittorrent is the only default downloader in Plundarr and Boudoirr. SABnzbd and NZBGet are independent opt-in lanes, and you may select either or both.

## Playback and ebooks

| Service | Role | Select it when |
| --- | --- | --- |
| Plex | Plex Media Server with host networking and read-only library mounts. | The generated deployment should own Plex. |
| Jellyfin | Open media server with one writable `/data` root. | The generated deployment should own Jellyfin. |
| Calibre-Web Automated | Ebook library, reader, and automatic ingest service. | You need ebooks in Plundarr or as a focused preset. |

Calibre-Web Automated is a removable default in Plundarr and the core of its focused preset. Its ingest directory is destructive, and its image updates remain excluded from Watchtower so database migrations stay operator-controlled.

## Plex utilities

| Service | Role | Select it when |
| --- | --- | --- |
| Kometa | Collections, metadata, and overlays from external configuration. | You want the core of the Duplex preset. |
| ImageMaid | Plex artwork reporting and cleanup. | You can grant carefully scoped access to Plex application data. |
| PATTRMM | Returning-soon metadata and overlays for Kometa. | You want the removable Duplex helper. |
| Tautulli | Plex activity, history, and analytics. | You want the Duplex monitoring core. |
| Notifiarr | Host and application notifications. | You want the removable Duplex notification route. |
| Overlay Reset | One-shot Kometa overlay repair. | You explicitly invoke the dry-run-first `tools` profile. |

Kometa, ImageMaid, and Tautulli are Duplex core services. PATTRMM, Notifiarr, and Overlay Reset are removable defaults. Watchtower remains optional.

## Operations

| Service | Role | Select it when |
| --- | --- | --- |
| Homepage | Dashboard for the generated fleet. | You want one launchpad and health view. |
| Duplicati | Configuration and host-data backups. | You need scheduled encrypted backups. |
| Speedtest Tracker | Connection-performance history. | Network trends matter to troubleshooting. |
| Apprise | Notification gateway. | Several services need one notification endpoint. |
| Watchtower | Persistent or one-shot updates for eligible containers. | You accept the risks of automated image replacement. |

> [!CAUTION]
> Automatic updates can introduce migrations, changed healthchecks, or incompatible configuration. Run only one persistent Watchtower daemon per host and keep tightly coordinated containers excluded until their upgrade path is tested.

## Inspect dependency resolution

Generate into the normal preset directory, then inspect the selected Compose services:

```sh
make ship PRESET=YOUR-PRESET ADD_SERVICES=SERVICE-ID
make compose-services PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Replace the placeholders with IDs from `make presets` and `make services`. Maraudarr displays the resolved fleet before it writes the project.

[Compare presets](../presets/index.md){ .md-button .md-button--primary }
