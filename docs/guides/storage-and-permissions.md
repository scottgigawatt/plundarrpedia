---
title: Paths and Permissions
description: Design mounts that support imports, hardlinks, backups, and least privilege.
icon: material/folder-key-network
---

# Paths and permissions

Most apparently mysterious media automation failures are ordinary filesystem
problems with better costumes.

## Use a shared path vocabulary

```yaml
services:
  qbittorrent:
    volumes:
      - /srv/media/downloads:/downloads
  radarr:
    volumes:
      - /srv/media/downloads:/downloads
      - /srv/media/movies:/movies
```

The download client and Radarr agree that the same file is under `/downloads`.
No remote-path translation is needed.

## Understand hardlinks

Hardlinks require the source and destination to live on the same filesystem.
If downloads and the movie library are separate mounts/filesystems, Radarr may
copy instead of hardlinking. A common alternative is one shared host root:

```text
/srv/media
├── downloads
├── movies
└── tv
```

mounted as `/data` in relevant containers, with application-specific subpaths.
Choose one model and use it consistently.

## Numeric identity

Container images often accept `PUID` and `PGID`. Those values must correspond to
host ownership; a username inside one container does not grant host access by
magic.

```console
id media
stat -c '%u:%g %a %n' /srv/media/downloads /srv/media/movies
```

On BSD/macOS, use that platform's equivalent `stat` options.

## Least privilege

- Download clients need write access to downloads, not final libraries.
- Radarr/Sonarr need downloads plus their own final libraries.
- Plex/Jellyfin normally need read access to libraries and write access only to
  their own configuration/transcode locations.
- Privateerr needs write access to the shared Gluetun configuration directory.
- Backup tools need deliberate read access and a separately protected
  destination.

## SELinux hosts

On SELinux-enforcing distributions, normal Unix ownership can look correct while
the security label blocks the container. Use your distribution's supported
container volume labeling (`:z`/`:Z` where appropriate) and understand whether
the directory is shared between multiple services before relabeling it.

## Back up state, not caches

Prioritize application databases, configuration, `.env` through a secret-safe
path, custom scripts, and generated Compose inputs. Exclude disposable image
caches, transcode directories, package caches, and ordinary logs unless they
serve a specific audit need.
