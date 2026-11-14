---
title: Synology
description: Deploy Plundarr on DSM with deliberate paths, permissions, networking, and VPN validation.
icon: material/nas
---

# Synology

This guide covers deploying Plundarr on a Synology NAS through DSM 7.4's **Container Manager**. Synology is one supported harbor, not a requirement baked into the applications. DSM-specific work is concentrated in shared-folder paths, permissions, firewall rules, Container Manager projects, and the TUN device used by Gluetun.

## 1. Generate the deployment artifact

Complete [Plundarr quick start steps 1–2](../projects/plundarr/quick-start.md#1-open-the-interactive-generator) on this host or a workstation, then validate without starting. Continue deployment here; do not start another copy on the generation host.

Keep the generated `dist/plundarr/docker-compose.yml`, `.env`, and `config/` tree together. Copy that complete directory to a durable location such as:

```text
/volume1/docker/plundarr
```

> [!IMPORTANT]
> Edit the generated `.env`, not `example.env`. Confirm every `/volume1` or `/volume2` path actually exists on this NAS before Container Manager creates the project.

## 2. Design the media paths

A practical layout keeps completed downloads and final libraries under one shared-folder tree:

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

Use consistent container paths across downloaders and media managers. If qBittorrent reports `/downloads/torrents/movie.mkv`, Radarr should see that same file at the same container path.

## 3. Match permissions

Record the numeric user and group that should own media files:

```sh
id media-user
```

Set the matching `DEFAULT_PUID` and `DEFAULT_PGID` values in `.env`. Set `DEFAULT_GROUP` to the supplemental DSM group used for shared paths, then grant that identity read/write access to downloads, the applicable library folders, and service configuration directories.

Giving every container full control of every shared folder makes a permissions error disappear by creating a much larger security problem. Grant each service only the paths it needs.

## 4. Confirm the VPN device

Gluetun needs `/dev/net/tun` plus the `NET_ADMIN` capability declared in the generated Compose file. Privateerr separately runs as UID 0 with all Linux capabilities dropped and `no-new-privileges`; do not grant it Gluetun's network privileges. Review [recovery requirements](../projects/privateerr/automatic-recovery.md#enable-recovery) alongside the generated definition.

```sh
ls -l /dev/net/tun
```

If the device is absent after a reboot, review Plundarr's [TUN helper](https://scottgigawatt.github.io/plundarr/project-guides/scripts/#synologytunsh). Use the [shared Synology boot-task procedure](https://scottgigawatt.github.io/plundarr/project-guides/scripts/#create-a-synology-boot-task) to schedule it as `root` before a dependent VPN-stack restart.

<!-- markdownlint-disable-next-line MD033 -->
<a id="6-check-networking-and-the-dsm-firewall"></a>

## 5. Check networking and the DSM firewall

- Make sure the Plundarr subnet does not overlap the LAN, another Compose
  project, or a remote VPN route.
- If the DSM firewall is enabled, allow the generated bridge subnet before launch. For default Plundarr, allow all ports from `172.20.0.0` with mask `255.255.0.0`. Use the subnet from your generated `.env` if customized, and repeat for each bridge-network preset. See [Plundarr's firewall steps](https://scottgigawatt.github.io/plundarr/setup/#configure-the-synology-firewall).
- Permit only the Web UI host ports you intend to use from trusted LAN sources.
- Publish qBittorrent, SABnzbd, or NZBGet ports on Gluetun when those services
  use `network_mode: service:gluetun`.
- Prefer a private access layer or authenticated HTTPS reverse proxy over
  exposing application UIs directly to the internet.
- Enable WebSocket and HTTP/1.1 proxy support for applications that require
  persistent connections.

### Homepage behind HTTPS

Before opening Homepage, set `HOMEPAGE_EXTERNAL_URL` to its HTTPS browser URL and `HOMEPAGE_ALLOWED_HOSTS` to the matching hostname and optional nonstandard port without the scheme. Configure the DSM reverse proxy and certificate separately, forwarding to `HOMEPAGE_WEBUI_PORT` and preserving the original host and forwarded HTTPS scheme. Recreate Homepage after editing `.env`, then sign in with the generated password. See [Homepage login](../projects/plundarr/homepage.md) for the complete setup and recovery steps.

<!-- markdownlint-disable-next-line MD033 -->
<a id="5-create-the-container-manager-project"></a>

## 6. Create the Container Manager project

1. Open **Container Manager → Project**.
2. Select **Create** and choose the generated project directory.
3. Use a stable project name such as `plundarr`.
4. Confirm Container Manager found `docker-compose.yml` and `.env` together.
5. Review host paths, published ports, and the custom network before building.

Do not paste only the Compose file into an unrelated directory. Relative `./config/...` mounts resolve from the project directory and must travel with the deployment.

## 7. Validate in layers

Start the project, then run these checks from the deployed directory containing `docker-compose.yml` and `.env`:

```sh
docker compose config --quiet
docker compose ps
docker compose logs --tail=100 privateerr gluetun
```

When operating directly from the Plundarr checkout, use `make test-vpn PRESET=plundarr` to check its generated deployment. A copied Container Manager deployment has no Makefile; validate its VPN lane through the running service logs and client interface.

Only after the tunnel and download-client path are healthy should you configure Prowlarr, Radarr, Sonarr, request services, and playback applications.

For coordinated stack startup after each reboot, use Plundarr's [restart helper and shared boot-task setup](https://scottgigawatt.github.io/plundarr/project-guides/scripts/#composerestartsh).

Back up `config/` and the private `.env` through a secret-aware process. Transcode directories, caches, and ordinary container logs usually do not belong in the same backup tier as application databases.

## Optional: restore trusted Docker CLI access after boot

This optional step is only for trusted administrators using Docker over SSH. Container Manager can recreate `/var/run/docker.sock` with root-only group ownership after a DSM reboot or package update. This affects trusted users who run Docker commands over SSH; it does not require making the socket writable by every local account.

If the socket loses the intended group access, create a `docker` group under **Control Panel → User & Group → Group** and add only trusted DSM users who need Docker CLI access. Plundarr's [Docker socket helper](https://scottgigawatt.github.io/plundarr/project-guides/scripts/#synologydocker-socketsh) lists its prerequisites, command, and expected result. Follow the [shared boot-task procedure](https://scottgigawatt.github.io/plundarr/project-guides/scripts/#create-a-synology-boot-task) with **User** set to `root`.

> [!CAUTION]
> Docker-group membership grants root-equivalent control of the NAS through the Docker daemon. Add only trusted administrators; do not replace the helper's `0660` mode with world-writable permissions.
