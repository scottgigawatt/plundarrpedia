---
title: Plundarr Service Catalog
description: Understand what each selectable Plundarr service contributes.
icon: material/view-grid-plus
---

# Service catalog

Maraudarr resolves required companions, but it does not decide which optional
capabilities are valuable to you.

## VPN and discovery

| Service      | Role                                                 | Add it when                                     |
| ------------ | ---------------------------------------------------- | ----------------------------------------------- |
| Privateerr   | Generates PIA WireGuard configuration and metadata.  | You use PIA WireGuard with Gluetun.             |
| Gluetun      | Runs the VPN tunnel and port-forwarding integration. | Selected download clients need a VPN namespace. |
| Prowlarr     | Centralizes indexer configuration.                   | Radarr/Sonarr/Whisparr should share indexers.   |
| FlareSolverr | Handles supported anti-bot challenges for Prowlarr.  | A configured indexer explicitly needs it.       |

## Downloads and management

| Service      | Role                                      | Add it when                                                       |
| ------------ | ----------------------------------------- | ----------------------------------------------------------------- |
| qBittorrent  | Torrent download client.                  | You use torrent sources.                                          |
| SABnzbd      | Usenet download client.                   | You use Usenet sources.                                           |
| NZBGet       | Lean Usenet download client.              | You prefer NZBGet or need a separate Usenet queue.                |
| Radarr       | Movie acquisition and organization.       | You manage a movie library.                                       |
| Sonarr       | Television acquisition and organization.  | You manage episodic TV.                                           |
| Sonarr Anime | Separate Sonarr instance for anime rules. | Anime needs distinct naming, profiles, or indexers.               |
| Whisparr     | Adult media management.                   | You are using the Boudoirr-style lane.                            |
| Bazarr       | Subtitle acquisition.                     | Movies or shows need automated subtitles.                         |
| Seerr        | Request portal.                           | Other people should request media without entering Radarr/Sonarr. |

## Playback and operations

| Service           | Role                                            | Add it when                                                |
| ----------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| Plex              | Media playback server.                          | Plex is not already deployed elsewhere.                    |
| Jellyfin          | Open-source media playback server.              | You want Jellyfin in the same stack.                       |
| Cleanuparr        | Removes blocked or unwanted downloads.          | Stalled and rejected downloads need policy-driven cleanup. |
| Speedtest Tracker | Records connection performance.                 | Network trends matter to troubleshooting.                  |
| Apprise           | Notification gateway without another public UI. | Several apps need one notification path.                   |
| Duplicati         | Backs up application state.                     | You need scheduled, encrypted config backups.              |
| Homepage          | Dashboard for the fleet.                        | You want one launchpad and health view.                    |
| Watchtower        | Checks or updates selected containers.          | You accept the tradeoffs of unattended image updates.      |

!!! caution
    VPN and download components should be updated intentionally. A release can
    change healthchecks, namespaces, or port-forwarding behavior. The project
    disables Watchtower for tightly coordinated containers by default.

SABnzbd and NZBGet are separate opt-in Usenet lanes. Maraudarr can select
either one or both, routes each through Gluetun, and keeps the default
Plundarr preset unchanged.

## Related projects

Calibre Web Automated replaces the retired Readarr lane for ebook management.
Duplex focuses on Plex curation and monitoring after the core media server is
already running.
