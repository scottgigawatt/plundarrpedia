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
| Tautulli | Core | Records Plex activity, history, and usage. |
| PATTRMM | Removable default | Produces returning-soon metadata and overlays for Kometa. |
| Notifiarr | Removable default | Connects the host and media applications to Notifiarr. |
| Overlay Reset | Removable default and `tools` profile | Removes Kometa overlays through an explicit dry-run-first repair command. |
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

Set `IMAGEMAID_PLEX_PATH` to the Plex application-data directory that contains `Cache`, `Metadata`, and `Plug-in Support`. Grant only the access each tool needs and back up state before enabling cleanup actions.

## Reset overlays safely

Overlay Reset is excluded from ordinary `make up` runs by the `tools` profile. Keep `OVERLAY_RESET_DRY_RUN=True`, inspect the proposed changes, and invoke it explicitly:

```sh
make kometa-overlay-reset PRESET=duplex
```

Do not run two overlay-reset jobs concurrently. Switch off dry-run mode only after the output matches the recovery you intend.

## Add Watchtower

Watchtower is not a Duplex default. Add it only if one Watchtower instance does not already manage the host:

```sh
make ship PRESET=duplex ADD_SERVICES=watchtower
```

[Compare every preset](index.md){ .md-button }
[Open the Plundarr repository](https://github.com/scottgigawatt/plundarr){ .md-button .md-button--primary }
