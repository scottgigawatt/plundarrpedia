---
title: Media Servers and Books
description: Generate focused Jellyfin, Plex, or Calibre-Web Automated deployments from Plundarr.
icon: material/book-open-page-variant
status: updated
---

# Media server and ebook presets

Plundarr can generate focused deployments when you need one media server or ebook service without the complete automation fleet. These presets keep their own `.env`, Compose file, network identity, and configuration tree under `dist/<preset>/`. Choose the desired preset in the [interactive generator](../plundarr/quick-start.md#1-open-the-interactive-generator), edit its `.env`, then use the commands below from the parent directory containing `dist/`.

In the browser addresses below, replace `YOUR-HOST` with your Docker host's address. Use the host port in the generated `.env` if you changed it.

## Jellyfin

After choosing Jellyfin and reviewing its `.env`, validate and start:

```sh
docker compose --project-directory dist/jellyfin config --quiet
docker compose --project-directory dist/jellyfin up --detach --pull always
```

1. Open `http://YOUR-HOST:28096`, the standalone preset's default `JELLYFIN_WEBUI_PORT`. Complete the [Jellyfin setup wizard](https://jellyfin.org/docs/general/post-install/setup-wizard/) to create an administrator account with a strong password and add your media libraries.
2. Use the container paths `/data/movies` and `/data/tv` for the corresponding libraries beneath `JELLYFIN_DATA_PATH`. Finish the wizard, sign in, and play a sample item to confirm that Jellyfin can read your media.

Jellyfin mounts one writable high-level media root at `/data`. Keep its persistent `/config` and `/cache` directories in your backup plan. The default generated bridge network is `172.22.0.0/16`.

## Customize Jellyfin Web and Vue

Maraudarr seeds preserved Jellyfin Web JSON and local styles under `config/jellyfin/web/`. `JELLYFIN_WEB_CONFIG_PATH` selects the complete JSON file, and `JELLYFIN_WEB_CUSTOM_PATH` selects the CSS/assets directory, both mounted read-only. External override paths must already exist and be readable. Validate the JSON for the selected Web version before recreating Jellyfin.

The `privacy-config.json` example omits Chromecast and YouTube players; it does not disable metadata providers or remote library images. The JSON mount does not activate CSS. To enable the bundled Boudoirr style, select **Dark** and add this to Jellyfin Web's **Dashboard → Branding → Custom CSS**:

```css
@import url("custom/boudoirr.css");
```

Local alternative styles and account-specific settings are covered in the [Jellyfin customization guide](https://scottgigawatt.github.io/plundarr/project-guides/jellyfin/). Web configuration/CSS do not customize Vue or all native clients. Check plugin compatibility against the selected server rather than installing every suggested extension.

The experimental Vue frontend is optional and does not force a local server. Select it in the picker, or use the optional [repository helpers](../plundarr/quick-start.md#use-repository-helpers-later):

```sh
make generate PRESET=jellyfin ADD_SERVICES=jellyfin-vue
```

It uses the upstream `unstable` channel and supports amd64/arm64, not arm/v7. The standalone Jellyfin preset exposes Vue on `28082`; Boudoirr uses `18082`. Set `JELLYFIN_VUE_DEFAULT_SERVERS` to browser-reachable URLs, or leave it empty for manual selection. Keep server selection enabled until that URL works. An HTTPS frontend requires an HTTPS Jellyfin URL; Docker service names and loopback addresses do not identify the server from a remote browser.

Keep Vue's seeded Nginx listener on internal port `8080`, its own image user, and writable startup configuration. It uses separate environment-generated frontend settings; its healthcheck proves static delivery, not server connectivity or playback. Read the [Vue chart](https://github.com/scottgigawatt/plundarr/blob/main/docker/services/jellyfin-vue/README.md) before changing those boundaries.

## Plex

Plex uses host networking and read-only media mounts. Only one Plex server can normally claim the standard host ports, so stop or reconfigure an existing server before starting the preset. For automatic account claiming, optionally set `PLEX_CLAIM` to a fresh token from [Plex's claim page](https://plex.tv/claim) immediately before the first launch; tokens expire after four minutes. Keep the token private and clear it from `.env` after the server is claimed. See the [selected Plex image's setup guidance](https://docs.linuxserver.io/images/docker-plex/).

After choosing Plex and reviewing its `.env`, validate and start:

```sh
docker compose --project-directory dist/plex config --quiet
docker compose --project-directory dist/plex up --detach --pull always
```

1. From a browser on the same local network, open `http://YOUR-HOST:32400/web`, sign in to your Plex account, and complete the server setup. For initial setup from another network, follow [Plex's installation instructions](https://support.plex.tv/articles/200288586-installation/).
2. Add `/movies` and `/tv` as the corresponding libraries, then play a sample item to confirm that Plex can read your media.

## Calibre-Web Automated

Set `CWA_CONFIG_PATH`, `CWA_INGEST_PATH`, and `CWA_LIBRARY_PATH` to three separate writable host directories. For a new library, choose an empty library directory; CWA creates and registers the library automatically. For an existing library, point `CWA_LIBRARY_PATH` at the Calibre library directory containing `metadata.db`. See [CWA library setup](https://github.com/crocodilestick/Calibre-Web-Automated/blob/main/README.md#library-auto-detect).

The ingest directory is destructive: Calibre-Web Automated removes books after processing them. Finish downloads elsewhere and place only completed files in the ingest directory. Set `CWA_NETWORK_SHARE_MODE=true` only when the configuration or library uses Network File System (NFS) or Server Message Block (SMB) storage.

The service image supports `linux/amd64` and `linux/arm64`, not `linux/arm/v7`, even though Maraudarr itself publishes for all three platforms.

After choosing Calibre-Web Automated in the generator and reviewing these paths, validate and start:

```sh
docker compose --project-directory dist/calibre-web-automated config --quiet
docker compose --project-directory dist/calibre-web-automated up --detach --pull always
```

1. Open `http://YOUR-HOST:48213`, the standalone preset's default `CWA_WEBUI_PORT`. On a new installation, sign in with the upstream [default administrator login](https://github.com/crocodilestick/Calibre-Web-Automated/blob/main/README.md#default-admin-login): username `admin` and password `admin123`. Change the password immediately.
2. Confirm that CWA has registered the library at `/calibre-library`. Copy a completed test ebook into the host directory set by `CWA_INGEST_PATH`, keeping the original elsewhere. Wait for the imported book to appear in the library and open or download it to confirm success.

Back up the complete configuration directory and Calibre library, including its `metadata.db` database and books.

> [!IMPORTANT]
> Calibre-Web Automated image releases can migrate persistent databases, so Plundarr excludes the service from Watchtower. Review and apply its image updates intentionally.

## Add services to another preset

Jellyfin, Plex, and Calibre-Web Automated are also selectable services. Select them in the picker, or from a source checkout use these independent examples:

```sh
make generate ADD_SERVICES=plex
make generate PRESET=boudoirr REMOVE_SERVICES=cruisarr
make generate REMOVE_SERVICES=calibre-web-automated
```

Use `make services` before generation to confirm the current catalog and dependency resolution.
