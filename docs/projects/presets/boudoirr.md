---
title: Boudoirr
description: Configure Whisparr, Cruisarr requests, Jellyfin playback, and optional independent automation instances.
icon: material/heart
status: updated
---

# Boudoirr preset 💋

Boudoirr combines required Privateerr, Gluetun, FlareSolverr, Prowlarr, and Whisparr services. qBittorrent, Cruisarr, Jellyfin, Stash, Cleanuparr, and Watchtower are removable defaults. Maraudarr writes the project under `dist/boudoirr/`.

## Before you start

Choose **Boudoirr** in the [interactive generator](../plundarr/quick-start.md#1-open-the-interactive-generator). Review the requirements below before launch. The Make examples on this page are optional [repository helpers](../plundarr/quick-start.md#use-repository-helpers-later). For the default Cruisarr selection, you also need:

- An amd64 or arm64 host. Cruisarr does not support arm/v7.
- Access to Cruisarr's private GitHub Container Registry (GHCR) package and a personal access token (classic) with `read:packages`.
- A Jellyfin server, API key, and account with access to the intended libraries.
- Whisparr v3 and its API key. Prepare credentials for your selected metadata providers; TMDB discovery requires a TMDB API read access token, and scenes use StashDB.

Cruisarr connects to Jellyfin and Whisparr over the network. They can run in this project or on another reachable host. Plex alone cannot provide Cruisarr's Jellyfin login.

## Generate and review the preset

In the picker, keep or deselect Cruisarr, Jellyfin, and Stash independently. From an optional Plundarr checkout, the equivalent default generation is:

```sh
make generate PRESET=boudoirr
```

To use an external Jellyfin server, omit only the local playback service:

```sh
make generate PRESET=boudoirr REMOVE_SERVICES=jellyfin
```

Use `REMOVE_SERVICES=cruisarr,jellyfin` to omit requests and the local Jellyfin server while retaining Stash. For a Usenet-only downloader lane:

```sh
make generate PRESET=boudoirr REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=sabnzbd
```

Repeat the complete service selection on regeneration. Review PIA credentials, host paths, user/group IDs, ports, generated secrets, and [recovery settings](../privateerr/automatic-recovery.md) in `dist/boudoirr/.env`, then validate:

```sh
docker compose --project-directory dist/boudoirr config --quiet
```

## Configure Whisparr libraries

Whisparr mounts persistent child directories below `/data`; the writable parent is temporary. Set `/data` as the root folder, use `movies/` and `scenes/` naming prefixes, set **Scene Import Folder Format** to `import`, and set **Recycling Bin** to `/data/recycle`. Keep durable files in the mounted children, not directly in the temporary parent.

Choose the movie metadata provider under **Settings → General → Movie metadata source** before importing. The fresh default is TMDB; TPDB is a separate choice, and scenes use StashDB. Directory names do not select a provider or convert existing records.

For an independent second instance:

```sh
make generate PRESET=boudoirr ADD_SERVICES=whisparr-alt
```

Whisparr Alt uses its own config, API key, libraries, recycle directory, download category, and host port (`16970` by default). Add it separately in Prowlarr at `http://whisparr-alt:6969`; the primary instance uses `http://whisparr:6969`. Process shared import staging through one instance at a time. Follow the [Whisparr Alt setup](https://github.com/scottgigawatt/plundarr/blob/main/docker/services/whisparr-alt/README.md) for provider and mount details.

## Prepare Cruisarr storage and image access

Maraudarr generates `CRUISARR_SETUP_SECRET` and `CRUISARR_SECRET_KEY` in the private `.env` and preserves them on regeneration. Keep both private. `CRUISARR_CONFIG_PATH` defaults to `./config/cruisarr`, mounted at `/data` for SQLite state and encrypted settings. Cruisarr needs no media or download mounts.

The container runs as `DEFAULT_PUID:DEFAULT_PGID` with `DEFAULT_GROUP`. Give that host identity write access to the configured data directory before launch. Startup does not change existing ownership. Runtime `CRUISARR_UID` or `CRUISARR_GID` variables do not change the process identity.

On the deployment host, authenticate before pulling the private image:

```sh
docker login ghcr.io
```

Enter your GitHub username and use the token as the password. Confirm `Login Succeeded`. Keep the token out of `.env`, Compose files, commands, and logs. Synology Container Manager also needs authenticated registry access on the NAS; a workstation login does not authenticate it.

Keep `CRUISARR_IMAGE` as the repository and `CRUISARR_TAG` as the separate image tag. The defaults select `ghcr.io/scottgigawatt/cruisarr:latest`. See [private-image access](https://github.com/scottgigawatt/cruisarr/blob/main/docs/operations/private-images.md) for package permissions.

For an HTTPS reverse proxy, set `CRUISARR_ORIGIN` to the exact browser origin, without a path or trailing slash, and forward the HTTPS scheme. For example:

```sh
CRUISARR_ORIGIN="https://cruisarr.example.com"
```

Keep `CRUISARR_ALLOW_HTTP=1` when Whisparr or Jellyfin uses private HTTP. Cruisarr's saved **Allow private HTTP** setting overrides this fallback. Recreate the container after changing environment values; a restart does not reload them.

## Complete Cruisarr owner setup

1. Launch the reviewed project and check status:

    ```sh
    docker compose --project-directory dist/boudoirr up --detach --pull always
    docker compose --project-directory dist/boudoirr ps
    ```

2. Confirm the VPN is healthy in local Privateerr/Gluetun logs, then open Cruisarr at the configured browser address. Boudoirr defaults to host port `16699`; the internal port is `6699`. Read `CRUISARR_SETUP_SECRET` locally from `.env` for first-run setup.
3. Connect Jellyfin with your account, API key, and intended libraries. Use `http://jellyfin:8096` inside this project or an address reachable from Cruisarr for an external server.
4. Set Jellyfin's external playback URL to the address users open in their browsers.
5. Connect Whisparr at `http://whisparr:6969` with its API key. Add an optional Alt instance at `http://whisparr-alt:6969` with its own key.
6. Match each connection's movie provider to that Whisparr instance. Cruisarr supports TPDB and TMDB movies, StashDB scenes, and multiple Whisparr connections. Choose the default scene instance and configure provider credentials, root folders, quality profiles, and path mappings.
7. Admit the intended Jellyfin users and test sign-in. Submit representative movie and scene requests, confirm the intended Whisparr receives them, and verify playback after fulfillment.

With default mounts, primary Whisparr's `/data/movies` corresponds to Jellyfin's `/data/movies/main`; Alt's corresponds to `/data/movies/alt`. Scene paths follow `/data/scenes/main` and `/data/scenes/alt`. Adjust mappings when host paths change; do not expose staging or recycle folders as playback libraries.

A healthy Cruisarr container confirms application storage access. It does not verify owner setup, sign-in, provider connections, or fulfillment. If it stays unhealthy, check data-directory permissions and inspect logs locally. For `unauthorized` or `denied` pulls, check package access and registry authentication on the deployment host. A missing matching manifest requires checking the architecture and selected tag. Redact secrets before sharing diagnostics.

When Homepage is selected, Maraudarr adds a Cruisarr link card. Set `HOMEPAGE_VAR_CRUISARR_HREF` to the browser address; the internal service address is not a browser URL.

## Add Stash cataloging

Stash is independently removable in the interactive picker. It uses the same media root as Jellyfin, mounted read-only at `/data`. Only the creators directory at `/data/scenes/creators` and the recycle directory at `/data/recycle/stash` are writable; Whisparr-managed media stays protected.

Before launch, set `STASH_DATA_PATH` to your media root, `STASH_CREATORS_PATH` to that root's existing `scenes/creators` child, and `STASH_RECYCLE_PATH` to its `recycle/stash` directory. Grant the configured user/group the intended access. Docker can create the recycle directory, but its host ownership still needs to permit writes. Stash's separate config/database, metadata, images, cache, and previews live under `config/stash/` by default.

Open `http://YOUR-HOST:19999` for Boudoirr's default Stash port. Create an account, scan only your intended video libraries, and set the recycle-bin directory to `/data/recycle/stash`, outside scanned libraries. Try a small scan and playback sample before bulk preview generation. Identification through StashDB needs a separate account/API key; simply enabling Stash does not import existing NFO metadata.

Jellyfin integrations can use `http://stash:9999` in this project. Both applications see the same `/data` paths. Whisparr sees different child paths; do not enable scan/cleanup notifications with an unverified mapping. Scan Stash again after Whisparr moves or renames files.

Use [Stash setup and backup](https://scottgigawatt.github.io/plundarr/project-guides/stash/) for optional integrations and recovery. Export a Stash database backup before archiving its surrounding stopped application state; media, external paths, and `.env` need separate backups. Cache and previews can be regenerated.

## Choose the Jellyfin client

Jellyfin playback is selected by default. Its Web client supports preserved host-side JSON and local CSS; the separate Vue client is opt-in:

```sh
make generate PRESET=boudoirr ADD_SERVICES=jellyfin-vue
```

See [Jellyfin clients and customization](media-servers-and-books.md#customize-jellyfin-web-and-vue) for browser URLs, theme activation, privacy configuration, and client-specific limits. Plex is an optional additional service with host networking; Cruisarr still requires Jellyfin for sign-in.

## Back up requests and libraries

> [!IMPORTANT]
> Back up Cruisarr's complete stopped data directory, including SQLite journal or write-ahead log files, with its matching `CRUISARR_SECRET_KEY` from `.env`. Losing the matching key prevents recovery of encrypted credentials. `make backup` does not include `.env` or data outside the selected config tree.

Cruisarr is excluded from Watchtower because the watcher has no private-registry credentials. Before an intentional update, stop Cruisarr, copy its complete data directory and matching key, then start it again. With an authenticated deployment account, pull and recreate Cruisarr:

```sh
docker compose --project-directory dist/boudoirr pull cruisarr
docker compose --project-directory dist/boudoirr up -d cruisarr
```

Repeat the sign-in, connection, and request checks after updating. To recover, stop Cruisarr, restore into fresh storage, point `CRUISARR_CONFIG_PATH` at it, restore the matching key and permissions, then recreate and verify the service. Keep the original data until recovery is verified. See [Cruisarr backup and recovery](https://github.com/scottgigawatt/cruisarr/blob/main/docs/operations/setup-and-configuration.md#backup-and-recovery) for application details.

Keep recovery copies off-host and outside the config tree. Export each Whisparr instance's backup separately; stop it before raw file copies. Regeneration preserves state and secrets but does not stop omitted containers. Review [update and backup checks](../plundarr/upgrading.md) before pulling images or deleting host configuration.

[Open the shared configuration guide](../plundarr/configuration.md){ .md-button } [Troubleshoot the generated stack](../plundarr/troubleshooting.md){ .md-button .md-button--primary }
