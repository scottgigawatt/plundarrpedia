---
title: Privateerr Quick Start
description: Generate the Privateerr and Gluetun handoff through Plundarr or as a focused standalone run.
icon: material/flash
status: updated
---

# Privateerr quick start

Use a VPN-enabled Plundarr preset for a new complete deployment. Maraudarr selects Privateerr and Gluetun together, writes the required environment and mounts, and preserves their configuration under the generated preset directory.

## Generate the recommended Plundarr route

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

Privateerr writes `wg0.conf` and `privateerr.env` beneath the generated configuration tree. Gluetun consumes the handoff and establishes the live tunnel.

!!! warning
    `wg0.conf` contains live WireGuard connection material. Do not paste it into an issue, commit it, or include it in an unencrypted backup.

## Generate files for another WireGuard deployment

Use the standalone source only when you specifically need Privateerr output outside a generated Plundarr project:

```sh
git clone --recurse-submodules https://github.com/scottgigawatt/privateerr.git
cd privateerr
cp example.env .env
```

Set the real PIA values in the ignored `.env`, then generate fresh files:

```sh
make run-privateerr
```

The outputs are:

| File | Consumer | Purpose |
| --- | --- | --- |
| `config/gluetun/wireguard/wg0.conf` | Gluetun, WireGuard, or another compatible client | WireGuard interface, peer, keys, and endpoint. |
| `config/gluetun/wireguard/privateerr.env` | Gluetun wrapper or other automation | PIA server identity, region, endpoint, and port-forwarding support. |

Inspect only the non-secret metadata you need. Do not print or share the private key from `wg0.conf`.

## Run the standalone example stack

The Privateerr repository also includes a Privateerr and Gluetun Compose example:

```sh
make config
make up
make ps
make logs
```

Use this route for a focused handoff test, not as a second full media-stack architecture.

## Clean up live test state

```sh
make down
make restore-test-config
git status --short
```

`restore-test-config` restores the checked-in safe examples after a live run. Use `make clean-test` after end-to-end validation so containers are stopped and example state is restored together.

[Understand the file handoff](config-handoff.md){ .md-button .md-button--primary }
[Troubleshoot Privateerr](troubleshooting.md){ .md-button }
