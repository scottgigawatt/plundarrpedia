---
title: Synology
description: Deploy Plundarr on DSM with deliberate paths, permissions, networking, and VPN validation.
icon: material/nas
---

# Synology

This guide covers deploying Plundarr on a Synology NAS through DSM's **Container
Manager**. Synology is one supported harbor, not a requirement baked into the
applications. DSM-specific work is concentrated in shared-folder paths,
permissions, firewall rules, Container Manager projects, and the TUN device
used by Gluetun.

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

Set the matching `DEFAULT_PUID` and `DEFAULT_PGID` values in `.env`. Set
`DEFAULT_GROUP` to the supplemental DSM group used for shared paths, then grant
that identity read/write access to downloads, the applicable library folders,
and service configuration directories.

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

## 5. Restore trusted Docker CLI access after boot

Container Manager can recreate `/var/run/docker.sock` with root-only group
ownership after a DSM reboot or package update. This affects trusted users who
run Docker commands over SSH; it does not require making the socket writable by
every local account.

If the socket loses the intended group access:

1. Create a `docker` group under **Control Panel → User & Group → Group**.
2. Add only the trusted DSM users who need Docker CLI access.
3. Review Plundarr's
   [`docker-socket.sh`](https://github.com/scottgigawatt/plundarr/blob/main/scripts/synology/docker-socket.sh)
   helper.
4. Create a boot-up task in **Control Panel → Task Scheduler**, select `root`
   as the task user, and run:

```console
sh /volume1/docker/plundarr/scripts/synology/docker-socket.sh
```

The helper waits up to 120 seconds for the socket, verifies the Synology
`docker` group, then restores ownership to `root:docker` with mode `0660`.

!!! danger
    Docker-group membership grants root-equivalent control of the NAS through
    the Docker daemon. Add only trusted administrators; do not replace the
    helper's `0660` mode with world-writable permissions.

## 6. Create the Container Manager project

1. Open **Container Manager → Project**.
2. Select **Create** and choose the generated project directory.
3. Use a stable project name such as `plundarr`.
4. Confirm Container Manager found `docker-compose.yml` and `.env` together.
5. Review host paths, published ports, and the custom network before building.

Do not paste only the Compose file into an unrelated directory. Relative
`./config/...` mounts resolve from the project directory and must travel with
the deployment.

## 7. Check networking and the DSM firewall

- Make sure the Plundarr subnet does not overlap the LAN, another Compose
  project, or a remote VPN route.
- Permit only the Web UI host ports you intend to use from trusted LAN sources.
- Publish qBittorrent, SABnzbd, or NZBGet ports on Gluetun when those services
  use `network_mode: service:gluetun`.
- Prefer a private access layer or authenticated HTTPS reverse proxy over
  exposing application UIs directly to the internet.
- Enable WebSocket and HTTP/1.1 proxy support for applications that require
  persistent connections.

## 8. Validate in layers

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
