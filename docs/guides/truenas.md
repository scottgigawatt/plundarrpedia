---
title: TrueNAS
description: Run Plundarr on TrueNAS SCALE with Dockge or a TrueNAS custom application.
icon: material/server-network
status: new
---

# TrueNAS

This guide covers deploying Plundarr on **TrueNAS SCALE** through its
Docker-based Apps system, using either Dockge or a custom application. You can
deploy Plundarr as either:

- a **Dockge stack**, which keeps the generated Compose project editable and
  manageable as ordinary files; or
- a **TrueNAS custom application**, which accepts a rendered Compose model in
  the Apps interface.

This guide focuses on Dockge because it is a comfortable fit for people already
using Compose. The custom-application route remains useful when you do not want
another stack manager. Both routes target the Docker Apps model introduced in
TrueNAS 24.10, not the older Kubernetes Apps backend or TrueNAS CORE jails.

!!! note
    The TrueNAS Community catalog currently lists Dockge for TrueNAS 24.10.2.2
    or newer. Screens and container identity behavior continue to evolve, so
    confirm the workflow against the documentation for your installed release.

## 1. Plan datasets before installing

TrueNAS recommends dedicated datasets for application data instead of hiding
important state inside the system-managed `ix-apps` dataset. One starting point
for Dockge and Plundarr is:

```text
/mnt/tank
├── apps
│   ├── dockge
│   │   ├── data
│   │   └── stacks
│   │       └── plundarr
│   │           ├── compose.yaml
│   │           └── .env
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

The Dockge `data` directory holds its application state. The `stacks` directory
holds the actual Compose projects. Plundarr configuration and media stay
separate so they can have different backup, snapshot, and permission policies.

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

- Dockge needs access to its `data` and `stacks` paths.
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

## 3. Install Dockge from the Apps catalog

Open **Apps → Discover Apps**, search for **Dockge**, and install the Community
catalog application. During setup:

1. Map Dockge's application data to `/mnt/tank/apps/dockge/data`.
2. Map its stacks storage to `/mnt/tank/apps/dockge/stacks`.
3. Use an available Web UI port; Dockge uses port `5001` by default.
4. If the form exposes Dockge's `PUID` and `PGID`, set both to the identity that
   should own files created through the editor. Dockge ignores the pair if only
   one value is set.
5. Finish the installation, open the Web UI, and create its administrator
   account.

Dockge requires its stacks directory to use the **same absolute path on both
sides of the mount**. If the TrueNAS form exposes the container mount path or
`DOCKGE_STACKS_DIR`, all three values should agree:

```text
Host path:          /mnt/tank/apps/dockge/stacks
Container path:     /mnt/tank/apps/dockge/stacks
DOCKGE_STACKS_DIR:  /mnt/tank/apps/dockge/stacks
```

Using `/mnt/tank/apps/dockge/stacks` on the host and `/opt/stacks` in the
container looks conventional, but it prevents Dockge from handing the correct
host-side paths to Docker Compose.

!!! danger "Dockge can control Docker"
    The catalog application mounts the host Docker socket and currently runs as
    root. Anyone who controls Dockge can effectively control every Docker
    container on the TrueNAS host. Keep its Web UI on a trusted network, protect
    the account carefully, and do not publish it directly to the internet.

The [TrueNAS Dockge catalog entry](https://apps.truenas.com/catalog/dockge/)
documents the supported TrueNAS version and security context. Dockge's own
[README](https://github.com/louislam/dockge) documents its stack-directory and
import behavior.

## 4. Generate the Plundarr stack

Use a workstation or a shell on TrueNAS to generate and inspect the stack:

```console
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
make ship
$EDITOR .env
docker compose --env-file .env -f docker-compose.yml config --quiet
```

Replace Synology-shaped `/volume1/...` defaults with the actual
`/mnt/tank/...` host paths. Use absolute host paths for persistent Plundarr
configuration and media. Keep the container paths consistent across download
clients and media managers.

!!! tip ".env and env_file are different"
    The `.env` beside `compose.yaml` supplies values for `${VARIABLE}`
    interpolation in the Compose project. An `env_file:` entry sends variables
    into a particular container. One does not replace the other.

## 5. Put the stack where Dockge expects it

Copy the generated deployment into its own lowercase stack directory:

```console
mkdir -p /mnt/tank/apps/dockge/stacks/plundarr
cp docker-compose.yml \
  /mnt/tank/apps/dockge/stacks/plundarr/compose.yaml
