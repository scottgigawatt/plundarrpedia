---
title: Plundarr Quick Start
description: Generate, review, and launch the default Plundarr deployment under dist/plundarr.
icon: material/rocket-launch
status: updated
---

# Plundarr quick start

Generate one Compose project, review its private settings, then launch and verify it. You need Git, Make, Docker with Compose, and an active PIA subscription for a VPN-enabled preset. Check every selected image's architecture support; the default Calibre-Web Automated and Tracearr services require amd64 or arm64.

For an existing deployment, start with [update and backup checks](upgrading.md).

## Clone the repository

```sh
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
```

## Choose the generator

`MARAUDARR_IMAGE` selects the generator and its packaged service catalog. To refresh and use the configured published image (default `latest`):

```sh
make pull-image
make ship
```

For this checkout's catalog instead, explicitly build and select the source image:

```sh
export MARAUDARR_IMAGE=maraudarr:dev
make build
make ship
```

Keep that image selection for later commands. A checkout alone does not refresh a cached published catalog; source changes may be unreleased. Without an explicit selection, Make uses `ghcr.io/scottgigawatt/maraudarr:latest`, reuses it locally if present, or tries a pull and source-build fallback.

The project appears under `dist/plundarr/`: `docker-compose.yml`, safe `example.env`, private `.env`, and `config/`. Use `make configure` for interactive choices, or `make presets` and `make services` to inspect the selected catalog.

## Review the generated environment

Edit `dist/plundarr/.env` before launch:

| Review | Required action |
| --- | --- |
| `PIA_USER` / `PIA_PASS` | Supply PIA credentials for the VPN lane |
| User/group settings | Match host ownership and supplemental access |
| Host paths | Replace Synology-shaped examples with real absolute paths |
| `TZ`, `COMPOSE_NETWORK_*`, `*_WEBUI_PORT` | Set timezone and avoid route/port conflicts |
| [Homepage settings](homepage.md) | Match the browser URL/allowed host and read the generated password privately |
| [Recovery settings](../privateerr/automatic-recovery.md) | Keep the generated shared key private; review preserved opt-outs/image pins |

`example.env` contains reference values, not working generated credentials.

## Validate before launch

```sh
make config
```

Fix syntax/interpolation errors and review mounts, network choices, and host ports. This prints resolved configuration, which can contain secrets; it does not prove paths, permissions, or runtime health.

## Launch and test the VPN lane

```sh
make up
make test-vpn
```

`make up` pulls and recreates selected services. Check Privateerr readiness, Gluetun's healthy tunnel, then the download client's Web UI and synchronized port/interface before configuring managers. See [troubleshooting](troubleshooting.md) if any layer fails.

> [!WARNING]
> VPN validation uses real provider credentials and generated material. Keep `.env`, VPN files, API responses, and unsanitized logs private.

## Generate common variations

Use the [preset comparison and examples](../presets/index.md) to choose another deployment or add/remove services. Repeat the complete intended `ADD_SERVICES` / `REMOVE_SERVICES` selection on regeneration; saved environment assignments do not remember it.

## Regenerate an existing deployment

Follow [update a deployment](upgrading.md) for backups, generator refresh, selection review, and recreation. Regeneration preserves known environment values and application state, but does not stop removed services or back up databases, external state, or `.env`.
