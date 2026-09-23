---
title: Automatic recovery
description: Enable, upgrade, and troubleshoot Privateerr recovery without adding a service or replacing the VPN namespace.
icon: material/shield-refresh
status: new
---

# Recover stale VPN connections 🛟

Privateerr v2.1.0 adds a Python supervisor inside the existing container. After a sustained Gluetun tunnel failure, it requests fresh PIA WireGuard settings and applies them through Gluetun's authenticated control API. Gluetun owns the tunnel, firewall, DNS, and forwarded port. No extra recovery container, web server, or Docker socket is needed.

The Gluetun container and the network namespace shared by download clients stay in place. Connections can still disconnect while the internal VPN tunnel changes; recovery is not a promise of uninterrupted downloads.

## Choose the right setup

| Deployment | Recovery default | Shared API key |
| --- | --- | --- |
| Plundarr/Maraudarr v2.1.0 with Privateerr and Gluetun selected | Enabled, including core services and downloader dependencies | Generated in the private deployment `.env`; preserved on regeneration. |
| Generated Privateerr without Gluetun | Disabled for a fresh deployment | No tunnel to monitor; review preserved settings if changing an existing service selection. |
| Privateerr repository example | Enabled alongside Gluetun, qBittorrent, and Buccaneerr | Generate and set it in `.env` before starting. |
| Existing custom deployment with no recovery variable | Disabled | An image update alone does not opt in. |

Plundarr preserves existing image pins and explicit recovery opt-outs. Verify that `PRIVATEERR_TAG` selects v2.1.0 or a later compatible release before adopting the new generated settings. The standalone [quick start](quick-start.md) covers one-shot generation and the complete test example.

## Understand the sequence

<ol class="handoff-timeline">
  <li><strong>🧭 Monitor the tunnel.</strong> Wait through startup grace and measure continuous Gluetun health failures.</li>
  <li><strong>Prepare a candidate.</strong> Generate and validate replacement PIA settings while retaining the saved configuration.</li>
  <li><strong>🛡️ Apply through the API.</strong> Send the candidate to Gluetun without recreating the containers or network namespace.</li>
  <li><strong>Confirm the result.</strong> Read back connection settings and require a healthy tunnel. If the result is uncertain, retain the candidate and reconcile before another attempt.</li>
  <li><strong>📁 Save and continue.</strong> Publish the matching file pair after confirmation, then resume monitoring. Gluetun manages the forwarded port.</li>
</ol>

Privateerr waits through startup grace, then measures continuous tunnel failure. A lost API response does not prove that an update failed: the supervisor checks Gluetun's active settings before generating another candidate. It saves new files only when the connection fields match and the tunnel is healthy. Gluetun's forwarding hook then keeps qBittorrent's listening port and VPN interface synchronized.

## Upgrade a generated deployment

Back up the private `.env` and application state, then update the Maraudarr image to v2.1.0 or a later compatible release. From the Plundarr checkout, regenerate the selected preset:

```sh
make pull-image
make ship PRESET=YOUR-PRESET
make config PRESET=YOUR-PRESET
```

Replace `YOUR-PRESET` and repeat the full `ADD_SERVICES` / `REMOVE_SERVICES` selection, or review it with `make configure`. Regeneration adds missing controls, generates the shared key when absent, and preserves existing values and application data. `example.env` contains no generated credentials. Resolved Compose output can contain secrets; review it locally.

Maraudarr replaces only the exact unchanged Gluetun wrapper shipped immediately before recovery support. Customized, symlinked, and older unrecognized wrappers remain operator-owned.