cp .env /mnt/tank/apps/dockge/stacks/plundarr/.env
```

Run those commands from a checkout stored on TrueNAS. If you generated the
project on another computer, transfer the two files to the same destination
with SFTP or an SMB share instead.

Keep `.env` beside `compose.yaml`, and protect both as private configuration.
If `COMPOSE_PROJECT_NAME` is set, use a stable value such as `plundarr`.

In Dockge, choose **Scan Stacks Folder**. Open the discovered `plundarr` stack,
review the resolved configuration, and deploy it. Dockge recognizes standard
`compose.yaml` and `docker-compose.yml` files, but one stack per directory is
the least surprising layout.

!!! warning "Do not launch the same stack twice"
    Stop and remove any earlier CLI-managed or TrueNAS Custom App copy before
    deploying it through Dockge. Two copies compete for container names, ports,
    networks, and the same configuration files.

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

Dockge controls the host Docker engine, so **Gluetun** needs `/dev/net/tun` and
`NET_ADMIN`; the Dockge application itself does not. Publish a network-sharing
download client's Web UI and listening ports on Gluetun. That download-client
container does not have a separate network identity.

!!! caution
    Avoid switching the entire stack to host networking just to make one port
    reachable. It removes useful isolation and creates port collisions with
    TrueNAS and other Apps.

## 7. Use the Custom App route instead

Skip this section if Dockge is managing the stack. For a TrueNAS custom
application, render interpolation before pasting the project because the Apps
editor does not automatically discover the `.env` beside your source file:

```console
docker compose --env-file .env -f docker-compose.yml \
  config > truenas-compose.yml
```

Then:

1. Open **Apps → Discover Apps**.
2. Open the menu beside **Custom App**.
3. Choose **Install via YAML**.
4. Use a lowercase application name such as `plundarr`.
5. Paste the reviewed contents of `truenas-compose.yml`.
6. Save and watch the first deployment rather than leaving it unattended.

TrueNAS performs basic YAML validation but does not prove that paths,
permissions, ports, or application settings are correct. Follow the current
[custom application documentation](https://apps.truenas.com/managing-apps/installing-custom-apps/)
for the exact screen.

!!! warning
    Rendered Compose can contain credentials, tokens, and private paths that
    came from `.env`. Never commit it or paste it into a public support thread.

## 8. Validate the smallest path first

Use Dockge's container logs, or the TrueNAS Apps logs for a custom application,
to confirm this order:

1. Privateerr generates `wg0.conf` and `privateerr.env`.
2. Gluetun reads those files and establishes the WireGuard tunnel.
3. The selected download client starts in Gluetun's network namespace.
4. The download client can write to the TrueNAS download dataset.
5. A media manager can see the same completed file at the same container path.

Do not configure every indexer and manager while the VPN lane is still
unhealthy. One working path is easier to diagnose than twenty simultaneous
first-run failures.

## 9. Update without creating configuration drift

Treat the generated Plundarr project as the source of truth:

1. Back up `config/`, `compose.yaml`, and `.env` through a secret-aware process.
2. Run `make ship` in the Plundarr checkout and review the regenerated files.
3. Validate them with `docker compose config --quiet`.
4. Copy the reviewed Compose file and `.env` into the Dockge stack directory.
5. Use Dockge to pull the selected images and recreate the stack.
6. Repeat the VPN-lane validation before updating application settings.

Avoid maintaining different hand-edited copies in the Plundarr checkout and
Dockge. That makes the next regeneration difficult to audit.

## Dockge troubleshooting

| Symptom | First check |
| --- | --- |
| Stack is absent after a scan | Confirm `stacks/plundarr/compose.yaml` exists and the host, container, and `DOCKGE_STACKS_DIR` paths match exactly. |
| Compose variables are empty | Confirm the private file is named `.env`, sits beside `compose.yaml`, and is readable by Dockge. |
| A host path is denied | Check dataset traversal, ACL entries, and the numeric service UID/GID instead of granting world-write access. |
| Gluetun cannot open TUN | Confirm the Gluetun service retains `/dev/net/tun` and `NET_ADMIN`. |
| Download-client Web UI is unreachable | Publish its ports on Gluetun when it uses `network_mode: service:gluetun`. |
| Ports or container names already exist | Stop the older Custom App or CLI-managed copy before deploying the Dockge stack. |

## TrueNAS launch checklist

- [ ] The installed TrueNAS release supports the Docker-based Apps system and
      the current Dockge catalog application.
- [ ] Dockge's data and stacks datasets exist before installation.
- [ ] Dockge's host, container, and configured stacks paths match exactly.
- [ ] Dockge is reachable only from a trusted network.
- [ ] Downloads and libraries that need hardlinks share one ZFS dataset.
- [ ] ACL entries match the services' numeric identities.
- [ ] Every host path begins with the correct `/mnt/POOL/...` path.
- [ ] `.env` is private and sits beside the Dockge `compose.yaml`.
- [ ] `/dev/net/tun` and `NET_ADMIN` remain configured for Gluetun.
- [ ] The custom subnet does not overlap another network.
- [ ] Published ports belong to Gluetun for network-sharing download clients.
- [ ] Only one Dockge, Custom App, or CLI copy of the stack is running.
