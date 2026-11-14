---
title: Media Monitoring
description: Configure Tracearr or Tautulli and preserve viewing history with exported application backups.
icon: material/chart-timeline-variant
status: new
---

# Monitor media servers

Tracearr is Plundarr's preferred media monitor and a removable default. It connects to Plex, Jellyfin, or Emby over the network, including servers in other projects or on other hosts. Tautulli remains an optional Plex monitor; Duplex includes neither monitor by default.

Follow the [Plundarr quick start](quick-start.md) to generate and start your deployment first. Run this page's Docker Compose commands from the generated directory containing `docker-compose.yml` and `.env`, such as `dist/plundarr/`.

## Select a monitor

The `tracearr` selection includes the application, TimescaleDB, and Redis as one unit. Its internal containers are not separate catalog choices. It supports amd64 and arm64, not arm/v7.

Select a monitor in the interactive generator. You may choose Tautulli instead of Tracearr, add Tracearr to another preset, or select both monitors. Keep your complete service additions and removals when [regenerating an existing deployment](upgrading.md).

## Connect a media server

Confirm that the selected Tracearr services are running:

```sh
docker compose ps tracearr tracearr-db tracearr-redis
```

1. Open `http://YOUR-HOST:3080`, replacing `YOUR-HOST` with your Docker host's address and using the actual `TRACEARR_WEBUI_PORT` from `.env`.
2. Create the owner account and [connect a media server](https://docs.tracearr.com/getting-started/first-server) with an address reachable from Tracearr. `localhost` refers to Tracearr's container, not your host or media server. No media-library mount or VPN dependency is required.
3. Play a sample item on the connected server and confirm that its session appears in Tracearr.

Maraudarr generates database and authentication secrets in `.env` and preserves them on regeneration. Keep that file private. Changing `TRACEARR_DB_PASSWORD` in `.env` does not change the password in an already initialized database; coordinate database credential changes explicitly.

| Setting | Default | Purpose |
| --- | --- | --- |
| `TRACEARR_WEBUI_PORT` | `3080` in Plundarr | Browser-facing host port. |
| `TRACEARR_PORT` | `3000` | Internal application, widget, and healthcheck port. |
| `TRACEARR_DB_TAG` | `pg18` | TimescaleDB HA channel based on PostgreSQL 18. |
| `TRACEARR_TRUST_PROXY` | `false` | Enable only behind a trusted reverse proxy. |

The database and Redis have no published host ports. After changing `.env`, recreate the affected containers using the [update procedure](upgrading.md).

## Connect Homepage

When both services are selected, Maraudarr generates a native Tracearr widget. Set `HOMEPAGE_VAR_TRACEARR_HREF` to the browser URL and `HOMEPAGE_VAR_TRACEARR_KEY` to an API key created in Tracearr. The internal widget URL defaults to `http://tracearr:3000`, independently of the host port. Recreate Homepage after environment changes.

Regeneration rebuilds Homepage service cards while preserving existing `settings.yaml`; see [Homepage customization](homepage.md#preserve-dashboard-customization).

## Back up and update

Tracearr's database, Redis state, and internal backup workspace at `/data/backup` use project-scoped named Docker volumes. Regeneration, `docker compose down` without volume removal, and Plundarr's `make remove-stack` preserve these volumes. A host config archive does not dump databases or copy named volumes.

With Tracearr running, export an application backup before updating:

1. Open **Settings → Backup** and select **Create Backup**.
2. Wait for the backup to finish and appear in the backup history, then download its ZIP archive.
3. Keep a verified copy off the Docker host with the matching private `.env` file. Tracearr's generated authentication secrets are needed alongside its saved data.

Tracearr currently labels backup and restore as beta. Follow the [upstream backup and restore guidance](https://docs.tracearr.com/configuration/backup) and verify your independent backup before relying on it for recovery.

For a terminal export instead, run these commands from the generated deployment directory:

1. Create the application backup and confirm success.

   ```sh
   docker compose exec -T tracearr node apps/server/scripts/backup.ts
   ```

2. Copy the backup workspace into the host config tree.

   ```sh
   umask 077
   mkdir -p config/tracearr/backups
   docker compose cp tracearr:/data/backup/. config/tracearr/backups/
   ```

3. Confirm an archive exists, then copy it and the matching private `.env` to your independent backup destination.

   ```sh
   ls -lh config/tracearr/backups/
   ```

The export commands use `config/tracearr/backups/` beneath the generated deployment. If you changed `CONFIG_PATH`, export beneath that host config tree to include the archive in your usual config backup. Duplicati also needs exported backups in its selected source paths. Restore through Tracearr's backup interface; do not copy live PostgreSQL files.

> [!CAUTION]
> `make delete-config` deletes the host config tree, including backup exports stored there. Keep a verified off-host backup and the matching private `.env`. Named-volume survival is not a substitute for an independent backup.

Watchtower can update Tracearr, but its database and Redis are excluded. Compose startup still follows the generated image pull policy and may update floating database tags. Review changes and export backups before updating; use exact image tags where needed.

## Optional repository helpers

From a Plundarr source checkout, the optional [repository helpers](quick-start.md#use-repository-helpers-later) provide equivalent service selection. These are separate examples:

```sh
make generate PRESET=plundarr REMOVE_SERVICES=tracearr ADD_SERVICES=tautulli
make generate PRESET=duplex ADD_SERVICES=tracearr
```

After exporting a Tracearr backup into the selected preset's host config tree, `make backup PRESET=plundarr` archives that tree. It does not dump databases, copy named volumes, or include `.env`; back up the matching private `.env` separately.
