---
title: Docker hosts
description: Run the generated project on Linux or Docker Desktop.
icon: fontawesome/brands/docker
---

# Deploy with Docker Compose

Use this route for Linux or Docker Desktop. You need Docker with Compose v2 and images supported by your host:

```sh
docker version
docker compose version
```

## Prepare host folders

Choose durable download, media, and config directories. Grant the numeric host user/group in your `.env` the required access. Replace `/volume1/...` examples with real absolute paths on this host. Docker Desktop must be allowed to share those folders with containers.

The generated default mounts support imports through copies; downloads and final libraries are separate container mounts. Hardlinks need a different, deliberately designed shared-mount layout. See [paths and permissions](storage-and-permissions.md).

## Generate and start

Follow the [Plundarr quick start](../projects/plundarr/quick-start.md). If you generated elsewhere, transfer the whole project directory and run from the directory containing `docker-compose.yml` and `.env`:

```sh
docker compose config --quiet
docker compose up --detach --pull always
docker compose ps
```

Start only one copy. Check Privateerr and Gluetun locally before continuing to qBittorrent:

```sh
docker compose logs --tail 100 privateerr gluetun qbittorrent
```

Confirm the healthy tunnel and sign in to the downloader. Then [connect the applications](../projects/plundarr/connect-applications.md). [Troubleshooting](../projects/plundarr/troubleshooting.md) follows the same layers.

## Host requirements

Gluetun needs `/dev/net/tun` and its declared network capability. The firewall must allow the intended Web UI ports from trusted clients. Hardware transcoding needs host-specific device/group configuration; it is not automatically portable between Linux and Docker Desktop.

Back up application state, the private `.env`, and external settings separately from media and caches. Follow [updates and backups](../projects/plundarr/upgrading.md).
