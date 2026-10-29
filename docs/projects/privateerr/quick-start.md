---
title: Privateerr Quick Start
description: Generate PIA WireGuard files or start Privateerr, Gluetun, and qBittorrent without running live fault tests.
icon: material/flash
status: updated
---

# Privateerr quick start

Choose a VPN-enabled Plundarr preset for a generated media stack, or the standalone Privateerr project for one-shot generation and a focused three-service stack. You need Docker, a PIA subscription, and private storage. Source builds also require Git, Make, Compose, Buildx, and the initialized PIA submodule.

## Generate the complete Plundarr route

Complete [Plundarr's generator setup](../plundarr/quick-start.md#choose-the-generator), then generate the preset. Set `PIA_USER` and `PIA_PASS` in `dist/plundarr/.env`; keep `PIA_PF=true` for forwarding. Review paths, permissions, ports, and the generated shared API key:

```sh
make config
make up
make test-vpn
```

Privateerr installs its integration scripts and prepares the saved pair before readiness. Gluetun then starts the tunnel. Recovery is enabled when both are selected, preserving existing keys and explicit opt-outs.

> [!WARNING]
> Keep credentials, keys, VPN files, resolved Compose output, and unsanitized logs out of Git and public support reports.

## Generate files for another WireGuard deployment

Clone the source with its public submodule:

```sh
git clone --recurse-submodules https://github.com/scottgigawatt/privateerr.git
cd privateerr
cp example.env .env
```

Edit the private `.env`: set PIA credentials, keep `PIA_VPN_PROTOCOL=wireguard` and `PIA_CONNECT=false`, and review output paths. Preserve needed VPN files and stop every supervisor writing the same directory before running:

```sh
make run-privateerr
```

This builds the checkout, disables recovery/keepalive for the disposable run, and replaces `config/gluetun/wireguard/wg0.conf` and `privateerr.env`. It does not change `.env`. Custom one-shot containers should use `restart: "no"`; the [direct Docker route](https://github.com/scottgigawatt/privateerr#using-docker-directly) needs neither Git nor Make.

## Run the standalone example stack

From the checkout above, prepare the three-service Privateerr/Gluetun/qBittorrent application:

1. Generate a key with `openssl rand -hex 24` and save it as `PRIVATEERR_GLUETUN_API_KEY` in `.env`.
2. Review qBittorrent's user/group IDs, config/download paths, and `QBITTORRENT_WEBUI_PORT`. Keep `PIA_PF=true` and `QBITTORRENT_PORT_SYNC=true` for forwarding.
3. Share the complete `config/gluetun/` directory read/write with both VPN services. Privateerr installs the scripts; no separate download or file mount is needed.
4. Confirm amd64 or arm64 support for this qBittorrent example; Privateerr alone also supports arm/v7.

Pull the published images and start the application:

```sh
make config
make up
make ps
```

`make up` does not build images or start Buccaneerr. Use `make up-build` to build Privateerr from this checkout while pulling its companions. Check Privateerr's readiness, Gluetun's healthy tunnel, and qBittorrent's Web UI in that order.

Open the configured host port, default `8080`. Read qBittorrent's initial password locally from logs and change it. The seeded hook uses unauthenticated loopback API access; every application sharing the namespace has that access. Existing qBittorrent configuration must permit the hook. See [local control and VPN ports](../../guides/networking-and-vpn.md#shared-network-namespaces).

`make down` stops the project while preserving volumes, images, and the saved pair. Keep Gluetun's control/health ports internal.

## Run tests deliberately

Ordinary startup does not run fault tests. `make test` runs credential-free checks in Buccaneerr with runtime networking disabled; building the test image can need network access.

> [!CAUTION]
> Live tests deliberately interrupt the VPN and can overwrite saved configuration during cleanup. Use the [Privateerr testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/) from an isolated disposable checkout, with needed files backed up.

[Understand the file handoff](config-handoff.md){ .md-button } [Troubleshoot Privateerr](troubleshooting.md){ .md-button }
