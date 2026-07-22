---
title: Privateerr Quick Start
description: Generate a PIA WireGuard configuration in one short run.
icon: material/flash
---

# Privateerr quick start

## Clone and prepare

The upstream PIA scripts are a Git submodule, so include submodules when
cloning:

```console
git clone --recurse-submodules https://github.com/scottgigawatt/privateerr.git
cd privateerr
cp example.env .env
```

## Generate the files

Pass credentials for the run instead of storing them in shell history whenever
your environment offers a safer secret mechanism. The direct form is:

```console
PIA_USER="p1234567" \
PIA_PASS="replace-me" \
PIA_PF="false" \
make run-privateerr
```

Inspect the generated files:

```console
sed -n '1,120p' config/gluetun/wireguard/wg0.conf
sed -n '1,120p' config/gluetun/wireguard/privateerr.env
```

!!! warning
    `wg0.conf` contains live WireGuard connection material. Do not paste it into
    an issue, commit it, or include it in ordinary backups without encryption.

## Request a port-forwarding region

```console
PIA_USER="p1234567" \
PIA_PASS="replace-me" \
PIA_PF="true" \
make run-privateerr
```

Privateerr asks PIA for a port-forwarding-capable endpoint, identifies the
matching PIA WireGuard server name, and records that name in `privateerr.env`.
Gluetun still owns the live tunnel and the forwarded-port lifecycle.

## Run the paired Compose stack

The repository includes a full Privateerr + Gluetun example:

```console
make up
docker compose ps
make logs
```

Use this when you want automatic generation, health-ordered Gluetun startup,
and port-forwarding integration rather than only the resulting file.

## Clean up safely

```console
make down
make reset-config
```

`reset-config` restores the checked-in example files after a live run. Inspect
`git status --short` before committing anything from a checkout that handled
real credentials.
