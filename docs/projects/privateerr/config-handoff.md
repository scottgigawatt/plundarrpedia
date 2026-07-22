---
title: Privateerr Config Handoff
description: Follow Privateerr output from PIA scripts through shared storage into Gluetun.
icon: material/file-swap
---

# Config handoff

Privateerr and Gluetun coordinate through files, health, and a thin wrapper—not
through hidden changes to either upstream project.

<ol class="handoff-timeline">
  <li><strong>Compose starts Privateerr.</strong> The generator requests a token and WireGuard endpoint through PIA's scripts and API.</li>
  <li><strong>Privateerr writes the handoff.</strong> It stores <code>wg0.conf</code> and <code>privateerr.env</code> in the shared config directory.</li>
  <li><strong>Privateerr reports healthy.</strong> Compose can now satisfy Gluetun's service dependency.</li>
  <li><strong>The Gluetun wrapper reads metadata.</strong> It loads <code>PIA_WG_SERVER_NAME</code> and exports the matching <code>SERVER_NAMES</code> value.</li>
  <li><strong>Gluetun launches.</strong> Gluetun consumes the generated WireGuard file and owns the live tunnel.</li>
</ol>

## Why the metadata exists

`wg0.conf` has enough information to create the tunnel, but PIA port forwarding
also depends on the provider's server identity. `privateerr.env` records that
identity and related endpoint facts in a format the Gluetun wrapper can source.

A representative metadata file contains:

```dotenv
PIA_WG_SERVER_NAME=example-server
PIA_WG_ENDPOINT_IP=192.0.2.10
PIA_WG_ENDPOINT_PORT=1337
PIA_REGION_ID=example-region
PIA_REGION_NAME="Example Region"
PIA_PORT_FORWARDING_SUPPORTED=true
PIA_GEOLOCATED_REGION=false
```

These are documentation values. A real generated file contains the endpoint
selected for your account and request.

## Important variables

| Variable | Owner | Meaning |
| --- | --- | --- |
| `PIA_USER`, `PIA_PASS` | PIA scripts | Account credentials. |
| `PIA_PF` | PIA scripts | Request a port-forwarding-capable region. |
| `PIA_CONNECT=false` | Privateerr policy | Generate files without connecting in the generator. |
| `PIA_CONF_PATH` | PIA scripts | Container path where `wg0.conf` is written. |
| `PRIVATEERR_METADATA_PATH` | Privateerr | Container path for `privateerr.env`. |
| `PRIVATEERR_KEEPALIVE` | Privateerr | Keep the healthy generator container alive for Compose ordering. |
| `VPN_SERVICE_PROVIDER=custom` | Gluetun | Tell Gluetun to consume the generated WireGuard configuration. |

## Directory mounts

Mount the shared **directory**, not only `wg0.conf`. Privateerr writes both
files and may replace them atomically. Gluetun reads that same directory after
Privateerr becomes healthy.

This is also why real outputs remain ignored: the shared directory is runtime
state with secrets, not documentation source.
