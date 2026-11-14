---
title: Privateerr quick start
description: Run the published Privateerr, Gluetun, and qBittorrent images and verify the VPN download stack.
icon: material/flash
---

# Start Privateerr, Gluetun, and qBittorrent

This starts three published images. The **Privateerr container** generates the PIA WireGuard configuration file and monitors VPN recovery. The **Gluetun VPN container** runs the VPN tunnel. **qBittorrent** downloads through Gluetun.

## Before you start

You need Git, Docker with Compose v2, an active PIA subscription, and an amd64 or arm64 host for the supplied qBittorrent image. Privateerr alone also supports arm/v7. Choose private storage for configuration and a writable download directory. No local image build or Make is required.

## 1. Create your settings file

Start a new checkout:

```sh
git clone --recurse-submodules https://github.com/scottgigawatt/privateerr.git
cd privateerr
cp example.env .env
```

Open `.env` in your editor. Change the right-hand value for these settings, retaining each setting name:

| Setting | Required action |
| --- | --- |
| `PIA_USER`, `PIA_PASS` | Enter your PIA VPN username (`p` or `P` followed by seven digits) and password; do not use your email |
| `PRIVATEERR_GLUETUN_API_KEY` | Set a private key generated with the command below |
| `QBITTORRENT_PUID`, `QBITTORRENT_PGID` | Match the numeric host owner of downloads and qBittorrent configuration; use `id` to check |
| `HOST_TORRENTS_DOWNLOADS_PATH` | Choose a writable download directory |
| `QBITTORRENT_TZ`, `QBITTORRENT_WEBUI_PORT` | Set your timezone; change port `8080` only if occupied |

Generate the shared recovery key locally, then paste it into `PRIVATEERR_GLUETUN_API_KEY`:

```sh
openssl rand -hex 24
```

Keep `PIA_VPN_PROTOCOL=wireguard`, `PIA_CONNECT=false`, `PIA_PF=true`, `PRIVATEERR_AUTO_RECOVER=true`, and `QBITTORRENT_PORT_SYNC=true`. The Privateerr container and the Gluetun VPN container mount the same host directory, `config/gluetun/`; Privateerr installs the integration scripts there at startup.

> [!WARNING]
> Keep `.env`, WireGuard files, API keys, and unsanitized logs private. Do not commit them or paste them into support requests.

## 2. Start the published images

Run from the `privateerr` checkout:

```sh
docker compose config --quiet
docker compose pull privateerr gluetun qbittorrent
docker compose up --detach --no-build privateerr gluetun qbittorrent
docker compose ps
```

Quiet validation succeeds without output. Allow time for image downloads and VPN startup. The test service Buccaneerr is excluded from this command.

## 3. Confirm the VPN and open qBittorrent

Inspect startup locally:

```sh
docker compose logs --tail 100 privateerr gluetun qbittorrent
```

Confirm `Automatic recovery enabled` and `Gluetun tunnel is healthy` in Privateerr's logs. Privateerr being healthy means its startup files are ready; Gluetun's health reports the tunnel state.

Open <http://localhost:8080> when Docker runs on this computer. From another computer, use the Docker host's address and your configured port. Sign in to qBittorrent as `admin`, read its temporary password locally from qBittorrent's logs, and change it in the Web UI.

In qBittorrent, confirm the listening port matches Gluetun's forwarded port and its network interface is the VPN interface. The forwarding hook updates both. A tunnel can be healthy even if the hook cannot reach qBittorrent; see [qBittorrent troubleshooting](troubleshooting.md#qbittorrent-does-not-follow-the-tunnel).

You have a working starting point when all three containers run, Gluetun is healthy, and you can sign in to qBittorrent. A small legal test download provides an additional end-to-end check. If a step fails, use [Privateerr troubleshooting](troubleshooting.md).

## Stop or expand

Stop the project while retaining saved configuration and downloads:

```sh
docker compose down
```

[Generate a complete Plundarr stack](../plundarr/quick-start.md) when you want media automation and dashboards. Plundarr includes its own VPN services; stop this standalone project before reusing its ports or application state. Do not point both stacks at the same qBittorrent configuration.

For another task, [create WireGuard configuration files once](https://scottgigawatt.github.io/privateerr/advanced-usage/#generate-without-make), [choose a PIA region](../plundarr/configuration.md#vpn-region-selection), or [configure automatic recovery](automatic-recovery.md). [Privateerr's developer guide](https://scottgigawatt.github.io/privateerr/development/privateerr/) covers source builds and tests. Tests that deliberately interrupt the VPN belong in an isolated environment.