> [!IMPORTANT]
> Before recreating a deployment with a preserved custom wrapper, update it to the [current Gluetun wrapper](https://github.com/scottgigawatt/plundarr/blob/main/docker/services/gluetun/config/scripts/gluetun-entrypoint-wrapper.sh), or set `PRIVATEERR_AUTO_RECOVER=false`. If you own Gluetun's API authentication file, add the recovery role described in [Privateerr's authentication guide](https://scottgigawatt.github.io/privateerr/automatic-recovery/#configure-a-custom-deployment). The wrapper preserves custom authentication.

Check the image pin, shared key, wrapper, and writable config mounts, then recreate the full selected stack:

```sh
make up PRESET=YOUR-PRESET
make test-vpn PRESET=YOUR-PRESET
```

In Synology Container Manager, rebuild the existing project with its regenerated Compose file and `.env`. A plain container restart does not reload environment settings. Look for `Automatic recovery enabled` and then `Gluetun tunnel is healthy` in Privateerr's logs. Keep the API key, settings responses, and VPN files out of support reports.

## Configure timing and region policy

Edit the deployment's `.env`; the Compose file describes behavior and units beside each setting. Defaults belong in environment files, so a standalone Compose upgrade must copy missing values from `example.env` without overwriting credentials or local paths.

| Setting | Default | Meaning |
| --- | --- | --- |
| `PRIVATEERR_RECOVERY_INTERVAL_SECONDS` | `30` | Seconds between health probes. |
| `PRIVATEERR_RECOVERY_FAILURE_SECONDS` | `120` | Startup grace and continuous failure threshold, in seconds. |
| `PRIVATEERR_RECOVERY_COOLDOWN_SECONDS` | `300` | Initial retry delay in seconds; failures increase it up to one hour. |
| `PRIVATEERR_GENERATION_TIMEOUT_SECONDS` | `180` | Maximum seconds for one PIA generation. |

Detection can take several minutes because Gluetun must first report a failure and Privateerr then applies its own threshold. A healthy probe resets outage tracking. A monotonic clock measures elapsed time independently of the system date, so correcting the host clock cannot shorten the cooldown. Timers restart when the supervisor process restarts; retained pending files are checked separately.

Both Compose examples expose `PIA_AUTOCONNECT` and `PIA_PREFERRED_REGION`, defaulting to automatic selection and preferred region `ca`. With automatic selection disabled, recovery stays within the pinned region. Automatic recovery prefers eligible endpoints in the saved region before considering other regions; it does not repeat the startup latency benchmark. `PIA_PF=true` limits selection to regions advertising forwarding. Dedicated-IP setups keep their dedicated endpoint.

A healthy saved connection is reused at startup. To change its region immediately, follow the [explicit regeneration procedure](../plundarr/configuration.md#vpn-region-selection); changing `.env` alone sets future selection policy but does not rotate the current healthy tunnel.

## Keep privileges and restart policies distinct

Privateerr runs as UID 0 because PIA's unmodified scripts require it, but the supplied service drops all Linux capabilities and enables `no-new-privileges`. Docker applies `PRIVATEERR_IPV6_DISABLED=1` to Privateerr's own network namespace; `0` leaves IPv6 enabled. Keep the default alongside `PIA_DISABLE_IPV6=yes` so the adapter can skip redundant upstream writes without filtering warnings. Gluetun separately retains `/dev/net/tun` and `NET_ADMIN` for the tunnel.

An image-only update, including Watchtower, preserves existing container options. Old `privileged: true` settings remain compatible but are not removed automatically. Recovery stays disabled if its flag was absent. Update the Compose definition and recreate the container to adopt hardening. The bundled VPN services disable unattended Watchtower updates through labels.

Privateerr, Gluetun, and qBittorrent use `restart: unless-stopped` for exited containers and host restarts. Docker health failure alone does not restart a container. qBittorrent's `depends_on.gluetun.restart: true` follows explicit Compose-managed Gluetun restarts or updates; it does not follow every runtime restart or Watchtower replacement. API-based recovery does not restart either container. Recreate the full VPN namespace and dependent applications when replacing Gluetun outside that path.

## Know when recovery cannot help

- A deliberately stopped VPN pauses recovery. Failed control-API authentication or an unreachable API does not trigger repeated PIA registration.
- Invalid PIA credentials, a PIA outage, or an entirely unavailable pinned region can prevent recovery.
- The supervisor cannot start a stopped Gluetun container, fix a hung Docker daemon, or repair an application attached to an orphaned namespace.
- A forwarding-only failure does not rotate a healthy tunnel. If qBittorrent remains unavailable longer than the forwarding hook's wait, restore the application and reapply the current port or restart forwarding.
- Only one Privateerr process should own the saved pair. Do not run one-shot generation alongside its supervisor, or delete pending recovery directories while it is running.

The discussion's external watchdog approach can restart unhealthy containers through the Docker socket. Privateerr deliberately handles stale PIA settings within the existing service instead. See the [scenario comparison](https://scottgigawatt.github.io/privateerr/automatic-recovery/#compare-with-the-discussions-watchdog-setup) for the different boundaries.

To opt out, set `PRIVATEERR_AUTO_RECOVER=false` and recreate both services as part of the full stack. Gluetun resumes its configured health-restart policy, and Privateerr generates fresh files at startup. Recovery requires `PRIVATEERR_KEEPALIVE=true`, `PIA_CONNECT=false`, and WireGuard; keep Privateerr outside Gluetun's VPN namespace so it can reach PIA during an outage.

For implementation details, use the [supervisor architecture](https://scottgigawatt.github.io/privateerr/development/privateerr/architecture/) and [Python reference](https://scottgigawatt.github.io/privateerr/development/privateerr/reference/). The wiki focuses on operating the deployment; those pages document the program's contracts and tests.
