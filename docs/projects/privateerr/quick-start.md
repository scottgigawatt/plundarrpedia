---
title: Privateerr Quick Start
description: Generate the Privateerr and Gluetun handoff through Plundarr or as a focused standalone run.
icon: material/flash
status: updated
---

# Privateerr quick start

Privateerr remains an actively maintained standalone project and a first-class Plundarr integration. Use a VPN-enabled Plundarr preset for a complete generated deployment, or use standalone Privateerr when you need its WireGuard configuration and metadata without the rest of the stack.

For existing checkouts, review the [v2 command replacements](../plundarr/upgrading.md#update-command-names). Privateerr v2.1 retains the file handoff and keeps recovery disabled when an existing image-only deployment omits its flag. Review [recovery upgrades](automatic-recovery.md#upgrade-a-generated-deployment) before adopting the new Compose settings.

## Generate the complete Plundarr route

```sh
git clone https://github.com/scottgigawatt/plundarr.git
cd plundarr
make ship
```

Set `PIA_USER` and `PIA_PASS` in `dist/plundarr/.env`. Set `PIA_PF=true` when you need a port-forwarding-capable endpoint, then validate and start the stack:

```sh
make config
make up
make test-vpn
```

Privateerr prepares `wg0.conf` and `privateerr.env` beneath the generated configuration tree. Gluetun consumes the handoff and establishes the live tunnel. Maraudarr v2.1.0 enables recovery for this paired selection and generates its shared API key in the private `.env`; keep it secret. Existing values and opt-outs survive regeneration.

> [!WARNING]
> `wg0.conf` contains live WireGuard connection material. Do not paste it into an issue, commit it, or include it in an unencrypted backup.

## Generate files for another WireGuard deployment

Use the standalone source when you need Privateerr output outside a generated Plundarr project:

```sh
git clone --recurse-submodules https://github.com/scottgigawatt/privateerr.git
cd privateerr
cp example.env .env
```

Set the real PIA values in the ignored `.env`, then generate fresh files. Stop any supervisor using the same configuration directory first:

```sh
make run-privateerr
```

`make run-privateerr` disables recovery and keepalive only for this disposable run; it exits after generation without changing `.env`. Custom one-shot deployments should also use `restart: "no"`.

The outputs are:

| File | Consumer | Purpose |
| --- | --- | --- |
| `config/gluetun/wireguard/wg0.conf` | Gluetun, WireGuard, or another compatible client | WireGuard interface, peer, keys, and endpoint. |
| `config/gluetun/wireguard/privateerr.env` | Gluetun wrapper or other automation | PIA server identity, region, endpoint, and port-forwarding support. |

Inspect only the non-secret metadata you need. Do not print or share the private key from `wg0.conf`.

## Run the standalone example stack

The root Compose example starts Privateerr, Gluetun, qBittorrent, and Buccaneerr. Recovery and qBittorrent port synchronization are enabled in `example.env`. Before starting:

1. Generate a private shared API key with `openssl rand -hex 24` and set `PRIVATEERR_GLUETUN_API_KEY` in `.env`.
2. Review qBittorrent user/group IDs, config and download paths, and `QBITTORRENT_WEBUI_PORT` for the host.
3. Keep `PIA_PF=true` and `QBITTORRENT_PORT_SYNC=true` to exercise forwarding.

Buccaneerr deliberately blocks the active VPN endpoint briefly to verify automatic recovery. Start this test stack only when an intentional outage is acceptable:

```sh
make config
make up
make ps
make logs
```

qBittorrent's Web UI uses host port 8080 by default. Its internal listener, published port, healthcheck, and forwarding-hook URL follow `QBITTORRENT_WEBUI_PORT` together. Gluetun's control and health ports stay unpublished. Read qBittorrent's initial password locally from its container logs and change it in the Web UI; do not share those logs.

The seeded qBittorrent API permits loopback access for Gluetun's hook, while remote Web UI access still requires authentication. Other applications in that shared namespace have the same loopback access. Existing application configuration is preserved and must allow the hook explicitly.

For a lasting application stack without the test container, start only:

```sh
docker compose up --detach privateerr gluetun qbittorrent
```

Use `BUCCANEERR_TEST_RECOVERY=false` for connectivity-only validation when you do run the tester. LinuxServer's qBittorrent image supports amd64 and arm64; check application architecture separately from Privateerr's arm/v7 support.

## Clean up live test state

```sh
make down
make restore-test-config
git status --short
```

`restore-test-config` restores the checked-in safe examples after a live run. Use `make clean-test` after end-to-end validation so containers are stopped and example state is restored together.

[Understand the file handoff](config-handoff.md){ .md-button .md-button--primary }
[Troubleshoot Privateerr](troubleshooting.md){ .md-button }
