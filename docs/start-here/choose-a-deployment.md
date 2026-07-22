---
title: Choose a Deployment
description: Compare Linux Docker, Synology Container Manager, TrueNAS Apps, and the Plundarrpedia image.
icon: material/source-branch
---

# Choose a deployment

The Compose model stays recognizable across platforms. What changes is how the
host prepares paths, grants permissions, supplies the TUN device, and accepts
the generated Compose project.

| Harbor         | Deployment path            | Main adjustment                                          |
| -------------- | -------------------------- | -------------------------------------------------------- |
| Linux server   | Docker Compose CLI         | `/srv` or `/mnt` paths, ownership, and firewall rules    |
| Synology DSM   | Container Manager project  | `/volume*` paths, DSM permissions, and boot helpers      |
| TrueNAS        | Apps custom YAML           | ZFS datasets, ACLs, rendered Compose, and `/dev/net/tun` |
| Docker Desktop | Compose CLI for evaluation | Host-folder sharing and platform networking differences  |

=== "Linux Docker"

    Install Docker Engine with the Compose plugin, prepare durable mounts, and
    use the repository Makefile or normal `docker compose` commands.

    [:material-linux: Linux Docker guide](../guides/docker.md)

=== "Synology"

    Keep `.env`, the complete generated Compose file, and relative `config/`
    paths together in a shared folder, then create a Container Manager project.

    [:material-nas: Synology guide](../guides/synology.md)

=== "TrueNAS"

    Create datasets and ACL entries first. Render environment interpolation,
    then install the resulting Compose YAML as a custom App.

    [:material-server-network: TrueNAS guide](../guides/truenas.md)

## Running this wiki itself

Plundarrpedia is a static site. It needs no database and stores no runtime
state. The production image exposes port `8080`:

```console
docker run --rm -p 8000:8080 \
  --read-only \
  --tmpfs /tmp \
  ghcr.io/scottgigawatt/plundarrpedia:edge
```

For a durable deployment, use this repository's `docker-compose.yml`. It adds a
healthcheck, bounded logs, a read-only filesystem, dropped capabilities, and a
restart policy.
