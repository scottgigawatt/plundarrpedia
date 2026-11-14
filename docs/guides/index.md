---
title: Choose your platform
description: Deploy one generated project with Docker Compose, Synology Container Manager, or TrueNAS.
icon: material/server-network
---

# Choose your platform

Generate your project with [Maraudarr](../projects/plundarr/quick-start.md), then deploy it once on the host that will run the applications. Keep `docker-compose.yml`, private `.env`, and `config/` together.

| Host | Deployment guide | Main preparation |
| --- | --- | --- |
| Linux or Docker Desktop | [Docker Compose](docker.md) | Folder access, numeric ownership, firewall, and supported devices |
| Synology DSM 7.4 | [Container Manager](synology.md) | Shared folders, DSM permissions, TUN device, project directory |
| TrueNAS with Docker-based Apps | [Dockge or Custom App](truenas.md) | ZFS datasets, ACLs, and stack directory |

Docker Desktop needs permission to share your host folders. Selected service images and hardware features must support your host; the generator's architecture support alone is insufficient.

For any platform, review [storage and permissions](storage-and-permissions.md) and avoid overlapping networks. Gluetun needs `/dev/net/tun` and `NET_ADMIN`; Privateerr does not need those tunnel privileges. The [network guide](networking-and-vpn.md) explains the shared downloader ports.
