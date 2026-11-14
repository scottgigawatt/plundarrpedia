---
title: Start here
description: Run a working VPN download stack, then generate and expand your media stack.
icon: material/map
---

# Start your media stack

Run Privateerr with Gluetun and qBittorrent, or generate the larger Plundarr stack through Maraudarr's interactive terminal. These guides start with published images; building source is optional.

<div class="grid cards" markdown>

-   :material-shield-key:{ .lg .middle } **Start with Privateerr**

    ---

    Run three containers: Privateerr prepares the VPN settings, Gluetun runs the tunnel, and qBittorrent downloads through it.

    [:octicons-arrow-right-24: Start the VPN download stack](projects/privateerr/quick-start.md)

-   :material-ship-wheel:{ .lg .middle } **Generate Plundarr**

    ---

    Choose your services interactively, edit the generated settings, and start a complete media automation stack.

    [:octicons-arrow-right-24: Generate and launch Plundarr](projects/plundarr/quick-start.md)

</div>

Already running? [Connect your applications](projects/plundarr/connect-applications.md), [add a preset](projects/presets/index.md), or [update and back up your deployment](projects/plundarr/upgrading.md).

## What you need

Use Docker with Compose v2, private storage for settings, and an active Private Internet Access (PIA) subscription for the VPN-enabled routes. The default three-container and Plundarr stacks need an amd64 or arm64 host. Know where your media and downloads should live; each quick start identifies the values to change.

For NAS deployment, use the [Synology or TrueNAS guide](guides/index.md) at the deployment step. You can generate a stack on a workstation and transfer it to the NAS.

[See how the containers connect](start-here/architecture.md). Privateerr prepares configuration and can recover stale VPN connections; Gluetun carries VPN traffic.
