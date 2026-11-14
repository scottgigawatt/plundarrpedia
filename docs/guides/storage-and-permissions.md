---
title: Paths and permissions
description: Prepare shared download paths, library permissions, and complete application backups.
icon: material/folder-key-network
---

# Paths and permissions

A downloader and media manager must agree where the same file lives inside their containers. Host paths choose storage; container paths are what applications report to one another.

## Use matching download paths

In the generated default stack, qBittorrent sees `/downloads/torrents` and Radarr/Sonarr see the parent `/downloads`. Set `HOST_TORRENTS_DOWNLOADS_PATH` to the `torrents` child of `HOST_DOWNLOADS_PATH`. A completed file then has the same `/downloads/torrents/...` path in each application.

Radarr imports into `/movies`; Sonarr imports into `/tv`. Keep final libraries out of incomplete downloads. [Connect your applications](../projects/plundarr/connect-applications.md) after the containers start.

## Understand hardlinks

The default generated download and library paths are separate bind mounts, so imports between them use copies. Storing both host directories on one disk alone does not enable hardlinks across those container mounts.

A custom hardlink layout needs downloads and libraries under one shared container mount and on one host filesystem. ZFS child datasets are separate filesystems. Design and verify that layout deliberately; it changes paths and mounts beyond the default quick start.

## Set numeric permissions

Use `id` for the host account that owns the folders. Match the generated user/group settings and give each service the access it needs:

- Download clients write downloads.
- Managers read downloads and write their own final libraries.
- Plex reads libraries; generated Jellyfin has a writable `/data` root.
- Privateerr writes the shared Gluetun configuration directory.
- Stash's shared media is read-only except its explicit creators and recycle mounts.
- Backup tools need access to selected sources and a protected destination.

A `:rw` mount does not override host permissions. On Synology or TrueNAS, check ACLs and mapped container identities too. On SELinux hosts, use the distribution's supported `:z`/`:Z` labeling for shared or private container mounts rather than changing Unix modes blindly.

## Back up durable state

Save configuration, application-created database exports, private `.env`, encryption keys, and external state. Tracearr's database and backup workspace use named volumes; export a [Tracearr application backup](../projects/plundarr/monitoring.md#back-up-and-update) before archiving host config. Back up external Kometa/Plex state separately.

A host config archive does not replace database or volume backups. Caches, transcodes, and generated previews can usually be rebuilt. Keep an independent off-host copy and verify recovery before deleting originals.
