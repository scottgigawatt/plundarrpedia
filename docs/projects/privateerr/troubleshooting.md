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

```console
docker compose logs privateerr
docker compose config
```

## The files exist but Gluetun does not start

Confirm all three boundaries:

1. Privateerr and Gluetun mount the same host config directory.
2. Compose waits for Privateerr's healthcheck rather than only container start.
3. The Gluetun wrapper can read `privateerr.env` and execute the default Gluetun
   entrypoint.

Privateerr's health signal means generation finished; it does not mean the VPN
tunnel is connected.

## Port forwarding is unavailable

`PIA_PF=true` requests a compatible region. If metadata says forwarding is not
supported, do not force the rest of the stack to pretend otherwise. Allow
automatic selection or choose a known compatible PIA region, regenerate, and
then restart Gluetun.

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

## Testing the full path

Privateerr's repository includes the test-only Buccaneerr validator:

```console
make test-e2e
make test-down
```

The e2e path uses real credentials when supplied, launches Privateerr and
Gluetun, validates the tunnel and forwarding expectations, and restores example
files during cleanup.

!!! caution
    Always run the cleanup target after live validation and inspect the worktree
    for generated VPN material before committing.
