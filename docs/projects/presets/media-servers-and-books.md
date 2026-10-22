---
title: Media Servers and Books
description: Generate focused Jellyfin, Plex, or Calibre-Web Automated deployments from Plundarr.
icon: material/book-open-page-variant
status: updated
---

# Media server and ebook presets

Plundarr can generate focused deployments when you need one media server or ebook service without the complete automation fleet. These presets keep their own `.env`, Compose file, network identity, and configuration tree under `dist/<preset>/`. Complete [generator setup](../plundarr/quick-start.md#choose-the-generator) before using the commands below.

## Jellyfin

Generate the standalone Jellyfin preset:

```sh
make ship PRESET=jellyfin
make config PRESET=jellyfin
make up PRESET=jellyfin
```

Jellyfin mounts one writable high-level media root at `/data`. Add `/data/movies` and `/data/tv` as libraries in Jellyfin, and keep its persistent `/config` and `/cache` directories in your backup plan. The default generated bridge network is `172.22.0.0/16`, and the example host port is `28096`.

## Customize Jellyfin Web and Vue

Maraudarr seeds preserved Jellyfin Web JSON and local styles under `config/jellyfin/web/`. `JELLYFIN_WEB_CONFIG_PATH` selects the complete JSON file, and `JELLYFIN_WEB_CUSTOM_PATH` selects the CSS/assets directory, both mounted read-only. External override paths must already exist and be readable. Validate the JSON for the selected Web version before recreating Jellyfin.

The `privacy-config.json` example omits Chromecast and YouTube players; it does not disable metadata providers or remote library images. The JSON mount does not activate CSS. To enable the bundled Boudoirr style, select **Dark** and add this to Jellyfin Web's **Dashboard → Branding → Custom CSS**:

```css
@import url("custom/boudoirr.css");
```

Local alternative styles and account-specific settings are covered in the [Jellyfin customization guide](https://scottgigawatt.github.io/plundarr/project-guides/jellyfin/). Web configuration/CSS do not customize Vue or all native clients. Check plugin compatibility against the selected server rather than installing every suggested extension.

The experimental Vue frontend is optional and does not force a local server:

```sh
make ship PRESET=jellyfin ADD_SERVICES=jellyfin-vue
```

It uses the upstream `unstable` channel and supports amd64/arm64, not arm/v7. The standalone Jellyfin preset exposes Vue on `28082`; Boudoirr uses `18082`. Set `JELLYFIN_VUE_DEFAULT_SERVERS` to browser-reachable URLs, or leave it empty for manual selection. Keep server selection enabled until that URL works. An HTTPS frontend requires an HTTPS Jellyfin URL; Docker service names and loopback addresses do not identify the server from a remote browser.

Keep Vue's seeded Nginx listener on internal port `8080`, its own image user, and writable startup configuration. It uses separate environment-generated frontend settings; its healthcheck proves static delivery, not server connectivity or playback. Read the [Vue chart](https://github.com/scottgigawatt/plundarr/blob/main/docker/services/jellyfin-vue/README.md) before changing those boundaries.

## Plex

Generate the standalone Plex preset:

```sh
make ship PRESET=plex
make config PRESET=plex
make up PRESET=plex
```

Plex uses host networking and separate read-only movie and television library mounts. Only one Plex server can normally claim the standard host ports, so stop or reconfigure an existing server before starting the preset.

## Calibre-Web Automated

Generate the focused ebook preset:

```sh
make ship PRESET=calibre-web-automated
make config PRESET=calibre-web-automated
make up PRESET=calibre-web-automated
```

Set `CWA_CONFIG_PATH`, `CWA_INGEST_PATH`, and `CWA_LIBRARY_PATH` to three separate host directories. The ingest directory is destructive: Calibre-Web Automated removes books after processing them. Finish downloads elsewhere and place only completed files in the ingest directory.

Back up the complete configuration directory and the Calibre library containing `metadata.db`. Set `CWA_NETWORK_SHARE_MODE=true` only when the library uses Network File System (NFS) or Server Message Block (SMB) storage.

> [!IMPORTANT]
> Calibre-Web Automated image releases can migrate persistent databases, so Plundarr excludes the service from Watchtower. Review and apply its image updates intentionally.

The service image currently supports `linux/amd64` and `linux/arm64`, not `linux/arm/v7`, even though Maraudarr itself publishes for all three platforms.

## Add services to another preset

Jellyfin, Plex, and Calibre-Web Automated are also selectable services. For example:

```sh
make ship ADD_SERVICES=plex
make ship PRESET=boudoirr REMOVE_SERVICES=velvarr
make ship REMOVE_SERVICES=calibre-web-automated
```

Use `make services` before generation to confirm the current catalog and dependency resolution.
