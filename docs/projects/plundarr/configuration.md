---
title: Configure Plundarr
description: Set paths, identity, ports, VPN behavior, and networking without losing the thread.
icon: material/tune-variant
---

# Configure the stack

Treat `.env` as the control panel and `docker-compose.yml` as the generated wiring diagram. Routine local changes belong in `.env`; regenerate the Compose file when you want to change selected services.

## Identity and permissions

Run `id media` for the host account that owns your media, then set `DEFAULT_PUID`, `DEFAULT_PGID`, and service-specific supplemental groups. Confirm access to the actual mounted directories.

Rootless services use generated identity settings directly; LinuxServer-style images use their supported `PUID`/`PGID` entrypoints. Inspect the selected image and generated chart before changing permissions or hardening.

## Path strategy

Use matching container paths for shared files: if the client reports `/downloads/movies/example.mkv`, the manager must see that same path. Keep host media, persistent service config, and temporary files separate. Hardlinks also need compatible mount/filesystem boundaries; follow [paths and permissions](../../guides/storage-and-permissions.md).

## Network choices

Use a private subnet that does not overlap your LAN, another Docker network, or a local/remote VPN route. Generated subnet/port offsets reduce collisions between presets but do not prove availability on your host. Review the actual `.env` before launch.

## VPN region selection

In a generated Plundarr deployment, `PIA_AUTOCONNECT=true` selects a low-latency eligible region automatically and ignores `PIA_PREFERRED_REGION`. To choose a specific region, set `PIA_AUTOCONNECT=false` and `PIA_PREFERRED_REGION` to its PIA region ID in `dist/<preset>/.env`. The generated fallback ID is `ca`; verify that your chosen region supports port forwarding when `PIA_PF=true`.

Recovery-enabled startup reuses a healthy saved pair; recreation alone does not select a new endpoint.

> [!CAUTION]
> The following procedure interrupts the stack and replaces its saved VPN pair. Back up needed files first and stop the supervisor so only one writer owns the directory.

From the Plundarr checkout, replace `YOUR-PRESET`, then stop the stack, generate fresh settings, and recreate:

```sh
docker compose --project-directory dist/YOUR-PRESET stop
docker compose --project-directory dist/YOUR-PRESET run --rm --no-deps -e PRIVATEERR_AUTO_RECOVER=false -e PRIVATEERR_KEEPALIVE=false privateerr
make up PRESET=YOUR-PRESET
make test-vpn PRESET=YOUR-PRESET
```

A plain restart does not reload environment changes, and recreation alone does not rotate a healthy saved connection. For standalone Privateerr, follow its [one-shot generation route](../privateerr/quick-start.md#generate-files-for-another-wireguard-deployment).

In Synology Container Manager, stop the project before generation and rebuild it afterward. For a UI-only change, temporarily set `PRIVATEERR_AUTO_RECOVER=false`, rebuild and verify fresh generation, then restore `true` and rebuild again.

## Automatic VPN recovery

Plundarr enables recovery when the resolved service selection includes Privateerr and Gluetun, including core services and downloader dependencies. Maraudarr generates the private shared API key and preserves existing keys, timing controls, image pins, and explicit opt-outs. See [automatic recovery](../privateerr/automatic-recovery.md) when configuring the generated services or customizing the wrapper.

Generated Privateerr runs without privileged mode. It runs as UID 0 with capabilities dropped, `no-new-privileges`, and Docker-applied namespace IPv6 settings. Gluetun retains its separate tunnel privileges. Keep image and generated-chart versions compatible; an image-only update does not rewrite container options.

## Dashboard and monitoring

Configure [Homepage password login](homepage.md) before opening the dashboard. Tracearr is a removable default in Plundarr; follow [media monitoring](monitoring.md) for first-run setup, Homepage integration, architecture limits, and database backup exports.

## Download client selection

The selected client changes the VPN namespace and service dependencies:

=== "qBittorrent"

    Use for torrents. Gluetun calls Privateerr's hook to synchronize the PIA peer port and VPN interface. See [local control and VPN traffic](../../guides/networking-and-vpn.md#shared-network-namespaces) for listener/API controls, loopback trust, and restart boundaries.

=== "SABnzbd"

    Best for Usenet. It still benefits from the Gluetun network boundary when
    that is your chosen privacy model, but it does not consume PIA's forwarded
    torrent port.

=== "NZBGet"

    A lean Usenet alternative to SABnzbd. It shares Gluetun's network
    namespace, keeps its internal control port at `6789`, and receives a strong
    first-run Web UI password in `.env`.

=== "Several clients"

    Valid when managers may choose either protocol or separate Usenet queues.
    Expect more first-run configuration and be explicit about ports,
    categories, and completed-download handling.

## NZBGet first-run settings

Add provider credentials under **Settings → News-Servers** in NZBGet. Those credentials belong to the application; `NZBGET_USER` and `NZBGET_PASS` in `.env` protect its Web UI and RPC control endpoint.

Keep the generated path vocabulary:

| NZBGet setting  | Value                                     |
| --------------- | ----------------------------------------- |
| `MainDir`       | `/downloads/usenet`                       |
| `InterDir`      | `${MainDir}/incomplete`                   |
| `DestDir`       | `${MainDir}/complete`                     |
| Radarr category | `radarr` → `${MainDir}/complete/movies`   |
| Sonarr category | `sonarr` → `${MainDir}/complete/tv`       |

When adding NZBGet to Radarr or Sonarr, use host `gluetun`, port `6789`, no SSL, and the generated `NZBGET_USER` / `NZBGET_PASS` values. A browser reaches the host-side `NZBGET_WEBUI_PORT`; connected containers use the fixed internal port.

## Music and quality synchronization

Add Lidarr for music or Recyclarr for deliberate Radarr/Sonarr quality synchronization:

```sh
make ship PRESET=plundarr ADD_SERVICES=lidarr,recyclarr
```

Keep any other selected additions and removals in the same command. Set `HOST_MUSIC_PATH` to the host music library. Lidarr supports amd64 and arm64, not arm/v7, and uses the shared downloader paths and Prowlarr integration.

Recyclarr adds Radarr and Sonarr as dependencies and stays behind the `tools` profile. Put their API keys in the generated `.env`, review `dist/plundarr/config/recyclarr/recyclarr.yml`, and start the target applications before previewing:

```sh
make recyclarr-preview PRESET=plundarr
```

The seeded configuration synchronizes quality-size definitions and preserves operator edits on regeneration. Applying it changes the configured applications; inspect the preview before running:

```sh
make recyclarr-sync PRESET=plundarr
```

## Secrets

Keep PIA credentials, API keys, VPN files, webhook URLs, encryption keys, databases, and private logs out of Git. Use `example.env` for reference values and ignored `.env` files or a secret manager for real ones.
