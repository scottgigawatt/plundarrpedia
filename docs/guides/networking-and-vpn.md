---
title: Networking and VPN
description: Choose subnets, expose ports, understand shared namespaces, and validate the PIA path.
icon: material/vpn
---

# Networking and VPN

## Choose a non-overlapping subnet

Docker uses private address space, but not every private range is free in your environment. Compare the proposed Compose subnet with:

- your LAN and guest networks;
- routes installed by corporate or travel VPNs;
- existing Docker networks (`docker network ls` and `docker network inspect`);
- remote networks reached through site-to-site tunnels.

Overlap creates intermittent routing failures that look like DNS, firewall, or application bugs.

## Shared network namespaces

When Compose says:

```yaml
network_mode: service:gluetun
```

the dependent service shares Gluetun's interfaces, IP address, and port space. Publish the download client's Web UI port on Gluetun. Inside the shared namespace, the services can use `127.0.0.1` to reach each other.

Privateerr stays outside that namespace so it can reach PIA during a tunnel outage. Its [automatic recovery](../projects/privateerr/automatic-recovery.md) uses Gluetun's internal API, preserving the container and namespace. Keep the control and health ports unpublished.

qBittorrent's Web UI mapping belongs on Gluetun because qBittorrent shares its network namespace. Browser requests to that published Web UI and loopback API requests are local control traffic; they do not need to travel through the remote VPN tunnel. Torrent peer traffic uses the VPN tunnel.

Privateerr installs the forwarding hook that Gluetun calls to synchronize qBittorrent's assigned peer port and VPN interface. These controls belong in the generated `.env`:

| Setting | Default | Purpose |
| --- | --- | --- |
| `QBITTORRENT_WEBUI_PORT` | `8080` in Plundarr; presets may choose another port | Set the host mapping, application listener, healthcheck, and default API URL together. |
| `QBITTORRENT_PORT_SYNC` | `true` | Apply the VPN peer port and interface through the hook; `false` skips updates. |
| `QBITTORRENT_API_URL` | `http://127.0.0.1:${QBITTORRENT_WEBUI_PORT}` | Reach qBittorrent's Web API inside the shared namespace; change only for a deliberate API override. |
| `QBITTORRENT_API_WAIT_SECONDS` | `300` | Maximum seconds the forwarding hook waits for the Web API. |

The seeded API permits unauthenticated loopback access for that hook. Every container intentionally sharing Gluetun's namespace shares this loopback trust boundary; remote Web UI clients still authenticate. Existing application configuration remains operator-owned.

`depends_on.restart: true` follows planned Compose updates of Gluetun; an external replacement may still require recreating its dependent applications.

## Host exposure

Publishing `8080:8080` means host port 8080 forwards to container port 8080. It does not authenticate the application. Bind only to trusted interfaces where supported, use a firewall, or put the UI behind a properly configured reverse proxy/access layer.

## DNS

Decide whether DNS for the VPN lane should be resolved by Gluetun's configuration or by the host. Avoid adding ad hoc DNS overrides until you know whether the failure occurs before or after the tunnel starts.

## Port forwarding

PIA port forwarding is a coordinated chain:

1. Privateerr requests a compatible endpoint and writes its identity.
2. Gluetun connects to that endpoint and obtains/maintains the forwarded port.
3. Gluetun calls the hook installed by Privateerr, and the torrent client listens on the reported VPN peer port and interface.
4. Health or validation tooling confirms the values remain synchronized.

The VPN-assigned peer port is separate from the Web UI port and arrives through the VPN tunnel. It needs no host TCP/UDP publication. A green tunnel does not prove a working lease or synchronized client; test the complete chain when inbound torrent connectivity matters.

## Validation ladder

Run these commands from the Plundarr repository root for the default preset:

```sh
make config
make ps
docker compose --project-directory dist/plundarr logs privateerr gluetun
make test-vpn
```

Then check the download client's Web UI and listening-port setting. Move on to Prowlarr/Radarr/Sonarr only after this layer is stable.
