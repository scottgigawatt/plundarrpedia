---
title: Duplex
description: Generate the Plundarr preset for Plex metadata, artwork, monitoring, notifications, and recovery tools.
icon: material/television-classic
status: updated
---

# Duplex preset 📺

Duplex is now a maintained Plundarr preset for the backstage work around an existing Plex Media Server. Maraudarr generates the complete project under `dist/duplex/`; you no longer need to assemble or update a separate Duplex Compose chart for new deployments.

The name remains short for **Docker Utilities for Plex**. The preset focuses on curation, cleanup, monitoring, notifications, and recovery rather than downloading media or running the Plex server itself.

## Understand the default fleet

| Tool | Selection | Job |
| --- | --- | --- |
| Kometa | Core | Builds collections, applies metadata, and manages overlays from operator-owned configuration. |
| ImageMaid | Core | Reports on and cleans Plex artwork with operator-selected safeguards. |
| Tautulli | Optional | Records Plex activity, history, and usage. |
| PATTRMM | Removable default | Produces returning-soon metadata and overlays for Kometa. |
| Notifiarr | Removable default | Connects the host and media applications to Notifiarr. |
| Overlay Reset | Optional and `tools` profile | Removes Kometa overlays through an explicit dry-run-first repair command. |
| Watchtower | Optional | Updates eligible containers when you deliberately add it. |

## Generate the preset

```sh
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
make ship PRESET=duplex
```

Review `dist/duplex/.env`, especially Plex connection values and the Kometa and ImageMaid host paths. Then validate and launch:

```sh
make config PRESET=duplex
make up PRESET=duplex
```

## Keep Kometa state external

Set `KOMETA_CONFIG_PATH` to an independently managed Kometa checkout containing `config.yml`, assets, metadata, and overlays. Maraudarr mounts that directory but does not create a submodule, clone the repository, or manage its contents.

`KOMETA_RUNTIME_CONFIG_PATH` selects the existing YAML file shared by Kometa and PATTRMM at `/config/config.yml`. It defaults to `${KOMETA_CONFIG_PATH}/config.yml`; set it only when selecting a different file. A missing file fails the bind mount instead of being created as a directory. Regeneration preserves your selected path and external state.

Set `IMAGEMAID_PLEX_PATH` to the Plex application-data directory that contains `Cache`, `Metadata`, and `Plug-in Support`. Grant only the access each tool needs and back up state before enabling cleanup actions.

## Reset overlays safely

First add Overlay Reset, retaining any other service additions and removals:

```sh
make ship PRESET=duplex ADD_SERVICES=overlay-reset
```

It is excluded from ordinary `make up` runs by the `tools` profile. Confirm the Plex URL, token, and target library in `.env`, keep `OVERLAY_RESET_DRY_RUN=True`, then inspect a dry run:

```sh
make kometa-overlay-reset PRESET=duplex
```

> [!CAUTION]
> Overlay Reset is destructive and has no undo. Set `OVERLAY_RESET_DRY_RUN=False` only after reviewing the dry run and backups. Do not run two overlay-reset jobs concurrently.

For monitoring, add Tracearr or Tautulli explicitly; neither is included in Duplex by default. See [media monitoring](../plundarr/monitoring.md).

## Add Watchtower

Watchtower is not a Duplex default. Add it only if one Watchtower instance does not already manage the host:

```sh
make ship PRESET=duplex ADD_SERVICES=watchtower
```

[Compare every preset](index.md){ .md-button }
[Open the Plundarr repository](https://github.com/scottgigawatt/plundarr){ .md-button .md-button--primary }
