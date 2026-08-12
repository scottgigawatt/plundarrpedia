---
title: Choose a Harbor
description: Match Plundarr and the media fleet to Linux Docker, Synology, or TrueNAS.
icon: material/ferry
---

# Choose a harbor

Plundarr generates an ordinary Docker Compose project. The applications do not
care whether the Docker Engine lives on a Linux server or inside a NAS product.
The harbor changes how you prepare storage, grant permissions, enter Compose
configuration, and expose the VPN device.

| Platform | Best fit | Pay closest attention to |
| --- | --- | --- |
| Linux Docker | Direct control and standard Docker tooling | Ownership, firewall rules, and durable mount paths |
| Synology DSM | Media and containers on one Synology NAS | Shared-folder paths, Container Manager projects, and Task Scheduler |
| TrueNAS | ZFS-first media storage with Docker-based Apps | Dataset layout, ACL entries, YAML deployment, and `/dev/net/tun` |

!!! tip
    Generate the Plundarr project before translating it to a platform UI. The
    final `docker-compose.yml` and matching `.env` are the deployment artifact;
    the source modules are not.

## What stays the same

Every platform needs the same foundations:

1. Stable host paths for downloads, libraries, and application state.
2. Numeric users and groups that can access those paths.
3. A non-overlapping Docker subnet.
4. `/dev/net/tun` and `NET_ADMIN` for Gluetun.
5. Published download-client ports on Gluetun when services share its network
   namespace.
6. A VPN validation run before indexers and media managers are configured.

## Pick the platform guide

<div class="grid cards" markdown>

-   :material-linux:{ .lg .middle } **Linux and ordinary Docker**

    ---

    Use the normal Compose CLI with `/srv`, `/mnt`, or another deliberate host
    path layout.

    [:octicons-arrow-right-24: Open the Docker guide](docker.md)

-   :material-nas:{ .lg .middle } **Synology**

    ---

    Keep the complete generated project in a shared folder and deploy it as a
    Container Manager project.

    [:octicons-arrow-right-24: Open the Synology guide](synology.md)

-   :material-server-network:{ .lg .middle } **TrueNAS**

    ---

    Prepare ZFS datasets and ACLs first, render the Compose model, then install
    it through the custom YAML editor.

    [:octicons-arrow-right-24: Open the TrueNAS guide](truenas.md)

</div>
