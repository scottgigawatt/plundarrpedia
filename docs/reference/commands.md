---
title: Command Deck
description: Quick command reference for Plundarr, Privateerr, generated presets, and Plundarrpedia.
icon: material/console
status: updated
---

# Command deck

Run Make targets from the repository that owns the deployment. For copied Synology or TrueNAS projects, use Compose in the directory containing the matching definition and private `.env`. Resolved configuration, environment output, and logs can contain secrets.

## Plundarr and Maraudarr

Most deployment targets accept `PRESET=YOUR-PRESET`; omit it for `plundarr`.

| Task | Command |
| --- | --- |
| Choose services | `make configure`, `make presets`, `make services` |
| Generate a project | `make ship PRESET=YOUR-PRESET` |
| Validate before launch | `make config PRESET=YOUR-PRESET` |
| Pull and recreate selected services | `make up PRESET=YOUR-PRESET` |
| Check status or logs | `make ps PRESET=YOUR-PRESET`, `make logs PRESET=YOUR-PRESET` |
| Validate the running VPN lane | `make test-vpn PRESET=YOUR-PRESET` |
| Stop while preserving application state | `make down PRESET=YOUR-PRESET` |
| Archive host configuration | `make backup PRESET=YOUR-PRESET` |

Choose the [generator image](../projects/plundarr/quick-start.md#choose-the-generator) first. Backup archives exclude `.env`, external state, and named-volume databases; follow [update and backup checks](../projects/plundarr/upgrading.md). Select maintenance tools before invoking their targets: [Watchtower](../projects/presets/watchtower.md), [Overlay Reset](../projects/presets/duplex.md#reset-overlays-safely), and [Recyclarr](../projects/plundarr/configuration.md#music-and-quality-synchronization).

> [!CAUTION]
> `make nuke` removes scoped Docker resources/cache, clears Gluetun runtime state, and overwrites the saved VPN pair with examples. `make delete-config` deletes the selected config tree. Preserve needed VPN files and independent application backups first. Neither is an ordinary update step.

Use `make help` and the [developer documentation](https://scottgigawatt.github.io/plundarr/) for the complete target list. `make clean` removes disposable developer artifacts, preserving deployments and Docker resources.

## Privateerr standalone source

| Task | Command |
| --- | --- |
| Generate a fresh saved pair once | `make run-privateerr` |
| Pull and start the application stack | `make up` |
| Build Privateerr from the checkout and start | `make up-build` |
| Inspect services | `make ps`, `make logs` |
| Stop while preserving saved configuration | `make down` |

Follow the [standalone setup](../projects/privateerr/quick-start.md#run-the-standalone-example-stack) before startup. Stop every supervisor sharing the output directory before one-shot generation. Developer and live-test targets belong to the [Privateerr testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/).

## Preset examples

Use the [preset comparison](../projects/presets/index.md) for focused deployments and service selection. Repeat the complete additions/removals on regeneration.

## Plundarrpedia

| Task | Command |
| --- | --- |
| Preview authoring with live reload | `make serve` |
| Export the strict site | `make site` |
| Check Markdown and repository rules | `make markdown`, `make lint` |
| Build and start a local production copy | `make run` |
| Stop the local copy | `make down` |

See [contributing](../CONTRIBUTING.md) for prerequisites and [advanced usage](../ADVANCED_USAGE.md) for image/maintenance details. `make clean` deletes only generated site output.

## Universal diagnostics

Inspect status first, then the failing service's logs:

```sh
docker compose ps
docker compose logs --tail=100 SERVICE
```

Replace `SERVICE` with its Compose name. Validate syntax with `docker compose config --quiet`; inspect resolved output locally only when needed.
