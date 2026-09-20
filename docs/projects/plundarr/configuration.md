---
title: Configure Plundarr
description: Set paths, identity, ports, VPN behavior, and networking without losing the thread.
icon: material/tune-variant
---

# Configure the stack

Treat `.env` as the control panel and `docker-compose.yml` as the generated
wiring diagram. Routine local changes belong in `.env`; regenerate the Compose
file when you want to change selected services.

## Identity and permissions

Linux-based media containers commonly use a numeric user and group ID. On the
host, identify the account that owns the media directories:

```sh
id media
```

Use its numeric values for `DEFAULT_PUID` and `DEFAULT_PGID`. Review each generated supplemental-group setting, then confirm that downloads, final libraries, and `dist/<preset>/config/` are writable where appropriate.

Plundarr applies these settings in two deliberate ways:

- Rootless services such as Apprise and Seerr run directly with the generated user, group, and supplemental-group settings.
- LinuxServer-style services continue receiving `PUID` and `PGID` through
  their supported entrypoint environment rather than a blanket Compose
  `user:` override.

Refresh Maraudarr and regenerate an older Compose file before troubleshooting runtime identity. Do not weaken host ownership or container hardening to compensate for a stale generated chart.

## Path strategy

The most reliable strategy uses one shared host root and consistent container
paths:

| Host example           | Container path | Used by                          |
| ---------------------- | -------------- | -------------------------------- |
| `/srv/media/downloads` | `/downloads`   | Download clients, Radarr, Sonarr |
| `/srv/media/movies`    | `/movies`      | Radarr, Plex/Jellyfin            |
| `/srv/media/tv`        | `/tv`          | Sonarr, Plex/Jellyfin            |
| `./config/radarr`      | `/config`      | Radarr only                      |

Do not map the same host download directory as `/data` in one container and
`/downloads` in another unless you also configure remote-path mappings. A
single vocabulary makes imports, hardlinks, and troubleshooting easier.

## Network choices

Choose a private subnet that does not overlap:

- your home LAN;
- an employer or travel VPN;
- another Docker network;
- a remote site you route to.

The default Plundarr preset uses `172.20.0.0/16` with a smaller container allocation range. Other presets use separate allocations through `172.28.0.0/16`; Watchtower uses `172.26.0.0/16`, Portainer uses `172.27.0.0/16`, and Custom uses `172.28.0.0/16`. These are collision-avoiding defaults, not universal requirements.

## VPN region selection

In a generated Plundarr deployment, `PIA_AUTOCONNECT=true` selects a low-latency eligible region automatically and ignores `PIA_PREFERRED_REGION`. To choose a specific region, set `PIA_AUTOCONNECT=false` and `PIA_PREFERRED_REGION` to its PIA region ID in `dist/<preset>/.env`. The generated fallback ID is `ca`; verify that your chosen region supports port forwarding when `PIA_PF=true`.

Recreate the affected VPN lane after changing these values, then run `make test-vpn PRESET=YOUR-PRESET`. A plain restart does not reload environment changes. Privateerr generates the handoff; Gluetun establishes the tunnel.

## Dashboard and monitoring

Configure [Homepage password login](homepage.md) before opening the dashboard. Tracearr is a removable default in Plundarr; follow [media monitoring](monitoring.md) for first-run setup, Homepage integration, architecture limits, and database backup exports.

## Download client selection

The selected client changes the VPN namespace and service dependencies:

=== "qBittorrent"

    Best when the automation lane retrieves torrents. Its listening port may
    need to follow the port assigned by PIA/Gluetun.

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

Add provider credentials under **Settings → News-Servers** in NZBGet. Those
credentials belong to the application; `NZBGET_USER` and `NZBGET_PASS` in
`.env` protect its Web UI and RPC control endpoint.

Keep the generated path vocabulary:

| NZBGet setting  | Value                                     |
| --------------- | ----------------------------------------- |
| `MainDir`       | `/downloads/usenet`                       |
| `InterDir`      | `${MainDir}/incomplete`                   |
| `DestDir`       | `${MainDir}/complete`                     |
| Radarr category | `radarr` → `${MainDir}/complete/movies`   |
| Sonarr category | `sonarr` → `${MainDir}/complete/tv`       |

When adding NZBGet to Radarr or Sonarr, use host `gluetun`, port `6789`, no
SSL, and the generated `NZBGET_USER` / `NZBGET_PASS` values. A browser reaches
the host-side `NZBGET_WEBUI_PORT`; connected containers use the fixed internal
port.

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

Keep these out of Git:

- PIA username and password;
- application API keys;
- generated WireGuard files and endpoint metadata;
- notification credentials and webhook URLs;
- Duplicati encryption material;
- real service databases and logs.

Use `example.env` to document variable names and safe examples. Use ignored
`.env` files or an external secret-management workflow for real values.
