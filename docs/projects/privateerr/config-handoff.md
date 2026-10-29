---
title: Configuration handoff
description: Follow PIA configuration through startup, authenticated recovery, and verified file publication.
icon: material/file-swap
status: updated
---

# Configuration handoff

Privateerr shares files with Gluetun at startup and uses its authenticated API during recovery. Gluetun owns the tunnel; rewriting a file alone does not reconfigure a running tunnel.

1. Privateerr installs its two image-owned integration scripts.
2. It validates and reuses the saved VPN pair when recovery is enabled, or generates fresh settings.
3. Its startup healthcheck allows Gluetun to start.
4. Gluetun's wrapper reads the matching metadata and configures recovery authentication.
5. Gluetun starts the tunnel; network-sharing download clients start after it is healthy.
6. During sustained failure, Privateerr applies a candidate through the API and saves it after settings readback and tunnel-health confirmation.

## Why the metadata exists

`wg0.conf` contains WireGuard settings; `privateerr.env` supplies the matching PIA server identity needed for forwarding. Its generation timestamp does not change when a valid saved pair is reused. Age alone does not make a healthy connection stale. Keep both real files private.

## Understand readiness and retained files

Privateerr's startup marker means it installed the scripts and produced or validated the saved pair. It does not certify tunnel health or future recovery write access; Gluetun has its own healthcheck.

The supervisor retains `.privateerr-pending/` and `.privateerr-commit/` beside the pair when an update or save needs reconciliation. If publication fails, the running tunnel may already use newer settings than the saved files. Preserve those directories, repair the reported storage problem, and allow reconciliation. Do not delete retained state or run another writer. See [storage diagnostics](troubleshooting.md#recovery-reports-a-storage-error).

## Important variables

Set credentials, region policy, recovery flag, and the shared key in the private deployment `.env`. Keep `PIA_CONNECT=false` and `PRIVATEERR_KEEPALIVE=true` for recovery. Gluetun uses `VPN_SERVICE_PROVIDER=custom`.

See [region changes](../plundarr/configuration.md#vpn-region-selection), [recovery timing and authentication](automatic-recovery.md), and the [Privateerr configuration reference](https://scottgigawatt.github.io/privateerr/advanced-usage/) for complete settings. Generated Compose comments explain behavior and units.

## Mount the shared directory

Share the complete Gluetun configuration directory read/write: Privateerr mounts it at `/gluetun`; Gluetun mounts the same directory at `/gluetun` and `/tmp/gluetun`. Directory mounts support atomic replacement and retain recovery state. Privateerr's UID 0 needs write/traverse access; Gluetun needs read/execute access to the scripts. Only one supervisor may own the pair.

Privateerr replaces `scripts/gluetun-entrypoint-wrapper.sh` and `scripts/qbittorrent-port-forwarding.sh` from its image on startup. Keep operator scripts under other names. A preserved custom `GLUETUN_ENTRYPOINT_WRAPPER` must satisfy the [recovery contract](automatic-recovery.md#configure-a-generated-deployment).

Keep Privateerr on the project network, outside Gluetun's namespace, so it can contact PIA during an outage. Keep Gluetun's control and health endpoints internal.
