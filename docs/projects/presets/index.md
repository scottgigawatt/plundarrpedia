---
title: Choose a preset
description: Choose a focused media server, automation stack, or utility project.
icon: material/view-grid-plus
---

# Choose a preset

A preset is a starting service selection in Maraudarr. Choose it in the [interactive generator](../plundarr/quick-start.md#1-open-the-interactive-generator), adjust optional services, and review the final selection. Each project gets its own `dist/<preset>/` directory.

| 🗺️ Preset | 🎯 Use it for | ✅ Before launch |
| --- | --- | --- |
| 🏴‍☠️ `plundarr` | Movies, television, ebooks, requests, monitoring, and VPN downloads | [Default quick start](../plundarr/quick-start.md) |
| 🔞 `boudoirr` | Whisparr automation, requests, Jellyfin playback, and Stash cataloging | [Boudoirr setup](boudoirr.md); Cruisarr requires private-image access |
| 🎞️ `jellyfin`, 📺 `plex` | One media server | [Media server setup](media-servers-and-books.md) |
| 📚 `calibre-web-automated` | Ebook library and ingest | [Book paths and ingest behavior](media-servers-and-books.md#calibre-web-automated) |
| 🎭 `duplex` | Plex curation and Plex/Jellyfin theme songs | [External configuration and keys](duplex.md) |
| 🔭 `watchtower` | Deliberate container image updates | [Host update policy](watchtower.md) |
| 🚢 `portainer` | Docker host management | [Administrator access](portainer.md) |
| 🧩 `custom` | Your own service selection | Review dependencies and each selected service |

Required core services stay selected. Removable defaults start checked, and optional services start unchecked. Maraudarr adds required companions and shows the result before generating files. Generator platform support does not guarantee that every application supports your host.

## Launch a focused project

Choose your preset and generate it. Open its `.env`, edit the indicated host settings, and prepare any service-specific files from its guide. From the generated directory containing `docker-compose.yml`:

```sh
docker compose config --quiet
docker compose up --detach --pull always
docker compose ps
```

For Synology or TrueNAS, transfer the complete generated directory and use the [platform procedure](../../guides/index.md) instead of launching another copy locally.

## Use repository helpers

After [setting up the optional Git/Make route](../plundarr/quick-start.md#use-repository-helpers-later), you can inspect the selected image's catalog and generate directly:

```sh
make presets
make services
make generate PRESET=boudoirr
```

`ADD_SERVICES` and `REMOVE_SERVICES` accept comma-separated service IDs. For example:

```sh
make generate PRESET=plundarr REMOVE_SERVICES=qbittorrent,cleanuparr ADD_SERVICES=nzbget
```

Repeat your complete service selection on regeneration; saved `.env` values do not reselect services. Regeneration preserves application state, but does not stop omitted containers or move external data. Follow [updates and backups](../plundarr/upgrading.md) before changing an existing project.

## Run projects side by side

Presets have distinct project names, networks, and some offset host ports. Review the generated ports and subnet before launch; defaults do not reserve resources on your host. Plex uses host networking. Run only one persistent Watchtower per Docker host, and never run two applications against the same database files.
