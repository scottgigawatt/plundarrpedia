---
title: Duplex
description: A Docker Compose utility stack for curating, cleaning, monitoring, and maintaining Plex.
icon: material/television-classic
---

# Duplex 📺

Duplex is the backstage crew for an existing Plex Media Server. Plundarr focuses
on discovery, downloading, and library management; Duplex focuses on what
happens around Plex after the media is there.

## The cast

| Tool          | Job                                                                                 |
| ------------- | ----------------------------------------------------------------------------------- |
| Kometa        | Builds collections, applies metadata, and manages overlays from YAML configuration. |
| ImageMaid     | Cleans Plex image assets and cache state.                                           |
| Overlay Reset | Removes overlays when a clean slate is needed.                                      |
| PATTRMM       | Builds time-aware collections such as returning-soon or historical views.           |
| Tautulli      | Records activity and exposes Plex usage analytics.                                  |
| Notifiarr     | Delivers application and system notifications.                                      |
| Watchtower    | Handles selected container update policy.                                           |

The Kometa configuration lives in the separate
[`kometa-config`](https://github.com/scottgigawatt/kometa-config) repository and
is included as a submodule.

## Quick start

```console
git clone --recurse-submodules \
  https://github.com/scottgigawatt/duplex.git
cd duplex
cp example.env .env
cp config/imagemaid/example.env config/imagemaid/.env
```

Review both environment files, host paths, Plex URL/token values, and the
Compose network before launch:

```console
docker compose config
docker compose up -d
```

## Platform notes

Duplex is written with Synology in mind but uses standard Docker Compose. On a
generic Linux host:

- replace `/volume*` examples with real absolute paths;
- ensure the configured user/group can access Plex data and utility config;
- check the selected images support your CPU architecture;
- preserve the Kometa submodule when cloning or updating;
- avoid giving maintenance tools broader write access than they need.

## Relationship to Plundarr

Duplex can remain a separate Compose project. It does not need to share
Plundarr's VPN namespace or download paths. It primarily needs network access to
Plex and carefully scoped mounts for the maintenance tools you enable.

[View Duplex on GitHub](https://github.com/scottgigawatt/duplex){ .md-button }
