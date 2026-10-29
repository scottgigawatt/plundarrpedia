---
title: Automatic recovery
description: Configure and troubleshoot Privateerr recovery without adding a service or replacing the VPN namespace.
icon: material/shield-refresh
status: new
---

# Recover stale VPN connections 🛟

Privateerr's supervisor replaces stale PIA settings through Gluetun's authenticated API after a sustained tunnel failure. Containers and their shared network namespace stay in place, but connections can disconnect while the tunnel changes.

## Choose the right setup

| Deployment | Recovery default | Shared API key |
| --- | --- | --- |
| Plundarr with Privateerr and Gluetun | Enabled | Generated in private `.env`; preserved on regeneration |
| Generated Privateerr without Gluetun | Disabled for a fresh deployment | Review preserved settings when changing selection |
| Privateerr standalone example | Enabled | Generate and set it in `.env` |
| Custom image-only deployment | Disabled | Set the flag and key explicitly |

Existing image pins and explicit opt-outs survive regeneration. Follow the [quick start](quick-start.md) for ordinary startup.

## Understand the sequence

Privateerr waits through startup grace and continuous health failure, validates a replacement, applies it through Gluetun's API, then saves the pair after settings readback and tunnel-health confirmation. An uncertain response retains a candidate for reconciliation instead of causing another registration. Gluetun's hook updates qBittorrent's peer port and interface.

## Configure a generated deployment

Back up the private `.env` and application state. Select the intended [generator](../plundarr/quick-start.md#choose-the-generator), then run from the Plundarr checkout:

```sh
make ship PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Replace `YOUR-PRESET` and repeat your complete `ADD_SERVICES` / `REMOVE_SERVICES` selection, or review it in `make configure`. Keep resolved Compose output private. Regeneration preserves existing settings and application data; `example.env` contains no generated keys.

Privateerr installs `gluetun-entrypoint-wrapper.sh` and `qbittorrent-port-forwarding.sh` in the shared `/gluetun/scripts/` before readiness. These two filenames are replaced from the selected image on startup. Keep custom scripts under different names. The default wrapper path is `/gluetun/scripts/gluetun-entrypoint-wrapper.sh`.

> [!IMPORTANT]
> A custom wrapper must supply the current metadata, internal health-listener, and authenticated recovery-role behavior. Check the [packaged wrapper contract](https://github.com/scottgigawatt/privateerr/blob/v2.3.1/docker/gluetun/gluetun-entrypoint-wrapper.sh), or disable recovery. An operator-managed `/gluetun/auth/config.toml` must include the shared key and [required routes](https://scottgigawatt.github.io/privateerr/automatic-recovery/#configure-a-custom-deployment); the wrapper preserves that file.

Check the image, shared key, wrapper, and writable mounts together before recreating the complete stack:

```sh
make up PRESET=YOUR-PRESET
make test-vpn PRESET=YOUR-PRESET
```

In Synology Container Manager, rebuild the existing project with its reviewed Compose file and `.env`. A restart does not reload environment changes. Confirm `Automatic recovery enabled`, followed by `Gluetun tunnel is healthy`, in Privateerr's logs. Keep keys, API responses, and VPN files private.

## Configure timing and region policy

Edit `.env`; all four values below are in seconds. The generated Compose comments explain behavior and units.

| Setting | Default | Purpose |
| --- | --- | --- |
| `PRIVATEERR_RECOVERY_INTERVAL_SECONDS` | `30` | Health-probe interval |
| `PRIVATEERR_RECOVERY_FAILURE_SECONDS` | `120` | Startup grace and continuous-failure threshold |
| `PRIVATEERR_RECOVERY_COOLDOWN_SECONDS` | `300` | Initial retry delay, increasing to one hour |
| `PRIVATEERR_GENERATION_TIMEOUT_SECONDS` | `180` | Maximum PIA generation time |

Detection can take several minutes. A healthy probe resets outage tracking; restarting the supervisor resets timers but retains pending candidates.

Recovery-enabled startup reuses a valid saved pair. Automatic recovery prefers eligible endpoints in its saved region; it does not rerun startup latency selection. With `PIA_AUTOCONNECT=false`, recovery stays in `PIA_PREFERRED_REGION`. `PIA_PF=true` requires forwarding support; dedicated-IP setups keep their endpoint.

Changing `.env` does not rotate a healthy connection. Use the [explicit regeneration procedure](../plundarr/configuration.md#vpn-region-selection) for an immediate region/server change, stopping the supervisor first.

## Keep privileges and restart policies distinct

Privateerr runs as UID 0 for PIA's scripts, with all capabilities dropped and `no-new-privileges`. Keep `PRIVATEERR_IPV6_DISABLED=1` with `PIA_DISABLE_IPV6=yes`; Docker applies the namespace setting so redundant upstream writes can be skipped. Gluetun separately needs `NET_ADMIN` and `/dev/net/tun`. Recreate services when changing container options; image updates alone do not apply them.

Container restart policies do not restart an unhealthy container merely because its healthcheck fails. qBittorrent's `depends_on.gluetun.restart: true` follows explicit Compose-managed Gluetun updates, not every Docker restart or Watchtower replacement. API recovery restarts neither container. After replacing Gluetun outside that path, recreate the full VPN namespace and dependent applications.

## Know when recovery cannot help

- A stopped VPN pauses recovery; an unreachable or unauthorized API prevents new registrations.
- Invalid credentials, a provider outage, or an unavailable pinned region can prevent recovery.
- Privateerr cannot start a stopped Gluetun container, repair Docker, or reconnect an application to an orphaned namespace.
- A forwarding-only failure does not rotate a healthy tunnel. Restore qBittorrent's API and reapply the hook or restart forwarding if its readiness wait expired.
- Only one supervisor or generator may write the saved pair.

To opt out, preserve needed files, set `PRIVATEERR_AUTO_RECOVER=false`, and recreate the full stack. This interrupts traffic and replaces the saved pair; Gluetun resumes its configured health-restart policy. Recovery requires `PRIVATEERR_KEEPALIVE=true`, `PIA_CONNECT=false`, WireGuard, and Privateerr outside Gluetun's namespace.

## Check recovery storage and readiness

Startup must install the scripts. A failed disposable storage probe can warn while a valid saved pair still permits readiness; readiness does not guarantee future recovery writes. Without reusable files, a storage failure prevents generation. Other startup failures can also prevent readiness.

Map the logged container path to its host mount and correct the specific permission, read-only, disk, or quota problem. Retain pending/commit state; do not grant broad `chmod 777` access or remove hardening. See [storage troubleshooting](troubleshooting.md#recovery-reports-a-storage-error) and the [developer architecture](https://scottgigawatt.github.io/privateerr/development/privateerr/architecture/) for publication details.
