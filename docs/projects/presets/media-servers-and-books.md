---
title: Media Servers and Books
description: Generate focused Jellyfin, Plex, or Calibre-Web Automated deployments from Plundarr.
icon: material/book-open-page-variant
status: updated
---

# Media server and ebook presets

Plundarr can generate focused deployments when you need one media server or ebook service without the complete automation fleet. These presets keep their own `.env`, Compose file, network identity, and configuration tree under `dist/<preset>/`.

## Jellyfin

Generate the standalone Jellyfin preset:

```sh
make ship PRESET=jellyfin
make config PRESET=jellyfin
make up PRESET=jellyfin
```

Jellyfin mounts one writable high-level media root at `/data`. Add `/data/movies` and `/data/tv` as libraries in Jellyfin, and keep its persistent `/config` and `/cache` directories in your backup plan. The default generated bridge network is `172.22.0.0/16`, and the example host port is `28096`.

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

!!! important
    Calibre-Web Automated image releases can migrate persistent databases, so Plundarr excludes the service from Watchtower. Review and apply its image updates intentionally.

The service image currently supports `linux/amd64` and `linux/arm64`, not `linux/arm/v7`, even though Maraudarr itself publishes for all three platforms.

## Add services to another preset

Jellyfin, Plex, and Calibre-Web Automated are also selectable services. For example:

```sh
make ship ADD_SERVICES=plex
make ship PRESET=boudoirr ADD_SERVICES=jellyfin
make ship REMOVE_SERVICES=calibre-web-automated
```

Use `make services` before generation to confirm the current catalog and dependency resolution.
