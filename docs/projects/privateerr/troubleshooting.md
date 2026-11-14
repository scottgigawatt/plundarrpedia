---
title: Troubleshoot Privateerr
description: Find the first failing container, then check credentials, VPN startup, port forwarding, or recovery storage.
icon: material/lifebuoy
---

# Troubleshoot Privateerr

From the directory containing the deployed Compose file, check status, then the first failing service's logs. Review them locally; they may contain passwords or VPN details.

```sh
docker compose ps
docker compose logs --tail 100 privateerr gluetun qbittorrent
```

## The generator exits before writing files

Read Privateerr's first direct error. Check PIA credentials, outbound DNS/HTTPS, region port-forwarding support, and write access to the shared directory. Use the PIA VPN username, not your email. Validate settings without displaying them:

```sh
docker compose config --quiet
```

For a source build error about missing PIA scripts, follow [the developer build setup](https://scottgigawatt.github.io/privateerr/development/privateerr/). Published-image startup does not need the source submodule.

## The files exist but Gluetun does not start

Privateerr must install its two integration scripts before its healthcheck succeeds. Both containers must share the complete configuration directory read/write, and Gluetun must use the installed wrapper. Check `GLUETUN_ENTRYPOINT_WRAPPER`, selected image, and mounts together.

```sh
docker compose exec privateerr privateerr-healthcheck
```

Zero exit status means the startup readiness marker exists; it does not prove a connected tunnel or future recovery write access. [Configuration handoff](config-handoff.md) explains the files and mounts.

## Port forwarding is unavailable

Keep `PIA_PF=true` and choose a compatible region. Healthy saved settings survive restarts; use the [region regeneration procedure](../plundarr/configuration.md#vpn-region-selection) when intentionally changing them. Verify that Gluetun's forwarded port matches qBittorrent's listening port.

## Gluetun reports a custom WireGuard error

Confirm `wg0.conf` exists, is non-empty, and uses WireGuard; check the host clock. Regenerate configuration rather than editing keys or endpoints by hand. Save any PIA WireGuard configuration files you need and stop other Privateerr containers writing to the same directory first.

## Recovery does not start

Look for `Automatic recovery enabled` in Privateerr's logs. Check matching API keys and recovery flags, current wrapper, internal network access, and timing in [automatic recovery](automatic-recovery.md). A stopped VPN pauses recovery; an unreachable or unauthorized API prevents registration. Do not publish control ports or share API responses to diagnose it.

## IPv6 writes report permission errors

Use `PRIVATEERR_IPV6_DISABLED=1` with `PIA_DISABLE_IPV6=yes`. Docker applies the namespace setting before startup so Privateerr can skip redundant upstream writes. Recreate Privateerr after correcting settings; do not grant it Gluetun's `NET_ADMIN` capability.

## Recovery reports a storage error

Use the logged operation and container path to locate the host mount. Permission denial, read-only storage, disk exhaustion, and quotas need different fixes. Container UID 0 needs write/traverse access even when the mount says `:rw`; host UID mapping or ACLs may affect that access.

Preserve `.privateerr-pending` and `.privateerr-commit`. Gluetun may already use new settings even when saving them failed. Repair storage and allow reconciliation; do not delete retained state, start another generator, or use `chmod 777`. Existing files can permit startup readiness despite a failed storage probe.

See [Privateerr's detailed storage diagnostics](https://scottgigawatt.github.io/privateerr/SUPPORT/) for further checks. Region labels are provider metadata, not measured latency or physical-location proof.

## qBittorrent does not follow the tunnel

The forwarding hook updates qBittorrent's port and VPN interface through its local API. It waits for the configured timeout. If qBittorrent starts too late, repair API access and reapply the hook or restart forwarding. A port-forwarding-only failure does not replace a healthy tunnel.

`QBITTORRENT_WEBUI_PORT` coordinates the listener, host mapping, healthcheck, and default hook URL. Review explicit `QBITTORRENT_API_URL` overrides. The seeded API trusts loopback; every application sharing Gluetun's network shares that trust boundary. See [networking and VPN](../../guides/networking-and-vpn.md#shared-network-namespaces).

If Gluetun was replaced externally, recreate the full VPN group and dependent applications together. Compose-managed restart dependencies do not follow every Docker or Watchtower replacement.

## Testing the full path

Use the [quick start checks](quick-start.md#3-confirm-the-vpn-and-open-qbittorrent) for ordinary operation. Fault tests deliberately interrupt the VPN and can replace saved settings; run them only in an isolated environment under the [developer testing guide](https://scottgigawatt.github.io/privateerr/development/privateerr/testing/).
