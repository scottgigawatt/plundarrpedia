---
title: Boudoirr
description: Generate a Whisparr-focused Plundarr deployment with deliberate downloader and playback choices.
icon: material/heart
status: updated
---

# Boudoirr preset 💋

Boudoirr is the Whisparr-focused Plundarr preset. Maraudarr generates it under `dist/boudoirr/` with Privateerr, Gluetun, FlareSolverr, Prowlarr, and Whisparr as its required core. qBittorrent, Cleanuparr, and Watchtower are removable defaults; Usenet clients and media servers remain explicit choices.

## Generate the preset

```sh
make ship PRESET=boudoirr
```

Review `dist/boudoirr/.env`, then validate and start the generated project:

```sh
make config PRESET=boudoirr
make up PRESET=boudoirr
```

The preset is VPN-enabled. Set real PIA credentials, confirm the generated host paths, and validate the Privateerr-to-Gluetun handoff before configuring Whisparr.

## Choose downloaders

Keep the default torrent lane when qBittorrent matches your sources. Add SABnzbd or NZBGet when you also use Usenet:

```sh
make ship PRESET=boudoirr ADD_SERVICES=sabnzbd
make ship PRESET=boudoirr ADD_SERVICES=nzbget
```

For a Usenet-only deployment, remove the default torrent client and its cleanup companion:

```sh
make ship PRESET=boudoirr REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=sabnzbd
```

Regeneration preserves known environment values and application state, but always inspect the generated diff before restarting an existing deployment.

## Add playback deliberately

Boudoirr does not select a media server by default. Add Jellyfin or Plex only when you want the generated project to own playback:

```sh
make ship PRESET=boudoirr ADD_SERVICES=jellyfin
make ship PRESET=boudoirr ADD_SERVICES=plex
```

Jellyfin shares the Boudoirr high-level data root at `/data`; configure its libraries beneath that root. Plex uses host networking and separate read-only movie and scene mounts, so confirm its paths and standard host ports before launch.

## Migrate an existing Boudoirr deployment

Treat the generated preset as a new Compose project rather than replacing an older chart in place:

1. Stop the old stack and back up its environment and application configuration.
2. Generate `dist/boudoirr/` with the services you intend to keep.
3. Map the old values to the generated `.env`; do not copy an old Compose file over the generated chart.
4. Move persistent application state only while the related containers are stopped.
5. Run `make config PRESET=boudoirr`, inspect mounts and ports, then start the new project.

[Open the shared configuration guide](../plundarr/configuration.md){ .md-button }
[Troubleshoot the generated stack](../plundarr/troubleshooting.md){ .md-button .md-button--primary }
