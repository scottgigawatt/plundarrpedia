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

Current checkouts use HTTPS and need no SSH key for the public PIA repository. A leading `-` in submodule status means it is still uninitialized. If you intentionally keep an older checkout with an SSH submodule URL, set a local HTTPS override before retrying initialization:

```sh
git config submodule.docker/pia-manual-connections.url https://github.com/pia-foss/manual-connections.git
git submodule update --init --recursive
```

## The files exist but Gluetun does not start

Confirm all three boundaries:

1. Privateerr and Gluetun mount the same host config directory.
2. Compose waits for Privateerr's healthcheck rather than only container start.
3. The Gluetun wrapper can read `privateerr.env` and execute the default Gluetun
   entrypoint.

Privateerr's health signal means a saved pair was generated or validated; it does not mean the VPN tunnel is connected. See [readiness and retained files](config-handoff.md#understand-readiness-and-retained-files).

Run the image-owned readiness probe directly when the Compose health state is
unclear:

```sh
docker compose exec privateerr privateerr-healthcheck
```

An exit status of zero means the configured `PRIVATEERR_HEALTHCHECK_MARKER` exists. Current Plundarr-generated deployments select a compatible Privateerr image. If the command is missing, refresh Maraudarr, regenerate the preset, and recreate the affected services before changing the healthcheck.

## Port forwarding is unavailable

`PIA_PF=true` requests a compatible region. If metadata says forwarding is not supported, select an eligible region and follow the [explicit regeneration procedure](../plundarr/configuration.md#vpn-region-selection). With recovery enabled, a healthy saved pair survives ordinary restarts; recreating containers alone does not force a new selection.

For torrent clients, verify the forwarded port reported by Gluetun is also the
listening port used by the client. A healthy tunnel with an unsynchronized
client port still produces poor inbound connectivity.

## Gluetun reports a custom WireGuard error

- Confirm `wg0.conf` is non-empty and current.
- Check that the host clock is correct.
- Verify the config was generated for WireGuard, not OpenVPN.
- Regenerate rather than hand-editing keys or endpoints.
- Treat a suddenly invalid config as secret rotation/runtime state, not a reason
  to commit a replacement.

## Recovery does not start

Check Privateerr's logs for `Automatic recovery enabled`. Both containers need the same `PRIVATEERR_AUTO_RECOVER` setting and API key, the current wrapper or equivalent configuration, and a shared Docker network. Recovery is disabled when an existing image-only deployment omits its flag. Review [the upgrade procedure](automatic-recovery.md#upgrade-a-generated-deployment) for preserved wrappers and image pins.

A deliberately stopped VPN pauses recovery. An unreachable or unauthorized control API prevents new registrations. Startup grace and continuous-failure timing mean recovery is not immediate. Check the configured endpoints without publishing their ports or sharing API responses, which can contain secrets.

## IPv6 writes report permission errors

Use Privateerr v2.1.0 or later with the hardened Compose definition. Keep `PRIVATEERR_IPV6_DISABLED=1` alongside `PIA_DISABLE_IPV6=yes` so Docker applies the settings before the adapter runs. Older images may still attempt sysctl writes after capabilities are dropped. Do not hide the warnings; match the image and chart, then recreate Privateerr. Gluetun's separate `NET_ADMIN` requirement remains unchanged.

## qBittorrent does not follow the tunnel

Confirm its listening port and bound VPN interface match Gluetun's current lease. The forwarding hook reports failed application updates and waits only for the configured number of seconds. If the application outlasted that wait, restore its API access and reapply the hook or restart forwarding. A forwarding-only failure does not trigger tunnel rotation.

If Gluetun was replaced outside Compose, recreate the complete VPN namespace and dependent applications. `depends_on.restart: true` follows explicit Compose maintenance, not every Docker or Watchtower restart. Check that the Web UI port mapping and `WEBUI_PORT` agree before diagnosing login or CSRF errors.

## Testing the full path

Privateerr's repository includes the test-only Buccaneerr validator:

```sh
make test-e2e
make clean-test
```

The e2e path requires real PIA credentials and starts Privateerr, Gluetun, qBittorrent, and Buccaneerr. By default it deliberately interrupts the demo VPN, checks recovery and the restored application port/interface, and restores checked-in examples during cleanup. It does not download torrents or prove UDP reachability or torrent throughput.

For isolated API/hook validation without PIA credentials, run `make test-recovery-api`. Use `make test-recovery-live` for isolated live PIA recovery and incoming-TCP checks. All Privateerr test drivers and lint tools run in Buccaneerr; see the [developer testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/).

> [!CAUTION]
> Always run `make clean-test` after live validation and inspect the worktree for generated VPN material before committing.
