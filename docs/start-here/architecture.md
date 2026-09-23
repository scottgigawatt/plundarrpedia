---
title: How the Fleet Fits Together
description: Understand control, download, VPN, storage, and playback lanes before deploying.
icon: material/transit-connection-variant
---

# How the fleet fits together

The easiest way to understand a media stack is to separate it into lanes. A
container may speak to several lanes, but each lane has one job.

| Lane       | Typical services                                                                 | Responsibility                                                                 |
| ---------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Requests   | Seerr                                                                            | Turns human requests into manager activity.                                    |
| Discovery  | Prowlarr, FlareSolverr                                                           | Supplies indexers and supported challenge handling.                            |
| Management | Radarr, Sonarr, Whisparr, Bazarr, Lidarr, Recyclarr                              | Chooses releases and manages final library files.                              |
| Download   | qBittorrent, SABnzbd, NZBGet                                                     | Retrieves payloads into a shared download root.                                |
| VPN        | Privateerr, Gluetun                                                              | Generates VPN configuration, runs the tunnel, and handles PIA port forwarding. |
| Playback   | Plex, Jellyfin                                                                   | Scans and serves completed media libraries.                                    |
| Books      | Calibre-Web Automated                                                            | Ingests, manages, and serves an ebook library.                                 |
| Operations | Homepage, Tracearr, Portainer, Duplicati, Cleanuparr, Speedtest Tracker, Apprise | Observability, backup, cleanup, and notification work.                         |
| Updates    | Watchtower                                                                       | Replaces eligible container images under an explicit host policy.              |
| Curation   | Kometa, ImageMaid, PATTRMM, Tautulli, Notifiarr                                  | Improves and monitors an existing Plex deployment.                             |

## The VPN boundary

<div class="flow-map" role="group" aria-label="VPN configuration handoff">
  <span class="flow-map__step">🏴‍☠️ Privateerr</span>
  <span class="flow-map__arrow">writes →</span>
  <span class="flow-map__step">📜 Shared VPN configuration</span>
  <span class="flow-map__arrow">read at startup →</span>
  <span class="flow-map__step">🛡️ Gluetun</span>
</div>

<div class="flow-map flow-map--support" role="group" aria-label="Download traffic path">
  <span class="flow-map__step">📥 Download clients</span>
  <span class="flow-map__arrow">shared network →</span>
  <span class="flow-map__step">🔐 Gluetun's WireGuard tunnel</span>
  <span class="flow-map__arrow">encrypted traffic →</span>
  <span class="flow-map__step">🌐 PIA endpoint</span>
</div>

Privateerr also uses Gluetun's internal authenticated API to replace stale connection settings. Radarr, Sonarr, and Prowlarr reach download-client Web UIs through Gluetun on the project network.

Only selected download clients need to share Gluetun's network namespace.
Managers, indexers, dashboards, and playback servers normally stay on the
project network and reach the download clients through the ports exposed by
Gluetun.

> [!WARNING]
> `network_mode: service:gluetun` means the download client does not own a separate network identity. Publish its Web UI on Gluetun, not on the download-client service. PIA-forwarded peer ports arrive through the VPN tunnel and do not need host publication.

## The storage boundary

Use consistent container paths across apps. If qBittorrent reports a completed
file as `/downloads/movies/example.mkv`, Radarr should see that same file at
`/downloads/movies/example.mkv`. Mapping the same host directory to different
container paths creates remote-path and hardlink problems.

```text
Host
├── downloads
│   ├── complete
│   └── incomplete
├── media
│   ├── movies
│   ├── tv
│   └── anime
└── docker
    └── plundarr
        └── config
```

## Responsibility map

- **Maraudarr** generates Plundarr; it is not a long-running media service.
- **Presets** select a maintained deployment shape; they are not separate generator implementations.
- **Privateerr** generates PIA files and supervises stale-connection recovery through Gluetun's API; it does not carry traffic.
- **Gluetun** carries VPN traffic and coordinates port forwarding.
- **Download clients** retrieve files; they should not organize the library.
- **Radarr/Sonarr** import and organize; they should not be the download engine.
- **Plex/Jellyfin** serve completed libraries; they should not watch incomplete
  download directories.
