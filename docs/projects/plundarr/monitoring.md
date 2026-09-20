---
title: Media Monitoring
description: Configure Tracearr or Tautulli and preserve viewing history with exported application backups.
icon: material/chart-timeline-variant
status: new
---

# Monitor media servers

Tracearr is Plundarr's preferred media monitor and a removable default. It connects to Plex, Jellyfin, or Emby over the network, including servers in other projects or on other hosts. Tautulli remains an optional Plex monitor; Duplex includes neither monitor by default.

## Select a monitor

The `tracearr` selection includes the application, TimescaleDB, and Redis as one unit. Its internal containers are not separate catalog choices. It supports amd64 and arm64, not arm/v7.

For a focused alternative or another preset:

```sh
make ship PRESET=plundarr REMOVE_SERVICES=tracearr ADD_SERVICES=tautulli
make ship PRESET=duplex ADD_SERVICES=tracearr
```

These are separate examples. Keep your complete service additions and removals when regenerating an existing deployment. You may also select both monitors.

## Connect a media server

Review `dist/<preset>/.env`, then start the selected project. For the default Plundarr preset:

```sh
make up PRESET=plundarr
```

Open `http://YOUR-HOST:3080`, using the actual `TRACEARR_WEBUI_PORT`, create the owner account, and connect a media server with an address reachable from Tracearr. `localhost` refers to Tracearr's container, not your host or media server. No media-library mount or VPN dependency is required.

Maraudarr generates database and authentication secrets in `.env` and preserves them on regeneration. Keep that file private. Changing `TRACEARR_DB_PASSWORD` in `.env` does not change the password in an already initialized database; coordinate database credential changes explicitly.

| Setting | Default | Purpose |
| --- | --- | --- |
| `TRACEARR_WEBUI_PORT` | `3080` in Plundarr | Browser-facing host port. |
| `TRACEARR_PORT` | `3000` | Internal application, widget, and healthcheck port. |
| `TRACEARR_DB_TAG` | `pg18` | TimescaleDB HA channel based on PostgreSQL 18. |
| `TRACEARR_TRUST_PROXY` | `false` | Enable only behind a trusted reverse proxy. |

The database and Redis have no published host ports. After changing `.env`, recreate affected containers with the matching preset's `make up` command.

## Connect Homepage

When both services are selected, Maraudarr generates a native Tracearr widget. Set `HOMEPAGE_VAR_TRACEARR_HREF` to the browser URL and `HOMEPAGE_VAR_TRACEARR_KEY` to an API key created in Tracearr. The internal widget URL defaults to `http://tracearr:3000`, independently of the host port. Recreate Homepage after environment changes.

Regeneration rebuilds Homepage service cards while preserving existing `settings.yaml`; see [Homepage customization](homepage.md#preserve-dashboard-customization).

## Back up and update

Tracearr's database, Redis state, and internal backup workspace use project-scoped named Docker volumes. Regeneration, `make down`, and `make nuke` preserve these volumes. `make backup` archives the host config tree only; it does not dump databases or copy named volumes.

With Tracearr running, export a consistent application backup before archiving host configuration. From the Plundarr repository root:

1. Create the application backup and confirm success.

   ```sh
   docker compose --project-directory dist/plundarr exec -T tracearr node apps/server/scripts/backup.ts
   ```

2. Copy the backup workspace into the host config tree.

   ```sh
   mkdir -p dist/plundarr/config/tracearr/backups
   docker compose --project-directory dist/plundarr cp tracearr:/data/backup/. dist/plundarr/config/tracearr/backups/
   ```

3. Confirm an archive exists, then include it in the host backup.

   ```sh
   ls -lh dist/plundarr/config/tracearr/backups/
   make backup PRESET=plundarr
   ```

Substitute the directory and preset throughout when deploying elsewhere. Downloading an application backup through Tracearr's web interface is another option. Duplicati also needs exported backups in its selected source paths. Restore through the application's backup interface; do not copy live PostgreSQL files.

> [!CAUTION]
> `make delete-config` deletes the host config tree, including backup exports stored there. Keep a verified off-host backup and the matching private `.env`. Named-volume survival is not a substitute for an independent backup.

Watchtower can update Tracearr, but its database and Redis are excluded. `make up` still pulls selected images and may update floating database tags. Review changes and export backups before updating; use exact image tags where needed. Keep your viewing history in a lifeboat.
