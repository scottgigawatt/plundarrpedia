---
title: Pick a Route
description: Choose the shortest path into the Scott Gigawatt media projects.
icon: material/map-marker-path
---

# Pick a route

You do not need every service. Start with the outcome you want, choose the smallest maintained route, and add another component only when it solves a real problem.

<div class="grid cards" markdown>

-   **I want the complete automation stack**

    Use **Plundarr**. Maraudarr generates one `docker-compose.yml`, one `.env`,
    and the configuration directories for your selected services.

    [:material-arrow-right: Plundarr quick start](../projects/plundarr/quick-start.md)

-   **I need the Privateerr and Gluetun VPN lane**

    Use a VPN-enabled **Plundarr** preset for a complete deployment. Read the **Privateerr** guide when you need to understand or troubleshoot the generated PIA WireGuard handoff.

    [:material-arrow-right: Understand Privateerr](../projects/privateerr/index.md)

-   **I want a focused deployment**

    Choose a Plundarr preset for Boudoirr, Jellyfin, Plex, Calibre-Web Automated, Duplex, Watchtower, or a custom service selection.

    [:material-arrow-right: Compare presets](../projects/presets/index.md)

-   **I need a platform-specific route**

    Choose Linux Docker, Synology Container Manager, or TrueNAS Apps. The stack
    stays Compose-based while storage and permissions change by platform.

    [:material-arrow-right: Choose a harbor](../guides/index.md)

</div>

## A sane first voyage

1. Decide where downloads, libraries, and application state will live.
2. Confirm the Docker user can read and write those locations.
3. Generate Plundarr with only the services you actually plan to configure.
4. Edit `.env` before starting containers.
5. Start the VPN lane first and validate it before adding indexers and managers.
6. Add requests, playback, dashboards, and maintenance tools in layers.

!!! tip
    A smaller working stack is easier to reason about than a 20-container stack
    where every web UI is asking for its first-run setup at once.

## Before you launch

- [ ] Docker Engine and Docker Compose v2 are available.
- [ ] Host paths exist and have the intended owner/group.
- [ ] The chosen host ports are free.
- [ ] The Docker subnet does not overlap your LAN, VPN, or another Compose
      project.
- [ ] Secrets are in an ignored `.env`, never in `docker-compose.yml`.
- [ ] You have a backup plan for `config/`, not just the media library.
