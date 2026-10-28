---
title: Update a Deployment
description: Review generator and runtime updates while preserving configuration, keys, libraries, and application backups.
icon: material/update
status: updated
---

# Update a deployment

The generator image, generated Compose definition, runtime image pins, and application state are separate update boundaries. Pulling an image does not rewrite container options, and regenerating a project does not move data or stop containers removed from its service selection.

## Inventory and back up first

- [ ] Record the selected preset, complete service additions/removals, Compose project name, image references, ports, mounts, and named volumes.
- [ ] Save the Compose definition and private `.env` through a secret-aware backup process.
- [ ] Export databases and named volumes with their application tools. `make backup PRESET=YOUR-PRESET` archives the host config tree, not `.env`, external state, or Docker volumes.
- [ ] Preserve external Kometa settings, Velvarr's encryption key, and Themerr's state plus separate token key when selected.
- [ ] Keep a verified off-host recovery copy and check each selected application's architecture and release requirements.

Stop affected containers before making raw database copies or changing state ownership. Keep downloads and libraries separate from disposable build output. Never run two database instances against the same persistent files.

## Refresh the generator and review selection

Choose the intended [generator revision](quick-start.md#choose-the-generator): rebuild a source-selected image after updating the checkout, or pull the configured published image with `make pull-image`. Building or pulling the generator does not update running application containers.

From the Plundarr checkout, regenerate and validate the selected project:

```sh
make ship PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Replace `YOUR-PRESET` and repeat your complete `ADD_SERVICES` / `REMOVE_SERVICES` selection, or review it through `make configure`. Preserved `.env` values do not restore a prior service selection. Review the generated diff and any still-running Compose orphans before removing them.

Regeneration preserves existing environment assignments, image pins, application state, and operator-owned files. At runtime, Privateerr replaces its two image-owned Gluetun integration scripts before readiness; keep custom scripts under separate names. Review custom wrapper paths and authentication against [the recovery requirements](../privateerr/automatic-recovery.md#configure-a-generated-deployment). Homepage service cards are regenerated; keep persistent card customization in the source fragments. The safe `example.env` does not contain generated passwords or keys.

## Apply runtime changes

Set reviewed runtime image references in `dist/YOUR-PRESET/.env`, then pull and recreate the selected stack:

```sh
docker compose --project-directory dist/YOUR-PRESET pull
make up PRESET=YOUR-PRESET
make ps PRESET=YOUR-PRESET
```

Use the actual deployment directory when operating from a copied Synology or TrueNAS project; those copies do not contain the repository Makefile. Keep its private environment, selected configuration seeds, and application mounts aligned with the reviewed generated project. A plain restart does not reload environment values or changed mounts.

When replacing Gluetun, recreate its complete VPN namespace and dependent applications together. A healthy saved Privateerr pair is reused; runtime recreation alone does not rerun region selection. Use [explicit regeneration](configuration.md#vpn-region-selection) only when intentionally replacing that pair.

For a VPN-enabled preset, run `make test-vpn PRESET=YOUR-PRESET` after startup. Verify application data, downloader imports, libraries, Homepage login, and monitoring before considering the update complete. Resolved configuration and logs can contain secrets; review them locally.

## Recover or clean up safely

If an update fails, stop the affected stack without deleting volumes. Restore the saved definition and matching application backup where required; an image downgrade does not reverse a database-format change. Restore encryption keys with the state they protect.

`make down` preserves application state. `make clean` removes disposable developer artifacts. `make nuke` removes scoped Docker resources and build cache, clears Gluetun runtime state, and overwrites the saved VPN pair with checked-in examples. It preserves other application volumes, deployment files, and backups; preserve needed VPN files separately before using it. `make delete-config` deletes the selected host configuration tree. Neither destructive reset is an ordinary update step.

[Review backup boundaries](monitoring.md#back-up-and-update){ .md-button }
[Inspect current commands](../../reference/commands.md){ .md-button .md-button--primary }
