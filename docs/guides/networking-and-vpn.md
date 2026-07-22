---
title: Networking and VPN
description: Choose subnets, expose ports, understand shared namespaces, and validate the PIA path.
icon: material/vpn
---

# Networking and VPN

## Choose a non-overlapping subnet

Docker uses private address space, but not every private range is free in your
environment. Compare the proposed Compose subnet with:

- your LAN and guest networks;
- routes installed by corporate or travel VPNs;
- existing Docker networks (`docker network ls` and `docker network inspect`);
- remote networks reached through site-to-site tunnels.

Overlap creates intermittent routing failures that look like DNS, firewall, or
application bugs.

## Shared network namespaces

When Compose says:

```yaml
network_mode: service:gluetun
```

the dependent service shares Gluetun's interfaces, IP address, and port space.
Publish the download client's Web UI port on Gluetun. Inside the shared
namespace, the services can use `127.0.0.1` to reach each other.

## Host exposure

Publishing `8080:8080` means host port 8080 forwards to container port 8080. It
does not authenticate the application. Bind only to trusted interfaces where
supported, use a firewall, or put the UI behind a properly configured reverse
proxy/access layer.

## DNS

Decide whether DNS for the VPN lane should be resolved by Gluetun's configuration
or by the host. Avoid adding ad hoc DNS overrides until you know whether the
failure occurs before or after the tunnel starts.

## Port forwarding

PIA port forwarding is a coordinated chain:

1. Privateerr requests a compatible endpoint and writes its identity.
2. Gluetun connects to that endpoint and obtains/maintains the forwarded port.
3. The torrent client listens on the port reported by Gluetun.
4. Health or validation tooling confirms the values remain synchronized.

A green VPN connection proves only step 2. Test the complete chain when inbound
torrent connectivity matters.

## Validation ladder

```console
docker compose config
docker compose ps
docker compose logs privateerr
docker compose logs gluetun
make test-vpn
```

Then check the download client's Web UI and listening-port setting. Move on to
Prowlarr/Radarr/Sonarr only after this layer is stable.
