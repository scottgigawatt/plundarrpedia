---
title: How the Fleet Fits Together
description: Understand control, download, VPN, storage, and playback lanes before deploying.
icon: material/transit-connection-variant
---

# How the fleet fits together

The easiest way to understand a media stack is to separate it into lanes. A
container may speak to several lanes, but each lane has one job.

| Lane | Typical services | Responsibility |
| --- | --- | --- |
| Requests | Seerr | Turns human requests into manager activity. |
| Discovery | Prowlarr, FlareSolverr | Supplies indexers and supported challenge handling. |
| Management | Radarr, Sonarr, Whisparr, Bazarr | Chooses releases and manages final library files. |
| Download | qBittorrent, SABnzbd | Retrieves payloads into a shared download root. |
| VPN | Privateerr, Gluetun | Generates VPN configuration, runs the tunnel, and handles PIA port forwarding. |
| Playback | Plex, Jellyfin | Scans and serves completed media libraries. |
| Operations | Homepage, Duplicati, Cleanuparr, Speedtest Tracker, Apprise | Observability, backup, cleanup, and notification work. |
| Curation | Kometa, ImageMaid, PATTRMM, Tautulli, Notifiarr | Improves and monitors an existing Plex deployment. |

## The VPN boundary

<div class="flow-map" role="img" aria-label="Privateerr writes configuration into shared storage, Gluetun consumes it, and Gluetun connects to the PIA endpoint.">
  <span class="flow-map__step">Privateerr</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">Shared config</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">Gluetun</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">PIA endpoint</span>
</div>

<div class="flow-map flow-map--support" role="img" aria-label="Media managers reach qBittorrent or SABnzbd over the project network, and the download client shares Gluetun's network namespace.">
  <span class="flow-map__step">Radarr / Sonarr / Prowlarr</span>
  <span class="flow-map__arrow" aria-hidden="true">→ project network →</span>
  <span class="flow-map__step">qBittorrent / SABnzbd</span>
  <span class="flow-map__arrow" aria-hidden="true">→ shared namespace →</span>
  <span class="flow-map__step">Gluetun</span>
</div>

Only selected download clients need to share Gluetun's network namespace.
Managers, indexers, dashboards, and playback servers normally stay on the
project network and reach the download clients through the ports exposed by
Gluetun.

!!! warning
    `network_mode: service:gluetun` means the download client does not own a
    separate network identity. Publish its Web UI and inbound ports on Gluetun,
    not on the download-client service.

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
- **Privateerr** generates PIA files; it does not carry traffic.
- **Gluetun** carries VPN traffic and coordinates port forwarding.
- **Download clients** retrieve files; they should not organize the library.
- **Radarr/Sonarr** import and organize; they should not be the download engine.
- **Plex/Jellyfin** serve completed libraries; they should not watch incomplete
  download directories.
