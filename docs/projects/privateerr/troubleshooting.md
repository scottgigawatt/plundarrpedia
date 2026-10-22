---
title: Troubleshoot Privateerr
description: Diagnose PIA credentials, endpoint selection, generated files, Gluetun startup, and port forwarding.
icon: material/lifebuoy
---

# Troubleshoot Privateerr

## The generator exits before writing files

Check the Privateerr log for the first direct error. Common causes include:

- invalid PIA credentials;
- outbound DNS or HTTPS blocked on the Docker host;
- a requested region that cannot satisfy port forwarding;
- the shared config directory is not writable;
- the upstream submodule was not cloned for a local image build.

```sh
make logs
make config
```

## A local build cannot find the PIA scripts

If the build cannot copy `docker/pia-manual-connections/LICENSE`, initialize the public submodule from the Privateerr repository root:

```sh
git submodule sync --recursive
git submodule update --init --recursive
git submodule status
```

The public submodule uses HTTPS and needs no SSH key. A leading `-` in submodule status means it is still uninitialized.

## The files exist but Gluetun does not start

Confirm all three boundaries:

1. Privateerr and Gluetun mount the same host config directory.
2. Compose waits for Privateerr's healthcheck rather than only container start.
3. The Gluetun wrapper can read `privateerr.env` and execute the default Gluetun
   entrypoint.

Privateerr's health signal means a saved pair was generated or validated; it proves neither a connected tunnel nor future recovery write access. See [readiness and retained files](config-handoff.md#understand-readiness-and-retained-files).

Run the image-owned readiness probe directly when the Compose health state is unclear:

```sh
docker compose exec privateerr privateerr-healthcheck
```

An exit status of zero means the configured `PRIVATEERR_HEALTHCHECK_MARKER` exists. Current Plundarr-generated deployments select a compatible Privateerr image. If the command is missing, refresh Maraudarr, regenerate the preset, and recreate the affected services before changing the healthcheck.

## Port forwarding is unavailable

`PIA_PF=true` requests a compatible region. If metadata says forwarding is not supported, select an eligible region and follow the [explicit regeneration procedure](../plundarr/configuration.md#vpn-region-selection). With recovery enabled, a healthy saved pair survives ordinary restarts; recreating containers alone does not force a new selection.

For torrent clients, verify the forwarded port reported by Gluetun is also the listening port used by the client. A healthy tunnel with an unsynchronized client port still produces poor inbound connectivity.

## Gluetun reports a custom WireGuard error

- Confirm `wg0.conf` is non-empty and current.
- Check that the host clock is correct.
- Verify the config was generated for WireGuard, not OpenVPN.
- Regenerate rather than hand-editing keys or endpoints.
- Treat a suddenly invalid config as secret rotation/runtime state, not a reason
  to commit a replacement.

## Recovery does not start

Check Privateerr's logs for `Automatic recovery enabled`. Both containers need the same `PRIVATEERR_AUTO_RECOVER` setting and API key, the current wrapper or equivalent configuration, and a shared Docker network. Image-only deployments must set the recovery flag explicitly. Review [the recovery requirements](automatic-recovery.md#configure-a-generated-deployment) for preserved wrappers and image pins.

A deliberately stopped VPN pauses recovery. An unreachable or unauthorized control API prevents new registrations. Startup grace and continuous-failure timing mean recovery is not immediate. Check the configured endpoints without publishing their ports or sharing API responses, which can contain secrets.

## IPv6 writes report permission errors

Keep `PRIVATEERR_IPV6_DISABLED=1` alongside `PIA_DISABLE_IPV6=yes` so Docker applies the namespace setting before the adapter runs and avoids redundant upstream writes. Do not hide warnings; check the selected image and Compose settings, then recreate Privateerr. Gluetun's separate `NET_ADMIN` requirement remains unchanged.

## Recovery reports a storage error

Read the first failed operation and its container path in Privateerr's logs. Permission denial, read-only storage, missing paths, disk exhaustion, and quota limits need different fixes. Map the path to its host bind mount; the logged UID/GID and ownership/mode help identify the intended access, but permission denial alone does not prove an ACL problem.

Give the container's UID 0 write and traverse access to the intended output directory, accounting for host UID remapping. A `:rw` mount does not override host permissions. Keep capabilities dropped and `no-new-privileges`; correct the specific mount, space, quota, or permission condition instead of applying `chmod 777`.

With a reusable pair, a failed disposable storage probe can warn while startup still becomes ready. Other startup operations can fail independently, and readiness does not guarantee recovery can save files later. A leftover `.privateerr-check.*` directory can indicate interrupted probe cleanup.

If Gluetun accepted a candidate but local publication failed, the running tunnel may already use settings newer than the saved pair. Preserve `.privateerr-pending` and `.privateerr-commit`, repair the reported storage issue, and let the supervisor reconcile settings/health and retry publication. Do not delete retained state or run another writer to clear the warning. New registrations use a cooldown; retained-candidate reconciliation can retry on subsequent monitoring cycles. Restarting Privateerr resets timers but does not repair storage or force a new registration.

Region messages report the provider-advertised saved or candidate region. `unknown` can mean an optional label is missing; it is not proof of invalid keys. Region names are not measured latency or proof of physical server location. Review even sanitized diagnostics before sharing operational paths or region information.

## qBittorrent does not follow the tunnel

Confirm its listening port and bound VPN interface match Gluetun's current lease. The forwarding hook reports failed application updates and waits only for the configured number of seconds. If the application outlasted that wait, restore its API access and reapply the hook or restart forwarding. A forwarding-only failure does not trigger tunnel rotation.

If Gluetun was replaced outside Compose, recreate the complete VPN namespace and dependent applications. `depends_on.restart: true` follows explicit Compose maintenance, not every Docker or Watchtower restart. Check that the Web UI port mapping and `WEBUI_PORT` agree before diagnosing login or CSRF errors.

## Testing the full path

Ordinary `make up` starts the application services only. `make test` runs credential-free repository checks inside Buccaneerr with runtime networking disabled; the initial build may fetch dependencies. For opt-in live fault validation, use a disposable checkout and accept a deliberate VPN interruption before running:

```sh
make test-e2e
make clean-test
```

The e2e path requires real PIA credentials and enables the `test` profile for Privateerr, Gluetun, qBittorrent, and Buccaneerr. It checks recovery and the restored application port/interface. `make clean-test` restores checked-in examples only after successful shutdown; restoration overwrites the saved pair. These tests do not download torrents or prove UDP reachability or torrent throughput.

For isolated API/hook validation without PIA credentials, run `make test-recovery-api`. Use `make test-recovery-live` for isolated live PIA recovery and incoming-TCP checks. All Privateerr test drivers and lint tools run in Buccaneerr; see the [developer testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/).

> [!CAUTION]
> Always run `make clean-test` after live validation and inspect the worktree for generated VPN material before committing.
