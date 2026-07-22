---
title: Any Docker Host
description: Deploy the media projects on Linux or Docker Desktop without Synology assumptions.
icon: fontawesome/brands/docker
---

# Any Docker host

Plundarr and its siblings are Docker Compose projects. Synology is a supported
harbor, not a runtime dependency.

## Prerequisites

```console
docker version
docker compose version
```

Use Docker Compose v2 (`docker compose`). If your system only provides the old
`docker-compose` binary, upgrade or translate commands deliberately rather than
assuming every modern Compose feature is supported.

## Prepare durable paths

One Linux example:

```console
sudo install -d -m 775 \
  /srv/media/downloads \
  /srv/media/movies \
  /srv/media/tv \
  /srv/containers/plundarr
sudo chown -R media:media /srv/media /srv/containers/plundarr
```

Choose ownership for your host. The name `media` is only an example. Record the
numeric IDs with `id media` and use them consistently in `.env`.

## Generate and validate

```console
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
make ship
$EDITOR .env
make config
```

Replace all `/volume1/...` examples with your `/srv`, `/mnt`, or other absolute
host paths. Relative `./config/...` paths are resolved from the Compose project
directory and can remain portable.

## Host requirements

- Gluetun needs the network capabilities declared by the generated Compose
  stack.
- The host firewall must permit the Web UI ports you intend to reach.
- Hardware transcoding requires platform-specific device mounts and group
  permissions; it is not automatically portable across Intel, AMD, NVIDIA, and
  NAS hardware.
- Docker Desktop must be allowed to share any host directory mounted into a
  Linux container.

## Operate in layers

```console
make up
docker compose ps
docker compose logs --tail=100 privateerr gluetun
make test-vpn
```

Configure the download client next, then Prowlarr, then Radarr/Sonarr, then the
request and playback layers. This ordering keeps a networking problem from
masquerading as five application problems.

## Backups

Back up `config/`, `.env` through an encrypted secret-aware method, and any
custom Compose inputs. Media files are replaceable only in theory; application
databases, watched state, collections, and carefully tuned quality profiles are
often harder to reconstruct.
