---
title: TrueNAS
description: Deploy a generated project through Dockge or a Docker-based TrueNAS Custom App.
icon: material/server-network
---

# Deploy on TrueNAS

Use TrueNAS's Docker-based Apps system with **Dockge** for a file-based Compose project, or **Custom App** for pasted YAML. Check the [Dockge catalog entry](https://apps.truenas.com/catalog/dockge/) for your installed TrueNAS release before starting. Use only one manager for this stack.

## 1. Prepare datasets and permissions

Create durable application storage outside the system-managed `ix-apps` dataset. One example is:

```text
/mnt/tank/apps/dockge/data
/mnt/tank/apps/dockge/stacks/plundarr
/mnt/tank/media/downloads/torrents
/mnt/tank/media/library/movies
/mnt/tank/media/library/tv
```

Set service user/group IDs to host identities with the required dataset ACL access. Dockge needs its data and stack directories; downloaders need downloads; managers need downloads and their libraries; Privateerr needs the shared Gluetun configuration directory. Jellyfin's generated `/data` root is writable; Plex libraries are read-only.

Container root may map to `truenas_container_unpriv_root`. If access fails, check current [TrueNAS ACL guidance](https://www.truenas.com/docs/scale/26/datasets/permissions/permissions/). Do not grant world-write access as a general fix.

Default generated imports use copies because downloads and libraries are separate bind mounts. A custom hardlink layout also needs one shared container mount and one host filesystem; ZFS child datasets are separate filesystems. See [storage and permissions](storage-and-permissions.md) before changing that layout.

## 2. Install Dockge

Open **Apps → Discover Apps**, install Dockge, and configure:

1. Data storage at `/mnt/tank/apps/dockge/data`.
2. Stack storage at `/mnt/tank/apps/dockge/stacks`.
3. An available Web UI port, normally `5001`.
4. Both `PUID` and `PGID` if those options are exposed; Dockge ignores the pair if only one is set.
5. An administrator account in the Web UI.

The stack directory must use the **same absolute path** on the host, inside Dockge, and in `DOCKGE_STACKS_DIR`:

```text
Host:              /mnt/tank/apps/dockge/stacks
Container:         /mnt/tank/apps/dockge/stacks
DOCKGE_STACKS_DIR:  /mnt/tank/apps/dockge/stacks
```

See [Dockge's stack requirements](https://github.com/louislam/dockge) before changing paths.

> [!CAUTION]
> Dockge controls the host Docker engine through its socket. Anyone controlling Dockge can control the host's containers. Restrict its UI to trusted administrators and do not expose it directly to the internet.

## 3. Generate and place the project

Complete [Plundarr quick start steps 1–2](../projects/plundarr/quick-start.md#1-open-the-interactive-generator), then validate without starting. Replace `/volume1/...` examples with actual `/mnt/tank/...` paths on TrueNAS. Keep the generated seed files with any config path they populate; external Kometa settings need their own storage.

Transfer the complete generated directory to `/mnt/tank/apps/dockge/stacks/plundarr`. If generation ran on TrueNAS, from the parent directory containing `dist/`, copy a new project:

```sh
mkdir -p /mnt/tank/apps/dockge/stacks/plundarr
cp dist/plundarr/docker-compose.yml /mnt/tank/apps/dockge/stacks/plundarr/compose.yaml
cp dist/plundarr/.env /mnt/tank/apps/dockge/stacks/plundarr/.env
cp -a dist/plundarr/config /mnt/tank/apps/dockge/stacks/plundarr/
```

These commands are for a new destination; do not overwrite existing state. When generating elsewhere, transfer files with SFTP or SMB instead. Keep `.env` private beside the Compose file. Relative `./config` paths resolve from this deployment directory.

In Dockge, choose **Scan Stacks Folder**, open `plundarr`, review the settings, and deploy. Both `compose.yaml` and `docker-compose.yml` are supported. Do not start a second workstation, CLI, or Custom App copy against the same state.

## 4. Preserve VPN requirements

Keep Gluetun's `NET_ADMIN`, `/dev/net/tun`, and the selected downloader's `network_mode: service:gluetun`. Publish downloader Web UI ports on Gluetun. Privateerr needs writable shared config, with its separate capabilities dropped; do not give it Gluetun's tunnel privileges.

Dockge itself does not need TUN. Do not switch the whole stack to host networking to solve a port issue. Check the [network guide](networking-and-vpn.md) for local controls versus VPN-forwarded peer ports.

## Use Custom App instead

Skip this section when using Dockge. TrueNAS's YAML editor needs resolved Compose values; it does not discover a separate `.env` automatically.

> [!WARNING]
> Rendered Compose contains private credentials and paths. Create it on the deployment host with private permissions, and never commit it or paste it into public support reports.

From the generated project directory on TrueNAS:

```sh
umask 077
docker compose config > truenas-compose.yml
```

Open **Apps → Discover Apps → Custom App → Install via YAML**, choose a lowercase application name, paste the reviewed file, and deploy. Follow the [current Custom App procedure](https://apps.truenas.com/managing-apps/installing-custom-apps/) for the exact screen. YAML validation does not prove folder access or live service health.

## Verify and operate

Use the selected manager's logs to confirm Privateerr readiness, Gluetun's healthy tunnel, and downloader startup. Sign in to the downloader, check write access, then [connect your applications](../projects/plundarr/connect-applications.md). Managers must see the same completed download path.

For updates, follow [updates and backups](../projects/plundarr/upgrading.md). Keep one authoritative private `.env`. Regenerate with the complete service selection, review files, preserve existing state, and copy only reviewed changes into the managed stack. Export application databases and named volumes separately; the config tree alone is insufficient.

| Symptom | First check |
| --- | --- |
| Dockge cannot find the stack | Stack directory, Compose filename, and matching absolute host/container paths |
| Empty Compose variables | Private `.env` beside the Compose file and readable by Dockge |
| Host path denied | Dataset traversal, ACLs, numeric identity, and container UID mapping |
| Gluetun cannot open TUN | Its device mapping and `NET_ADMIN` |
| Downloader UI unreachable | Host port published on Gluetun and firewall access |
| Conflicting ports or names | Another copy of the project is running |
