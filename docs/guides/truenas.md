---
title: TrueNAS Apps
description: Prepare datasets, ACLs, Compose YAML, networking, and Gluetun for Plundarr on current TrueNAS systems.
icon: material/server-network
status: new
---

# TrueNAS Apps

Current TrueNAS releases use a Docker-based Apps system and can install a custom
application from Docker Compose YAML. This guide targets that model, introduced
in TrueNAS 24.10. It does not describe the older Kubernetes-based application
backend or TrueNAS CORE jails.

!!! note
    TrueNAS screens and container identity behavior continue to evolve. Confirm
    the workflow against the documentation for your installed TrueNAS release
    before changing a production system.

## 1. Plan datasets before installing

TrueNAS recommends dedicated datasets for application data instead of hiding
important state inside the system-managed `ix-apps` dataset. One starting point
is:

```text
/mnt/tank
├── apps
│   └── plundarr
│       └── config
└── media
    ├── downloads
    │   ├── torrents
    │   └── usenet
    └── library
        ├── movies
        ├── tv
        └── anime
```

Create the datasets and directories before opening the Custom App screen.
TrueNAS cannot pause the installation wizard while you redesign storage.

!!! important "Keep hardlink candidates in one filesystem"
    ZFS datasets are separate filesystems. If you want Radarr or Sonarr to
    hardlink completed downloads into a library, keep both trees in the same
    dataset and create ordinary directories beneath it. Separate child datasets
    prevent hardlinks across that boundary.

See the TrueNAS guidance for
[setting up storage](https://www.truenas.com/docs/scale/25.10/gettingstarted/configure/setupstoragescale/)
and [application host paths](https://apps.truenas.com/getting-started/app-storage/)
before placing irreplaceable state.

## 2. Grant the container identities access

Plundarr services commonly use numeric `PUID` and `PGID` values. Choose the
TrueNAS user and group that should own media files, record their IDs, and put
those values into the generated `.env`.

Host-path mounts do not gain permission merely because a path appears in
Compose. Add the required access control list (ACL) entries for the identities
that read or write each dataset:

- Download clients need modify access to download directories.
- Radarr and Sonarr need downloads plus their own final libraries.
- Plex or Jellyfin normally need read access to libraries and modify access to
  their configuration and transcode paths.
- Privateerr needs modify access to the shared Gluetun configuration path.

Newer TrueNAS container isolation may map container root to the special
`truenas_container_unpriv_root` host identity. If a container runs as root and
cannot traverse a host path, consult the current
[TrueNAS ACL guidance](https://www.truenas.com/docs/scale/26/datasets/permissions/permissions/)
before adding an entry. Do not solve every ACL problem with recursive world
write access.

## 3. Generate Plundarr away from the Apps editor

Use a workstation or another Docker-capable shell to generate and inspect the
stack:

```console
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
make ship
$EDITOR .env
docker compose --env-file .env -f docker-compose.yml config --quiet
```

Replace Synology-style `/volume1/...` defaults with the actual `/mnt/tank/...`
host paths. Keep container paths consistent across applications.

## 4. Render the YAML TrueNAS will receive

The TrueNAS custom YAML editor receives a Compose model, but it is not the same
thing as a checkout where Docker Compose automatically discovers your local
`.env`. Render interpolation before pasting the project:

```console
docker compose --env-file .env -f docker-compose.yml \
  config > truenas-compose.yml
```

Review `truenas-compose.yml`, then keep it private.

!!! warning
    The rendered file can contain credentials, tokens, and private paths that
    came from `.env`. Never commit it or paste it into a public support thread.

## 5. Install the custom application

On current TrueNAS releases:

1. Open **Apps → Discover Apps**.
2. Open the menu beside **Custom App**.
3. Choose **Install via YAML**.
4. Use a lowercase application name such as `plundarr`.
5. Paste the reviewed contents of `truenas-compose.yml`.
6. Save and watch the first deployment rather than leaving it unattended.

TrueNAS performs basic YAML validation but does not prove that paths,
permissions, ports, or application settings are correct. The
[custom application documentation](https://apps.truenas.com/managing-apps/installing-custom-apps/)
is the source of truth for the current screen.

## 6. Preserve the VPN requirements

Do not remove these pieces from the generated Gluetun service:

```yaml
cap_add:
  - NET_ADMIN
devices:
  - /dev/net/tun:/dev/net/tun
```

Also preserve the shared-network relationship for any download client using:

```yaml
network_mode: service:gluetun
```

In that arrangement, publish the download client's Web UI and listening ports
on Gluetun. The download-client container does not have a separate network
identity.

!!! caution
    Avoid switching the entire stack to host networking just to make one port
    reachable. It removes useful isolation and creates port collisions with
    TrueNAS and other Apps.

## 7. Validate the smallest path first

Use the Apps logs and shell to confirm this order:

1. Privateerr generates `wg0.conf` and `privateerr.env`.
2. Gluetun reads those files and establishes the WireGuard tunnel.
3. The selected download client starts in Gluetun's network namespace.
4. The download client can write to the TrueNAS download dataset.
5. A media manager can see the same completed file at the same container path.

Do not configure every indexer and manager while the VPN lane is still
unhealthy. One working path is easier to diagnose than twenty simultaneous
first-run failures.

## TrueNAS launch checklist

- [ ] The installed release uses the Docker-based Apps system.
- [ ] Application state and media datasets exist before installation.
- [ ] Downloads and libraries that need hardlinks share one ZFS dataset.
- [ ] ACL entries match the services' numeric identities.
- [ ] Every host path begins with the correct `/mnt/POOL/...` path.
- [ ] `/dev/net/tun` and `NET_ADMIN` remain configured for Gluetun.
- [ ] The custom subnet does not overlap another network.
- [ ] Published ports belong to Gluetun for network-sharing download clients.
- [ ] Rendered YAML and generated VPN material are kept private.
