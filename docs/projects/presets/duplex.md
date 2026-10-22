---
title: Duplex
description: Configure Plex curation, Plex/Jellyfin theme songs, PATTRMM Neo, notifications, and deliberate cleanup tools.
icon: material/television-classic
status: updated
---

# Duplex preset 📺

Duplex is the Plundarr preset for the backstage work around an existing Plex Media Server and Plex/Jellyfin theme songs. Maraudarr generates the complete project under `dist/duplex/`.

The name is short for **Docker Utilities for Plex**. The preset does not deploy the Plex or Jellyfin server itself. Its required Themerr service supports amd64 and arm64, so the full preset does not run on arm/v7.

## Understand the default fleet

| Tool | Selection | Job |
| --- | --- | --- |
| Kometa | Core | Builds collections, applies metadata, and manages overlays from operator-owned configuration. |
| ImageMaid | Core | Reports on and cleans Plex artwork with operator-selected safeguards. |
| Themerr | Core | Manages theme songs through one instance connected to Plex and Jellyfin. |
| Tautulli | Optional | Records Plex activity, history, and usage. |
| PATTRMM Neo | Removable default | Generates collection YAML and paired Plex-GUID lists for Kometa. |
| Notifiarr | Removable default | Connects the host and media applications to Notifiarr. |
| Overlay Reset | Optional and `tools` profile | Removes Kometa overlays through an explicit dry-run-first repair command. |
| Watchtower | Optional | Updates eligible containers when you deliberately add it. |

## Generate the preset

Complete [generator setup](../plundarr/quick-start.md#choose-the-generator), then generate Duplex:

```sh
make ship PRESET=duplex
```

Review `dist/duplex/.env`, especially Plex connection values, Kometa/ImageMaid paths, and Themerr's key permissions. Prepare the external settings and writable directories below, then validate and launch:

```sh
make config PRESET=duplex
make up PRESET=duplex
```

## Keep Kometa state external

Set `KOMETA_CONFIG_PATH` to an independently managed Kometa checkout containing `config.yml`, assets, metadata, and overlays. Maraudarr mounts that directory but does not create a submodule, clone the repository, or manage its contents.

`KOMETA_RUNTIME_CONFIG_PATH` selects the existing YAML file shared by Kometa and PATTRMM Neo at `/config/config.yml`. It defaults to `${KOMETA_CONFIG_PATH}/config.yml`; set it only when selecting a different file. A missing file fails the bind mount instead of being created as a directory. Regeneration preserves your selected path and external state.

Set `IMAGEMAID_PLEX_PATH` to the Plex application-data directory that contains `Cache`, `Metadata`, and `Plug-in Support`. Grant only the access each tool needs and back up state before enabling cleanup actions.

## Prepare PATTRMM Neo

The `pattrmm` service uses the `neo` image channel. Create the external `PATTRMM_SETTINGS_PATH` directory, defaulting to `${KOMETA_CONFIG_PATH}/pattrmm`, and author the selected `PATTRMM_SETTINGS` files (`settings.yml` by default). Maraudarr does not seed or overwrite that external configuration. Keep private Plex/TMDb values in the shared runtime configuration out of Git.

Give `DEFAULT_PUID:DEFAULT_PGID` write access to `PATTRMM_CONFIG_PATH/data` and the configured collection output directories; settings and the runtime connection file need read access. Keep generated collection YAML and its paired GUID lists together. Default Neo runs at `02:00,14:00` precede Kometa's `05:00,17:00` in `TZ`; allow generation to finish before Kometa reads the output.

For a manual check from the Plundarr checkout:

```sh
docker compose --project-directory dist/duplex run --rm --no-deps pattrmm --run
```

Confirm `All operations complete` for every selected settings file and no failed-settings messages or tracebacks; successful parent-process exit alone is insufficient. See the [Neo settings and schedule guide](https://github.com/scottgigawatt/plundarr/blob/main/docker/services/pattrmm/README.md).

## Connect Themerr

Maraudarr creates the private `THEMERR_TOKEN_KEY_PATH` once with owner-only permissions and preserves its bytes. Keep it readable by the configured runtime UID and pair it with `THEMERR_CONFIG_PATH` in backups. Existing managed state without its matching key blocks regeneration; restore the original key. Operator-selected external state and key paths must already exist with correct access.

Open `https://YOUR-HOST:9494`, using the configured host port, and verify the initial self-signed certificate against your host. Read the first-run setup link locally from Themerr's logs and create the administrator account; keep that link private. Add Plex through sign-in and Jellyfin through its server URL/API key. Cross-project servers need addresses reachable between their networks; `localhost` and another project's service name usually do not work.

The separate HTTP port `9495` serves Jellyfin connector files, not administration. Use the connector bundled with the selected Themerr image and follow its server-version requirements. After connector installation, restart Jellyfin manually, confirm it is active, and enable theme songs in each supported client. Jellyfin needs writable media folders; Themerr's chart does not mount the media library.

Keep seeded cleanup, automatic Jellyfin restarts, legacy-plugin removal, and user-theme replacement disabled unless deliberately reviewed. Theme coverage depends on matching identifiers; TPDB/StashDB-only scenes may have few matches. Back up state, certificates, and the matching separate key as one recovery set. The [Themerr guide](https://scottgigawatt.github.io/plundarr/project-guides/themerr/) covers connector and server setup.

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
