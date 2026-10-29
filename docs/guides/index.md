---
title: Choose a Harbor
description: Match Plundarr and the media fleet to Linux Docker, Synology, or TrueNAS.
icon: material/ferry
---

# Choose a harbor

Generate Plundarr once, then use the route for your host. Keep the complete `docker-compose.yml`, private `.env`, and configuration tree together.

| Platform | Deployment route | Main differences |
| --- | --- | --- |
| Linux Docker | [Compose CLI](docker.md) | Host paths, numeric ownership, firewall, and devices |
| Synology DSM | [Container Manager](synology.md) | Shared folders, DSM permissions, project import, and TUN |
| TrueNAS | [Dockge or Custom App](truenas.md) | ZFS datasets, ACLs, stack paths, and rendered YAML |
| Docker Desktop | [Compose CLI for evaluation](docker.md) | Folder sharing and host networking differences |

## What stays the same

Prepare durable storage, choose accessible numeric user/group IDs, and avoid overlapping subnets. Gluetun needs `/dev/net/tun` and `NET_ADMIN`; download clients sharing its network publish their Web UI ports on Gluetun. Validate this lane before configuring media managers.

See [paths and permissions](storage-and-permissions.md) and [networking and VPN](networking-and-vpn.md) for the shared requirements.

## Pick the platform guide

Choose [Linux Docker](docker.md), [Synology](synology.md), or [TrueNAS](truenas.md). Platform guides add host-specific steps to the [Plundarr quick start](../projects/plundarr/quick-start.md); they do not require a different generator.
