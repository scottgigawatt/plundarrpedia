---
title: Updates and backups
description: Update generators and running applications while preserving settings and recoverable state.
icon: material/update
---

# Update and back up your deployment

The Maraudarr generator, generated Compose file, runtime images, and application databases are separate. Pulling a new image does not change the Compose file. Regeneration does not update running containers or move their data.

## Back up before changes

- Record your preset, complete service selection, project name, image references, ports, mounts, and volumes.
- Save the Compose file and private `.env` through a secret-aware backup process.
- Export databases with each application's backup tools. [Tracearr](monitoring.md#back-up-and-update) uses named volumes; a host config archive does not contain its database.
- Preserve external Kometa/Plex state and matching encryption keys for Cruisarr or Themerr. Keep a verified off-host recovery copy.

Stop affected applications before raw database file copies. Never run two database instances against the same files. `make backup`, when using repository helpers, archives only the selected host config tree; `.env`, external paths, and named volumes need separate coverage.

## Regenerate when changing the stack definition

To change services or adopt generator changes, rerun the [interactive generator](quick-start.md#1-open-the-interactive-generator) from the same mounted parent directory. Select your complete intended service set again; preserved `.env` assignments do not remember the selection. Stop retiring services before omitting them, and review remaining Compose orphans before removal.

Maraudarr preserves existing environment assignments, image references, and application state. Review generated changes before applying them. Homepage service cards are regenerated; persistent card customization belongs in the generator's source fragments. Other existing Homepage settings are preserved. Privateerr replaces its two image-owned scripts on long-running startup; keep custom scripts under other names.

Repository users can use `make pull-image` followed by `make configure`. A source-built generator must be rebuilt deliberately after source changes; see [developer documentation](https://scottgigawatt.github.io/plundarr/development/maraudarr/).

## Apply runtime changes

Review the selected images' release requirements and architecture support, then edit runtime references in the deployed `.env`. From its directory:

```sh
docker compose config --quiet
docker compose pull
docker compose up --detach --force-recreate
docker compose ps
```

A restart does not reload environment values or changed mounts. When replacing Gluetun, recreate the complete VPN group and dependent applications together. Healthy saved VPN settings are reused; an intentional region change uses the [separate regeneration procedure](configuration.md#vpn-region-selection).

For Synology or TrueNAS, apply the reviewed configuration through the manager controlling that project. Start only one copy. Confirm the VPN, downloader login and imports, application data, dashboard login, and any monitoring integrations after the update.

## Recover or clean up safely

If an update fails, stop affected containers without deleting volumes. Restore the saved Compose/settings and matching application backup where needed. Downgrading an image does not reverse a database-format change. Restore encryption keys with the data they protect, and retain the original recovery copy until verification succeeds.

`docker compose down` preserves state. Repository `make remove-stack` removes scoped Docker resources and build cache while preserving application volumes, deployment files, VPN configuration, and host backups; a later start may need image downloads. `make delete-config` deletes the selected host config tree and any backup exports there. Destructive cleanup is not a required update step.
