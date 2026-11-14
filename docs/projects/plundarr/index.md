---
title: About Plundarr
description: Generate one editable Docker Compose project from the services you choose.
icon: material/pirate
---

# Plundarr

Plundarr is a generated media stack: one commented `docker-compose.yml`, a matching `.env`, and configuration directories. **Maraudarr** is the interactive generator image that creates those files and exits. Docker Compose or Synology Container Manager runs the resulting applications.

[Generate and start Plundarr](quick-start.md){ .md-button .md-button--primary }

## Start small, then expand

The default preset includes VPN-protected downloads, Radarr/Sonarr automation, requests, monitoring, ebooks, and Homepage. Plex and Jellyfin are optional. [Other presets](../presets/index.md) provide focused media servers, books, or utilities from the same service catalog.

You edit the generated `.env` before launch. Maraudarr preserves existing environment values and application state when you regenerate; it does not configure every application for you. After startup, [connect your applications](connect-applications.md).

Use [configuration](configuration.md), [updates and backups](upgrading.md), or [troubleshooting](troubleshooting.md) for the task you need. [Developer documentation](https://scottgigawatt.github.io/plundarr/development/maraudarr/) covers source builds, architecture, service extensions, and the Python reference.
