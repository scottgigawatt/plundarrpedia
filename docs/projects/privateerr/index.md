---
title: About Privateerr
description: Understand Privateerr settings, Gluetun VPN traffic, and automatic recovery.
icon: material/shield-key
---

# Privateerr

Privateerr creates PIA WireGuard configuration for Gluetun or another compatible VPN client. Its built-in Python supervisor can replace stale connection settings through Gluetun's authenticated API. **Gluetun establishes and runs the VPN tunnel.**

[Start Privateerr, Gluetun, and qBittorrent](quick-start.md){ .md-button .md-button--primary }

## What Privateerr creates

| File in `config/gluetun/wireguard/` | Purpose |
| --- | --- |
| `wg0.conf` | WireGuard keys, interface, peer, and endpoint |
| `privateerr.env` | Matching PIA server identity and port-forwarding support |

Keep both files private and together. The supplied three-service stack installs its integration scripts automatically. [Automatic recovery](automatic-recovery.md) is enabled in that stack and in Plundarr when Privateerr and Gluetun are selected. If you write your own Compose file, enable recovery and set its shared key explicitly.

For a different task, [create configuration files once for another VPN client](https://scottgigawatt.github.io/privateerr/advanced-usage/#generate-without-make). Privateerr supports amd64, arm64, and arm/v7; companion services can support fewer platforms.

See [configuration handoff](config-handoff.md) for file/mount details or [developer documentation](https://scottgigawatt.github.io/privateerr/development/privateerr/) for source and tests. Privateerr uses PIA's unmodified connection scripts; test tools stay in the separate Buccaneerr image.
