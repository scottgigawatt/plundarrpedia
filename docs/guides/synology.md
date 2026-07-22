---
title: Synology Container Manager
description: Deploy Plundarr on DSM with deliberate paths, permissions, networking, and VPN validation.
icon: material/nas
---

# Synology Container Manager

Synology is one supported harbor for Plundarr, not a requirement baked into the
applications. DSM-specific work is concentrated in shared-folder paths,
permissions, firewall rules, and the TUN device used by Gluetun.

## 1. Generate the deployment artifact

Generate Plundarr on the NAS over SSH or on another Docker-capable system:

```console
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
make ship
```

Keep the generated `docker-compose.yml`, `.env`, and `config/` tree together.
Copy that complete directory to a durable location such as:

```text
/volume1/docker/plundarr
```

!!! important
    Edit the generated `.env`, not `example.env`. Confirm every `/volume1` or
    `/volume2` path actually exists on this NAS before Container Manager creates
    the project.

## 2. Design the media paths

A practical layout keeps completed downloads and final libraries under one
shared-folder tree:

```text
/volume1/media
├── downloads
│   ├── torrents
│   └── usenet
└── library
    ├── movies
    ├── tv
    └── anime
```

Use consistent container paths across downloaders and media managers. If
qBittorrent reports `/data/downloads/torrents/movie.mkv`, Radarr should see that
same file at the same container path.

## 3. Match permissions

Record the numeric user and group that should own media files:

```console
id media-user
```

Set the matching `PUID` and `PGID` values in `.env`, then grant that DSM account
read/write access to downloads, the applicable library folders, and service
configuration directories.

!!! warning
    Giving every container full control of every shared folder makes a
    permissions error disappear by creating a much larger security problem.
    Grant each service only the paths it needs.

## 4. Confirm the VPN device

Gluetun needs `/dev/net/tun` plus the `NET_ADMIN` capability declared in the
generated Compose file.

```console
ls -l /dev/net/tun
```

If the device is absent after a reboot, review Plundarr's
`scripts/synology/tun.sh` helper before adding it as a boot-triggered task under
**Control Panel → Task Scheduler**. Run host-level scripts with the smallest
privilege that works and keep a record of the change.

## 5. Create the Container Manager project

1. Open **Container Manager → Project**.
2. Select **Create** and choose the generated project directory.
3. Use a stable project name such as `plundarr`.
4. Confirm Container Manager found `docker-compose.yml` and `.env` together.
5. Review host paths, published ports, and the custom network before building.

Do not paste only the Compose file into an unrelated directory. Relative
`./config/...` mounts resolve from the project directory and must travel with
the deployment.

## 6. Check networking and the DSM firewall

- Make sure the Plundarr subnet does not overlap the LAN, another Compose
  project, or a remote VPN route.
- Permit only the Web UI host ports you intend to use from trusted LAN sources.
- Publish qBittorrent or SABnzbd ports on Gluetun when those services use
  `network_mode: service:gluetun`.
- Prefer a private access layer or authenticated HTTPS reverse proxy over
  exposing application UIs directly to the internet.
- Enable WebSocket and HTTP/1.1 proxy support for applications that require
  persistent connections.

## 7. Validate in layers

Start the project, then validate the VPN lane before configuring the rest of the
fleet:

```console
docker compose config
docker compose ps
docker compose logs --tail=100 privateerr gluetun
make test-vpn
```

Only after the tunnel and download-client path are healthy should you configure
Prowlarr, Radarr, Sonarr, request services, and playback applications.

!!! tip
    Back up `config/` and the private `.env` through a secret-aware process.
    Transcode directories, caches, and ordinary container logs usually do not
    belong in the same backup tier as application databases.
