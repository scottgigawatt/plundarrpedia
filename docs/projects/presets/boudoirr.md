---
title: Boudoirr
description: Configure Whisparr, Velvarr requests, Jellyfin playback, and optional independent automation instances.
icon: material/heart
status: updated
---

# Boudoirr preset 💋

Boudoirr combines required Privateerr, Gluetun, FlareSolverr, Prowlarr, and Whisparr services. qBittorrent, Velvarr, Jellyfin, Cleanuparr, and Watchtower are removable defaults. Maraudarr writes the project under `dist/boudoirr/`.

## Generate and review the preset

Complete [generator setup](../plundarr/quick-start.md#choose-the-generator) first, then generate the default selection:

```sh
make ship PRESET=boudoirr
```

The official Velvarr image supports amd64 only. On arm64, omit Velvarr or select an independently verified compatible image; check every selected service before using arm/v7. To use an external Jellyfin server, omit only the local playback service:

```sh
make ship PRESET=boudoirr REMOVE_SERVICES=jellyfin
```

Use `REMOVE_SERVICES=velvarr,jellyfin` to omit both companions. For a Usenet-only downloader lane:

```sh
make ship PRESET=boudoirr REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=sabnzbd
```

Repeat the complete service selection on regeneration. Review PIA credentials, host paths, user/group IDs, ports, generated secrets, and [recovery settings](../privateerr/automatic-recovery.md) in `dist/boudoirr/.env`, then validate and launch:

```sh
make config PRESET=boudoirr
make up PRESET=boudoirr
make test-vpn PRESET=boudoirr
```

## Configure Whisparr libraries

Whisparr mounts persistent child directories below `/data`; the writable parent is temporary. Set `/data` as the root folder, use `movies/` and `scenes/` naming prefixes, set **Scene Import Folder Format** to `import`, and set **Recycling Bin** to `/data/recycle`. Keep durable files in the mounted children, not directly in the temporary parent.

Choose the movie metadata provider under **Settings → General → Movie metadata source** before importing. The fresh default is TMDB; TPDB is a separate choice, and scenes use StashDB. Directory names do not select a provider or convert existing records.

For an independent second instance:

```sh
make ship PRESET=boudoirr ADD_SERVICES=whisparr-alt
```

Whisparr Alt uses its own config, API key, libraries, recycle directory, download category, and host port (`16970` by default). Add it separately in Prowlarr at `http://whisparr-alt:6969`; the primary instance uses `http://whisparr:6969`. Process shared import staging through one instance at a time. Follow the [Whisparr Alt setup](https://github.com/scottgigawatt/plundarr/blob/main/docker/services/whisparr-alt/README.md) for provider and mount details.

## Complete Velvarr owner setup

Velvarr needs Jellyfin for owner setup and user authentication; Plex alone cannot provide that login. It connects over the network and does not force local Whisparr or Jellyfin containers.

1. Open the configured Velvarr browser address; Boudoirr defaults to host port `16699`. Read `VELVARR_SETUP_SECRET` locally from the private `.env` for first-run setup.
2. Connect Jellyfin with its account, API key, and intended libraries. Use `http://jellyfin:8096` inside this project or an address reachable from Velvarr for an external server.
3. Set Jellyfin's external playback URL to the address users open in their browsers, not its Docker service name.
4. Connect Whisparr with that instance's API key and review root folders, quality profiles, provider credentials, and path mappings.

The official default Velvarr image targets one Whisparr endpoint for TPDB movies and StashDB scenes, without TMDB movie discovery. Its movie target must therefore use TPDB, even though a fresh Whisparr defaults to TMDB. Do not assume a fork's multi-instance/provider features exist in the default image. See [Velvarr setup and image selection](https://scottgigawatt.github.io/plundarr/project-guides/velvarr/) before changing providers or image channels.

With default mounts, primary Whisparr's `/data/movies` corresponds to Jellyfin's `/data/movies/main`; Alt's corresponds to `/data/movies/alt`. Scene paths follow `/data/scenes/main` and `/data/scenes/alt`. Adjust mappings when host paths change; do not expose staging or recycle folders as playback libraries.

For an HTTPS reverse proxy, set `VELVARR_ORIGIN` to its exact browser origin, without a path or trailing slash. Preserve forwarded HTTPS scheme information. Keep `VELVARR_ALLOW_HTTP=1` when the internal Whisparr/Jellyfin addresses use private HTTP. Recreate Velvarr after environment changes. A healthy container proves an HTTP response, not completed owner setup or successful fulfillment.

## Choose the Jellyfin client

Jellyfin playback is selected by default. Its Web client supports preserved host-side JSON and local CSS; the separate Vue client is opt-in:

```sh
make ship PRESET=boudoirr ADD_SERVICES=jellyfin-vue
```

See [Jellyfin clients and customization](media-servers-and-books.md#customize-jellyfin-web-and-vue) for browser URLs, theme activation, privacy configuration, and client-specific limits. Plex is an optional additional service with host networking; it does not replace Jellyfin's role in Velvarr authentication.

## Back up requests and libraries

> [!IMPORTANT]
> Back up Velvarr's complete stopped SQLite directory, including journal/WAL files, with its matching `VELVARR_SECRET_KEY` from `.env`. The database backup does not contain that encryption key, and `make backup` does not include `.env`.

Keep recovery copies off-host and outside the config tree. Export each Whisparr instance's backup separately; stop it before raw file copies. Regeneration preserves state and secrets but does not stop omitted containers. Review [update and backup checks](../plundarr/upgrading.md) before pulling images or deleting host configuration.

[Open the shared configuration guide](../plundarr/configuration.md){ .md-button } [Troubleshoot the generated stack](../plundarr/troubleshooting.md){ .md-button .md-button--primary }
