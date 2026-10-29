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

Confirm the startup boundaries:

1. Privateerr and Gluetun share the complete host config directory read/write.
2. Privateerr installs both executable scripts into `/gluetun/scripts/` before becoming healthy.
3. Compose waits for Privateerr's healthcheck rather than only container start.
4. `GLUETUN_ENTRYPOINT_WRAPPER` names the installed wrapper or an existing custom wrapper that can read `privateerr.env` and execute Gluetun's default entrypoint.

Privateerr's health signal means the integration scripts were installed and a saved pair was generated or validated; it proves neither a connected tunnel nor future recovery write access. See [readiness and retained files](config-handoff.md#understand-readiness-and-retained-files).

Run the image-owned readiness probe directly when the Compose health state is unclear:

```sh
docker compose exec privateerr privateerr-healthcheck
```

An exit status of zero means the configured `PRIVATEERR_HEALTHCHECK_MARKER` exists. It is written only after this startup installs the integration scripts and validates the VPN files. Review the selected image, `GLUETUN_ENTRYPOINT_WRAPPER`, and shared mounts together when startup cannot reach that point.

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

Keep `PRIVATEERR_IPV6_DISABLED=1` alongside `PIA_DISABLE_IPV6=yes` so Docker applies the namespace setting before generation and Privateerr avoids redundant upstream writes. Do not hide warnings; check the selected image and Compose settings, then recreate Privateerr. Gluetun's separate `NET_ADMIN` requirement remains unchanged.

## Recovery reports a storage error

Read the first failed operation and its container path in Privateerr's logs. Permission denial, read-only storage, missing paths, disk exhaustion, and quota limits need different fixes. Map the path to its host bind mount; the logged UID/GID and ownership/mode help identify the intended access, but permission denial alone does not prove an ACL problem.

Give the container's UID 0 write and traverse access to the intended output directory, accounting for host UID remapping. A `:rw` mount does not override host permissions. Keep capabilities dropped and `no-new-privileges`; correct the specific mount, space, quota, or permission condition instead of applying `chmod 777`.

Readiness can succeed with a reusable pair despite a failed storage probe; it does not guarantee future recovery writes. Script installation must still succeed. If publication fails after Gluetun accepted a candidate, preserve `.privateerr-pending` and `.privateerr-commit`, repair storage, and let reconciliation finish. Do not delete state or start a concurrent generator. Restarting resets timers but does not repair storage.

Region labels are provider metadata, not measured latency or physical-location proof. Review diagnostics before sharing them.

## qBittorrent does not follow the tunnel

Confirm its listening port and bound VPN interface match Gluetun's current lease. The forwarding hook reports failed application updates and waits only for the configured number of seconds. If the application outlasted that wait, restore its API access and reapply the hook or restart forwarding. A forwarding-only failure does not trigger tunnel rotation.

If Gluetun was replaced outside Compose, recreate the complete VPN namespace and dependent applications. `depends_on.restart: true` follows explicit Compose maintenance, not every Docker or Watchtower restart. `QBITTORRENT_WEBUI_PORT` controls the listener, host mapping, healthcheck, and default forwarding-hook API URL together. Review any explicit `QBITTORRENT_API_URL` override before diagnosing login or CSRF errors. The [networking guide](../../guides/networking-and-vpn.md#shared-network-namespaces) explains the local control traffic and separate VPN peer port.

## Testing the full path

Check ordinary startup with Privateerr readiness, Gluetun's tunnel health, and qBittorrent's synchronized peer port/interface. A healthy tunnel alone does not prove incoming connectivity.

`make test-recovery-api` validates the API/hook in isolation without PIA credentials. Live recovery and e2e suites use credentials, interrupt the VPN, and can replace saved files during cleanup; follow the [Privateerr developer testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/) in a disposable checkout. They do not prove UDP reachability or torrent throughput.
