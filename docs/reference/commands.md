---
title: Commands
description: Use Docker Compose for generated projects and optional Make shortcuts from source checkouts.
icon: material/console
---

# Commands

Run Compose commands from the deployed directory containing `docker-compose.yml` and its private `.env`. This works for Docker-only generation and copied NAS projects. Logs and resolved configuration can contain secrets; inspect them locally.

## Everyday Compose commands

| Task | Command |
| --- | --- |
| Validate without displaying secrets | `docker compose config --quiet` |
| Pull and start selected services | `docker compose up --detach --pull always` |
| Check status | `docker compose ps` |
| Inspect one service | `docker compose logs --tail 100 SERVICE` |
| Stop while retaining application state | `docker compose down` |

Replace `SERVICE` with a Compose service name. Starting a service does not complete its application setup; follow the relevant quick start.

## Plundarr repository helpers

These optional commands run from a [Plundarr source checkout](../projects/plundarr/quick-start.md#use-repository-helpers-later). They operate on that checkout's `dist/<preset>/`, not an unrelated copied deployment. Omit `PRESET` for `plundarr`.

| Task | Command |
| --- | --- |
| Interactive generation | `make configure` |
| Inspect the selected catalog | `make presets`, `make services` |
| Generate directly | `make generate PRESET=YOUR-PRESET` |
| Pull and start services | `make up PRESET=YOUR-PRESET` |
| Status or logs | `make ps PRESET=YOUR-PRESET`, `make logs PRESET=YOUR-PRESET` |
| Inspect a running VPN | `make test-vpn PRESET=YOUR-PRESET` |
| Archive host config | `make backup PRESET=YOUR-PRESET` |

Replace `YOUR-PRESET` with its catalog ID. Repeat the complete service additions/removals when regenerating. The backup archive excludes `.env`, external state, and named-volume databases; follow [updates and backups](../projects/plundarr/upgrading.md).

> [!CAUTION]
> `make remove-stack` removes the selected project's Docker resources, the separate Maraudarr project, and scoped build cache; application volumes, deployment settings, VPN files, config, and backups remain. `make delete-config` deletes the selected host config tree, including exports stored there. Neither is an ordinary update step.

`make clean-artifacts` removes only disposable developer artifacts. `make config` and `make env` print resolved values and can reveal credentials. Use `make help` for the full list and source documentation for [maintenance tools](https://scottgigawatt.github.io/plundarr/project-guides/).

## Privateerr repository helpers

From the [standalone checkout](../projects/privateerr/quick-start.md), `make up` pulls and starts the three published services; `make ps`, `make logs`, and `make down` provide their Compose equivalents. `make up-build` builds Privateerr from source. `make wireguard-config` builds and creates fresh VPN files once; stop every supervisor sharing the destination first.

Source builds and disruptive live tests belong to the [developer testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/).

## Plundarrpedia authoring

Use the [contribution guide](../CONTRIBUTING.md) for `make docs-serve`, `make docs`, and lint prerequisites. Use the [image guide](../GHCR_README.md) to host the published wiki; local builds are optional.
