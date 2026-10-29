---
title: Privateerr
description: Generate PIA WireGuard settings and recover stale Gluetun connections inside the existing Privateerr container.
icon: material/shield-key
status: updated
---

# Privateerr ⚓

Privateerr generates PIA WireGuard settings for Gluetun or another compatible VPN client. Its optional supervisor refreshes stale Gluetun connections through an authenticated API. Gluetun establishes and runs the tunnel.

Use a VPN-enabled Plundarr preset for a complete generated deployment, or the standalone project for one-shot generation and a focused Privateerr/Gluetun/qBittorrent stack.

## The two outputs

| File | Purpose |
| --- | --- |
| `config/gluetun/wireguard/wg0.conf` | WireGuard keys, interface, peer, and endpoint |
| `config/gluetun/wireguard/privateerr.env` | Matching PIA server identity, region, and forwarding support |

Keep both files private. The matching metadata lets Gluetun request port forwarding for the selected endpoint.

## Recovery without another service

[Automatic recovery](automatic-recovery.md) is enabled when generated Plundarr selects both Privateerr and Gluetun. It preserves the container/network namespace while replacing tunnel settings; connections can still disconnect. Custom image-only deployments must opt in.

The [quick start](quick-start.md) separates ordinary application startup from tests that deliberately interrupt the VPN.

## Images and platforms

Stable `latest` and exact release tags are available from [GHCR](https://github.com/scottgigawatt/privateerr/pkgs/container/privateerr) and [Docker Hub](https://hub.docker.com/r/scottgigawatt/privateerr). `edge` follows successful `main` builds. Privateerr supports amd64, arm64, and arm/v7; companion applications can have narrower support.

## Trust boundary

Privateerr invokes PIA's unmodified scripts, publishes the saved pair, and installs its two image-owned integration scripts before readiness. Test tools run separately in Buccaneerr. See the [source and developer contracts](https://scottgigawatt.github.io/privateerr/) and [security policy](https://scottgigawatt.github.io/privateerr/SECURITY/) for implementation and retained vulnerability findings.

[Start with Privateerr](quick-start.md){ .md-button .md-button--primary } [View the source](https://github.com/scottgigawatt/privateerr){ .md-button }
