---
title: Automatic VPN recovery
description: Enable and operate Privateerr automatic recovery for Gluetun.
icon: material/shield-refresh
---

# Recover stale VPN connections

Privateerr's built-in Python supervisor checks Gluetun's tunnel health. After a sustained failure, the supervisor obtains replacement PIA settings, sends them through Gluetun's authenticated API, and saves them after verification. Gluetun and download containers stay running, although connections can disconnect during recovery.

## Enable recovery

The [standalone quick start](quick-start.md) and generated Plundarr projects enable recovery when both Privateerr and Gluetun are selected. Maraudarr creates the shared key; the standalone project asks you to generate one. Existing generated values and explicit opt-outs are preserved.

If you write your own Compose file, use Privateerr's [custom recovery setup](https://scottgigawatt.github.io/privateerr/automatic-recovery/#configure-a-custom-deployment). Both containers need the same private key, the current wrapper, writable shared configuration, and an internal connection to Gluetun's control API. Keep control and health ports unpublished. Only one supervisor may write a configuration directory.

Keep `PRIVATEERR_KEEPALIVE=true`, `PIA_CONNECT=false`, and WireGuard selected. Privateerr must stay outside Gluetun's network so it can reach PIA during an outage. A custom wrapper or operator-managed authentication file must satisfy the [Privateerr recovery contract](https://scottgigawatt.github.io/privateerr/automatic-recovery/).

## Check recovery is active

From the directory containing the deployed Compose file and `.env`:

```sh
docker compose logs --tail 100 privateerr
```

Confirm `Automatic recovery enabled` and `Gluetun tunnel is healthy`. Privateerr's healthcheck indicates startup readiness, while Gluetun's healthcheck checks the tunnel. Do not deliberately break a working VPN to check setup; live fault tests belong in an isolated test deployment.

## Timing and region

All timing settings below use seconds:

| Setting | Default | Meaning |
| --- | --- | --- |
| `PRIVATEERR_RECOVERY_INTERVAL_SECONDS` | `30` | Time between health probes |
| `PRIVATEERR_RECOVERY_FAILURE_SECONDS` | `120` | Startup grace and continuous failure threshold |
| `PRIVATEERR_RECOVERY_COOLDOWN_SECONDS` | `300` | Initial retry delay, increasing to one hour |
| `PRIVATEERR_GENERATION_TIMEOUT_SECONDS` | `180` | Maximum time for PIA generation |

Detection can take several minutes. A healthy saved configuration is reused at startup; restarting does not force a different region. Recovery prefers eligible endpoints in the saved region, or stays in `PIA_PREFERRED_REGION` when automatic selection is disabled. Follow [region selection](../plundarr/configuration.md#vpn-region-selection) for an intentional change.

## Limits and failure recovery

- A stopped VPN pauses recovery. An unreachable or unauthorized API prevents new registrations.
- Invalid credentials, a provider outage, or an unavailable selected region can prevent recovery.
- Privateerr cannot start stopped containers, repair Docker, or reconnect an application to a replaced Gluetun network.
- A port-forwarding problem alone does not replace an otherwise healthy tunnel. Check qBittorrent's API access and the forwarding hook.

Recreate the full VPN group when replacing Gluetun. `depends_on.restart: true` follows explicit Compose-managed updates; it does not follow every external restart or image replacement. API recovery restarts neither container.

If a storage operation fails, preserve pending/commit files and repair the reported path, permissions, disk, or quota problem. Readiness with existing files does not guarantee future recovery writes. See [storage troubleshooting](troubleshooting.md#recovery-reports-a-storage-error) before deleting any state.

To disable recovery, save any PIA WireGuard configuration files you need, set `PRIVATEERR_AUTO_RECOVER=false`, and recreate the stack. This interrupts traffic and regenerates the saved settings. Gluetun resumes its configured tunnel-health restart policy. Container restart policies alone do not restart unhealthy containers.
