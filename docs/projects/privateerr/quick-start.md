---
title: Privateerr Quick Start
description: Generate PIA WireGuard files or start Privateerr, Gluetun, and qBittorrent without running live fault tests.
icon: material/flash
status: updated
---

# Privateerr quick start

Use a VPN-enabled Plundarr preset for a generated media deployment, or the standalone Privateerr checkout for one-shot configuration and the focused three-service application stack. You need Docker, an active PIA subscription, and private storage for the generated files. Source-build routes also need Git, Make, Compose, Buildx, and the initialized PIA submodule.

## Generate the complete Plundarr route

Follow [Plundarr's generator setup](../plundarr/quick-start.md#choose-the-generator), then run `make ship`. Set `PIA_USER` and `PIA_PASS` in `dist/plundarr/.env`; use `PIA_PF=true` for a forwarding-capable endpoint. Review paths, permissions, ports, and the generated shared API key before starting:

```sh
make config
make up
make test-vpn
```

Privateerr prepares `wg0.conf` and `privateerr.env`; Gluetun consumes the handoff and establishes the tunnel. Maraudarr enables recovery when both services are selected and preserves existing keys and explicit opt-outs.

> [!WARNING]
> The VPN path uses real PIA credentials. Keep `.env`, `wg0.conf`, `privateerr.env`, API keys, and unsanitized logs out of Git and public support reports.

## Generate files for another WireGuard deployment

For the standalone source workflow:

```sh
git clone --recurse-submodules https://github.com/scottgigawatt/privateerr.git
cd privateerr
cp example.env .env
```

Set `PIA_USER` and `PIA_PASS` in the ignored `.env`. Keep `PIA_VPN_PROTOCOL=wireguard` and `PIA_CONNECT=false`. Preserve any saved files you need and stop every supervisor writing the same directory before generation:

```sh
make run-privateerr
```

This builds the checked-out source, disables recovery and keepalive for the disposable run, and exits after replacing the saved pair without changing `.env`. Custom one-shot containers should also use `restart: "no"`. For generation without Git or Make, use the [published-image Docker command](https://github.com/scottgigawatt/privateerr#using-docker-directly).

| Output | Purpose |
| --- | --- |
| `config/gluetun/wireguard/wg0.conf` | WireGuard interface, peer, keys, and endpoint for a compatible VPN client. |
| `config/gluetun/wireguard/privateerr.env` | PIA server identity, region, endpoint, and port-forwarding support. |

## Run the standalone example stack

The application stack contains Privateerr, Gluetun, and qBittorrent. From the checkout above, complete this preflight:

- [ ] Set PIA credentials and generate a shared recovery key with `openssl rand -hex 24`; save it as `PRIVATEERR_GLUETUN_API_KEY` in `.env`.
- [ ] Review qBittorrent user/group IDs, config/download paths, and `QBITTORRENT_WEBUI_PORT`.
- [ ] Keep `PIA_PF=true` and `QBITTORRENT_PORT_SYNC=true` for the demonstrated forwarding path.
- [ ] Keep the configured Gluetun wrapper readable and the forwarding script executable; the supplied Compose mounts both from `config/gluetun/scripts/`.
- [ ] Check architecture support: the qBittorrent application example requires amd64 or arm64 even though Privateerr also supports arm/v7.

Pull the published application images and start the three services detached:

```sh
make config
make up
make ps
```

`make up-pull` is an explicit alias. These targets do not build images or start Buccaneerr. To pull Gluetun/qBittorrent, build Privateerr from the checkout, and retain that local build at startup, use:

```sh
make up-build
```

Without Make, the equivalent published-image startup is:

```sh
docker compose --env-file .env pull privateerr gluetun qbittorrent
docker compose --env-file .env up --detach --no-build --pull never privateerr gluetun qbittorrent
```

qBittorrent's Web UI uses host port `8080` by default. Its listener, host mapping, healthcheck, and forwarding-hook URL follow `QBITTORRENT_WEBUI_PORT` together. Read its initial password locally from container logs, change it in the Web UI, and keep those logs private. The seeded API allows loopback access for Gluetun's hook; other applications in that shared namespace have the same loopback access. Existing application configuration must allow the hook explicitly.

Gluetun's control and health ports remain internal. `make down` stops the selected project, including any test-profile container, while preserving volumes, images, and saved configuration.

## Run tests deliberately

`make test` runs credential-free repository checks in Buccaneerr with runtime networking disabled; the initial test-image build may need network access. Buccaneerr's live service is in the `test` profile and starts only through an explicit test route.

> [!CAUTION]
> `make test-e2e` uses real PIA credentials and deliberately interrupts its VPN endpoint. Use a disposable checkout, preserve needed configuration, and accept the outage before running it.

```sh
make test-e2e
make clean-test
git status --short
```

Run each command after the preceding command finishes. `make clean-test` stops the test-profile stack and restores safe examples only after shutdown succeeds. Restoration overwrites the saved VPN pair; do not use it against an active supervisor or a lasting deployment. `BUCCANEERR_TEST_RECOVERY=false` selects connectivity-only live validation. See [test boundaries](troubleshooting.md#testing-the-full-path) for API-only and isolated live suites.

[Understand the file handoff](config-handoff.md){ .md-button .md-button--primary }
[Troubleshoot Privateerr](troubleshooting.md){ .md-button }
