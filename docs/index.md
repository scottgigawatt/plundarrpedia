---
title: Chart Room
description: One harbor for Plundarr, Privateerr, Duplex, and self-hosted media guides.
icon: material/map
hide:
  - navigation
  - toc
status: new
---

<section class="hero" markdown>

# Your media fleet, finally on one map

Plundarrpedia connects the projects, containers, paths, and practical decisions
behind a self-hosted media stack—without assuming your harbor is a Synology.

[Plot a course](start-here/index.md){ .md-button .md-button--primary }
[Open the Plundarr charts](projects/plundarr/index.md){ .md-button }

</section>

<div class="fleet-line" aria-hidden="true">
  <b>DISCOVER</b><span></span><b>DOWNLOAD</b><span></span><b>STREAM</b>
</div>

## Pick up the right chart

<div class="grid cards" markdown>

-   :material-ship-wheel:{ .lg .middle } **Build a complete media stack**

    ---

    Use Maraudarr to generate one complete Plundarr Compose file and its
    matching environment.

    [:octicons-arrow-right-24: Start with Plundarr](projects/plundarr/quick-start.md)

-   :material-shield-key:{ .lg .middle } **Generate a PIA WireGuard config**

    ---

    Use Privateerr to run PIA's official scripts, then hand the result to
    Gluetun or another WireGuard client.

    [:octicons-arrow-right-24: Start with Privateerr](projects/privateerr/quick-start.md)

-   :material-television-classic:{ .lg .middle } **Care for Plex after launch**

    ---

    Explore Duplex, Kometa, ImageMaid, PATTRMM, Tautulli, and the rest of the
    backstage crew.

    [:octicons-arrow-right-24: Meet Duplex](projects/duplex/index.md)

-   :material-server-network:{ .lg .middle } **Choose your Docker harbor**

    ---

    Translate the same Compose stack to Linux Docker, Synology Container
    Manager, or the Docker-based TrueNAS Apps system.

    [:octicons-arrow-right-24: Choose a deployment](start-here/choose-a-deployment.md)

</div>

## The fleet at a glance

<div class="flow-map" role="img" aria-label="Requests flow from your crew through Seerr, media managers, a download client, the media library, and Plex or Jellyfin.">
  <span class="flow-map__step">👥 Your crew</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">🔎 Seerr</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">🎬 Radarr / Sonarr</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">⬇️ Download client</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">🗂️ Media library</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">📺 Plex / Jellyfin</span>
</div>

<div class="flow-map flow-map--support" role="img" aria-label="Privateerr generates WireGuard configuration for the Gluetun VPN tunnel, while Duplex maintains and monitors Plex.">
  <span class="flow-map__step">🔐 Privateerr</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">📄 WireGuard config</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">🛡️ Gluetun VPN tunnel</span>
  <span class="flow-map__divider" aria-hidden="true">◆</span>
  <span class="flow-map__step">📺 Duplex</span>
  <span class="flow-map__arrow" aria-hidden="true">→</span>
  <span class="flow-map__step">🧰 Plex maintenance</span>
</div>

!!! important "Privateerr draws the map; Gluetun sails the tunnel"
    Privateerr is deliberately not a VPN client. It generates `wg0.conf` and
    endpoint metadata. Gluetun is the component that establishes and maintains
    the VPN tunnel.

## What makes this wiki different

- **One architecture, several harbors.** Linux Docker, Synology, and TrueNAS
  each get a path that respects their storage and permissions model.
- **Task-first navigation.** Pages answer what to do and why, then send you to
  the source repository when project internals matter.
- **Safe examples.** Credentials, live WireGuard keys, API keys, and private
  hostnames never belong in these charts.
- **Two delivery lanes.** Read the site on GitHub Pages or run the same static
  build as a small, unprivileged container.
