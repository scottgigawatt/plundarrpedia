---
title: Command Deck
description: Quick command reference for Plundarr, Privateerr, generated presets, and Plundarrpedia.
icon: material/console
status: updated
---

# Command deck

## Plundarr and Maraudarr

Most deployment targets accept `PRESET=YOUR-PRESET`. Omit it for the default `plundarr` project.

| Command | Purpose |
| --- | --- |
| `make ship` | Generate the default Plundarr project under `dist/plundarr/`. |
| `make ship PRESET=YOUR-PRESET` | Generate one named preset under `dist/YOUR-PRESET/`. |
| `make configure` | Open Maraudarr's interactive preset and service picker. |
| `make pull-image` | Pull the configured published Maraudarr image. |
| `make presets` | List presets and their default services. |
| `make services` | List every selectable service. |
| `make compose-services PRESET=YOUR-PRESET` | List services in an existing generated Compose project. |
| `make config PRESET=YOUR-PRESET` | Render and validate the generated Compose model. |
| `make env PRESET=YOUR-PRESET` | Print evaluated environment values. |
| `make up PRESET=YOUR-PRESET` | Build, create, and start the selected project. |
| `make down PRESET=YOUR-PRESET` | Stop the project while preserving volumes, images, environment, config, and backups. |
| `make ps PRESET=YOUR-PRESET` | Print compact service status. |
| `make logs PRESET=YOUR-PRESET` | Follow the selected project logs. |
| `make backup PRESET=YOUR-PRESET` | Archive the selected configuration tree. |
| `make watchtower-run-once PRESET=watchtower` | Run one host-wide Watchtower update pass. |
| `make kometa-overlay-reset PRESET=duplex` | Run the profile-gated overlay repair tool. |
| `make test-unit` | Run Maraudarr unit tests. |
| `make test` | Run the offline generator, policy, workflow, and preset matrix. |
| `make test-vpn` | Validate an already-running VPN and downloader lane. |
| `make test-e2e` | Launch and validate the focused live VPN path. |
| `make test-image` | Test the hardened Maraudarr image. |
| `make build-platforms` | Validate Maraudarr on every published architecture. |
| `make docs` | Build Plundarr's strict developer documentation. |
| `make docs-serve` | Preview Plundarr's developer documentation. |

The published [Plundarr developer documentation](https://scottgigawatt.github.io/plundarr/) covers Maraudarr architecture, extension contracts, testing, and the generated Python reference.

!!! caution
    `make nuke PRESET=YOUR-PRESET` removes attributable Docker resources but preserves deployment files and application state. `make delete-config PRESET=YOUR-PRESET` deletes the selected configuration tree. Back up the deployment before either destructive operation.

## Privateerr standalone source

Use these only when you need the focused Privateerr repository outside Plundarr:

| Command | Purpose |
| --- | --- |
| `make run-privateerr` | Generate fresh `wg0.conf` and `privateerr.env`. |
| `make up` / `make down` | Start or stop the Privateerr and Gluetun example stack. |
| `make env` | Print evaluated environment values. |
| `make config` | Render the resolved Compose model. |
| `make ps` / `make logs` | Inspect service status or logs. |
| `make backup` | Archive the complete Privateerr configuration directory. |
| `make restore-test-config` | Restore checked-in safe example files. |
| `make clean-test` | Stop test containers and restore example state. |
| `make test` | Run offline policy and helper tests. |
| `make test-e2e` | Run live Buccaneerr validation with supplied credentials. |
| `make build-platforms` | Validate both images on published architectures. |

## Preset examples

```sh
make ship PRESET=boudoirr ADD_SERVICES=sabnzbd
make ship PRESET=jellyfin
make ship PRESET=plex
make ship PRESET=calibre-web-automated
make ship PRESET=duplex ADD_SERVICES=watchtower
make ship PRESET=watchtower
```

## Plundarrpedia

| Command | Purpose |
| --- | --- |
| `make serve` | Run the Compose live-reload authoring service. |
| `make site` | Export the strict static site into `site/`. |
| `make clean` | Delete the generated static site. |
| `make build` | Build the unprivileged Nginx image. |
| `make build-multiarch` | Validate every published platform. |
| `make config` | Validate the one-file Compose deployment. |
| `make run` / `make down` | Start or stop the production wiki stack. |

## Universal diagnostics

Run these from the directory containing the relevant Compose file and `.env`:

```sh
docker compose config
docker compose ps
docker compose logs --tail=100 SERVICE
docker inspect CONTAINER
docker network ls
git status --short
```
