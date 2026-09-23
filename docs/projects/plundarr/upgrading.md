---
title: Upgrade to v2
description: Migrate Plundarr v1 and retired standalone charts while preserving settings and application state.
icon: material/update
status: new
---

# Upgrade to v2

[Plundarr v2.0.0](https://github.com/scottgigawatt/plundarr/releases/tag/v2.0.0) consolidates deployments under `dist/<preset>/`, changes service defaults and command names, and enables Homepage password login. [Privateerr v2.0.0](https://github.com/scottgigawatt/privateerr/releases/tag/v2.0.0) changes repository maintenance commands while retaining its container interface and generated file paths.

Use this guide for a v1 Plundarr deployment or a retired standalone Boudoirr, Duplex, Jellyfin, or Calibre-Web Automated chart. Privateerr remains actively maintained separately and through Plundarr. Routine regeneration of an existing v2 preset is covered in the [quick start](quick-start.md#regenerate-an-existing-deployment).

## Adopt v2.1 VPN recovery

Plundarr v2.1.0 adds automatic recovery to generated deployments containing Privateerr and Gluetun. Use Privateerr v2.1.0 or later before recreating the hardened generated service. Follow [the recovery upgrade checklist](../privateerr/automatic-recovery.md#upgrade-a-generated-deployment) for preserved image pins, new settings, the shared key, and custom wrappers. Existing v2 deployments keep their `dist/<preset>/` layout and application state.

Image-only updates retain previous privileges and do not enable an absent recovery flag. Regeneration and container recreation apply the new chart. Intentional region changes also need [explicit regeneration](configuration.md#vpn-region-selection) because the supervisor reuses healthy saved files.

## Inventory and back up first

Record the existing Compose project name, selected services, image versions, host ports, mounts, and named volumes. Back up the old Compose file, private `.env`, application configuration, and external Kometa/Plex state. Export databases through their application backup tools and retain a verified off-host copy.

> [!IMPORTANT]
> Generating `dist/<preset>/` does not migrate old application state. Relative `./config` paths resolve beneath the new project directory, and a changed Compose project name can select new named volumes. Do not start a replacement project against empty or unintended storage.

Stop affected containers before copying application state or switching ownership of shared data. Keep the old deployment definition and pre-upgrade backups until the new deployment is verified. Do not use `nuke` or `delete-config` as migration steps.

## Generate the replacement project

Use an updated Plundarr checkout separately from the old deployment where practical. Refresh Maraudarr and generate the intended preset:

```sh
make pull-image
make ship PRESET=YOUR-PRESET
```

Replace `YOUR-PRESET` with the intended preset ID. Repeat the full `ADD_SERVICES` and `REMOVE_SERVICES` selection when needed, or review choices through `make configure`. Generation starts from preset defaults; preserved environment values do not restore an old service selection.

Review these changes before launch:

- `OPTIONAL_SERVICES` is removed; use `ADD_SERVICES` and `REMOVE_SERVICES`.
- qBittorrent remains the default downloader; SABnzbd and NZBGet are opt-in.
- Plundarr adds Tracearr as a removable default. CWA and Tracearr require amd64 or arm64; review image support on arm/v7.
- Duplex core is Kometa and ImageMaid, with PATTRMM and Notifiarr defaults. Select Tautulli and Overlay Reset explicitly if needed.
- Generated container names are project-scoped. Update external scripts or monitoring that relied on old names.
- Jellyfin uses the official image with a writable `/data` library root. Verify library paths, image-specific settings, ownership, and existing config compatibility before cutover.
- Preset network and host-port defaults may differ from the old chart. Check them against your host and other projects.

Map existing values into the new `.env`, then check every mount. Reuse intended named-volume identities or restore application exports into the new volumes deliberately. Never run the old and new databases against the same data simultaneously. If selected, point Kometa and PATTRMM at the existing shared file using [Duplex configuration](../presets/duplex.md#keep-kometa-state-external).

## Validate and cut over

If Homepage is selected, configure [its login](homepage.md) and inspect the generated service cards. Validate the selected project:

```sh
make config PRESET=YOUR-PRESET
```

Review resolved settings locally; the output can contain secrets. Confirm mounts, selected services, ports, and networks before starting:

```sh
make up PRESET=YOUR-PRESET
make ps PRESET=YOUR-PRESET
```

For a VPN-enabled preset, also run:

```sh
make test-vpn PRESET=YOUR-PRESET
```

Verify existing application data, library access, downloader imports, Homepage login, and monitoring before retiring the old deployment. Export [Tracearr backups](monitoring.md#back-up-and-update) separately from ordinary host config archives.

If cutover fails, stop the new project without deleting volumes. Restore the saved definition and settings; if an application migrated its database, restore its compatible pre-upgrade backup before restarting the old image. A container downgrade alone does not reverse a database migration.

## Update command names

| Previous command | Current command | Repository |
| --- | --- | --- |
| `make update-maraudarr` | `make pull-image` | Plundarr |
| `make backup-config` | `make backup` | Plundarr |
| `make build-multiarch` | `make build-platforms` | Plundarr and Privateerr |
| `make reset-config` | `make restore-test-config` | Plundarr and Privateerr |
| `make test-down` | `make clean-test` | Plundarr and Privateerr |
| `make start` / `make stop` | `make up` / `make down` | Plundarr and Privateerr |

Use `PRESET=YOUR-PRESET` for Plundarr deployment commands. These replacements do not apply to Plundarrpedia's own Makefile; see the [command reference](../../reference/commands.md).

`make clean` now removes disposable developer artifacts only. It does not stop the stack or reset generated configuration. `make down` preserves volumes and images. Privateerr's `restore-test-config` and `clean-test` replace generated VPN files with checked-in examples and belong to test cleanup. Plundarr's `delete-config` deletes its selected host configuration tree; its `nuke` preserves application volumes, deployment files, and backups while removing scoped Docker resources and build cache.

Existing Privateerr image consumers retain the same `wg0.conf` and `privateerr.env` handoff. Pull and recreate to apply an image update; do not regenerate production state solely to adopt renamed Make targets.
