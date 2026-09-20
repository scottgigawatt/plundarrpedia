---
title: Plundarr Quick Start
description: Generate, review, and launch the default Plundarr deployment under dist/plundarr.
icon: material/rocket-launch
status: updated
---

# Plundarr quick start

This route generates the default Plundarr deployment with its current removable defaults, including qBittorrent, Calibre-Web Automated, Cleanuparr, Watchtower, and Tracearr. You can change those choices before launch.

Upgrading an existing v1 or retired standalone deployment? Follow [Upgrade to v2](upgrading.md) before generating over existing files. The default CWA and Tracearr selections require amd64 or arm64; on arm/v7, remove both and check every remaining selected image.

## 1. Clone the repository

```sh
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
```

## 2. Generate the default deployment

```sh
make ship
```

Maraudarr resolves the preset and service dependencies, validates the generated Compose model, and writes the complete project beneath `dist/plundarr/`:

```text
dist/plundarr/
├── docker-compose.yml
├── example.env
├── .env
└── config/
```

Use the interactive configurator when you want to review preset and service choices before generation:

```sh
make configure
```

Inspect the current catalog at any time:

```sh
make presets
make services
```

## 3. Review the generated environment

Edit `dist/plundarr/.env`. At minimum, review:

| Setting | Why it matters |
| --- | --- |
| `PIA_USER` / `PIA_PASS` | Required because the default preset includes the Privateerr and Gluetun VPN lane. |
| `DEFAULT_PUID` / `DEFAULT_PGID` | Must identify a host account that can access the mounted paths. |
| Service-specific groups | Must match supplemental access required by the selected services. |
| Host path variables | Must point to real download, media, ebook, backup, and configuration locations. |
| `HOMEPAGE_EXTERNAL_URL` / `HOMEPAGE_ALLOWED_HOSTS` | Must match the browser URL and allowed hostname/port; see [Homepage login](homepage.md). |
| `HOMEPAGE_AUTH_PASSWORD` / `HOMEPAGE_AUTH_SECRET` | Generated login password and session secret; read locally and keep private. |
| `TZ` | Keeps logs and schedules aligned with your location. |
| `COMPOSE_NETWORK_*` | Must not overlap another Docker, local-area network, or virtual private network route. |
| `*_WEBUI_PORT` | Must not collide with another host service. |

The checked-in defaults use Synology-shaped paths as examples. Linux and Docker Desktop users should replace them with real absolute host paths.

## 4. Validate before launch

```sh
make config
```

This renders the generated project with `dist/plundarr/.env`. Fix missing variables, invalid interpolation, network overlap, or port collisions before containers exist.

## 5. Launch and test the VPN lane

```sh
make up
make test-vpn
```

> [!WARNING]
> VPN tests may use real PIA credentials and inspect generated WireGuard material. Never commit `.env`, `wg0.conf`, `privateerr.env`, forwarded ports, or test logs.

## Generate common variations

Use a focused preset:

```sh
make ship PRESET=boudoirr
make ship PRESET=jellyfin
make ship PRESET=plex
make ship PRESET=calibre-web-automated
make ship PRESET=duplex
make ship PRESET=watchtower
make ship PRESET=portainer
```

Add a Usenet client to the default preset:

```sh
make ship ADD_SERVICES=sabnzbd
make ship ADD_SERVICES=nzbget
```

Generate a Usenet-only default deployment:

```sh
make ship REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=nzbget
```

Remove the default ebook service when another deployment already owns it:

```sh
make ship REMOVE_SERVICES=calibre-web-automated
```

`ADD_SERVICES` and `REMOVE_SERVICES` replace the removed `OPTIONAL_SERVICES` interface.

## Regenerate an existing deployment

Pull the configured Maraudarr image, regenerate only the selected preset, and validate the result:

```sh
make pull-image
make ship PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Replace `YOUR-PRESET` with the deployment ID and repeat your complete `ADD_SERVICES` / `REMOVE_SERVICES` selection, or review it in `make configure`. Regeneration preserves known environment values and does not overwrite application state. Values for temporarily unselected services remain in a marked footer so they can return later.

Back up the private `.env`, host configuration, and external application state before a major migration. Export [Tracearr database backups](monitoring.md#back-up-and-update) separately; `make backup` does not dump named volumes. Inspect the generated `.env`, service selection, and mounts before recreating containers with `make up PRESET=YOUR-PRESET`.

[Compare presets](../presets/index.md){ .md-button }
[Configure the generated stack](configuration.md){ .md-button .md-button--primary }
