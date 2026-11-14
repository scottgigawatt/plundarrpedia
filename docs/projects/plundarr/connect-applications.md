---
title: Connect your applications
description: Connect the default downloader, indexers, and media managers after Plundarr starts.
icon: material/connection
---

# Connect your applications

Start here after the [Plundarr quick start](quick-start.md). Containers running does not yet mean the applications know about one another. Connect them in this order and use each application's **Test** button before continuing.

## 1. Confirm storage and qBittorrent

Sign in to qBittorrent. Keep its download directory under `/downloads/torrents`. Radarr and Sonarr mount the parent `/downloads`; ensure `HOST_TORRENTS_DOWNLOADS_PATH` is the `torrents` child of `HOST_DOWNLOADS_PATH` on the host. Both applications must see a downloaded file at the same container path.

Use `/movies` as Radarr's root folder and `/tv` as Sonarr's root folder. These are final libraries, separate from downloads. Confirm each manager can write to its library before importing files. See [paths and permissions](../../guides/storage-and-permissions.md) if a path is missing or an import fails.

## 2. Connect Radarr and Sonarr to qBittorrent

In each manager, open **Settings → Download Clients**, add qBittorrent, and enter its credentials. For the default generated project:

| Setting | Value |
| --- | --- |
| Host | `gluetun` |
| Port | `8080`, or your `QBITTORRENT_WEBUI_PORT` |
| SSL | Off for this internal HTTP connection |
| Category | `radarr` in Radarr; `sonarr` in Sonarr |

Use **Test**, then save. Applications inside Docker use the service hostname; your browser uses the host address. `localhost` inside Radarr means Radarr itself. qBittorrent shares Gluetun's network, which is why its host is `gluetun` here.

## 3. Connect indexers through Prowlarr

In Prowlarr, add only indexers you are authorized to use and test each connection. FlareSolverr is available for supported indexers that need it; it is not required for every indexer.

Under **Settings → Apps**, add Radarr at `http://radarr:7878` and Sonarr at `http://sonarr:8989`. Copy each manager's API key from its own **Settings → General** page. Use `http://prowlarr:9696` as Prowlarr's server address when requested. Test and save the connections, then confirm the indexers appear in each manager.

## 4. Try one complete workflow

In Radarr or Sonarr, choose a root folder and quality profile, add a title you are authorized to download, and start one small test. Confirm that the download reaches qBittorrent, completes, and imports into the final library. Do not change several apps at once if a step fails; use [download/import troubleshooting](troubleshooting.md#downloads-finish-but-never-import).

The default Plundarr preset does not include Plex or Jellyfin. If you selected a [media server](../presets/media-servers-and-books.md), add the final library there and confirm playback. Keep incomplete download folders out of playback libraries.

## Add requests and dashboard widgets

Once direct downloads and imports work, connect Seerr to your media server and managers through its setup wizard. Configure Bazarr for subtitles and [Tracearr](monitoring.md) for monitoring afterward.

Homepage browser links use `HOMEPAGE_VAR_*_HREF`; widget connections use `HOMEPAGE_VAR_*_URL` and the application's API key. Set browser links to addresses reachable from your computer and widget URLs to addresses reachable from Homepage's container. Recreate Homepage after changing `.env`. See [Homepage configuration](homepage.md) for login and customization.
