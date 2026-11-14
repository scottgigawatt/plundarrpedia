---
title: Configure Plundarr
description: Set host identity, paths, networking, VPN region, and optional application settings.
icon: material/tune-variant
---

# Configure the stack

Edit the generated `.env` for local settings. Change the service selection through Maraudarr, then regenerate the Compose file. The [quick start checklist](quick-start.md#2-edit-the-generated-settings) covers the values needed for your first launch.

## Identity and permissions

Use `id` for the host account that owns your media, then set `DEFAULT_PUID`, `DEFAULT_PGID`, and supplemental `DEFAULT_GROUP`. Confirm that identity can access the mounted directories. Each image handles user/group settings differently; do not change ownership or weaken container hardening to hide an unexplained permission error.

## Path strategy

Downloaders and managers must see shared files at the same container path. Set `HOST_TORRENTS_DOWNLOADS_PATH` to the `torrents` child of `HOST_DOWNLOADS_PATH`; qBittorrent then sees `/downloads/torrents`, matching Radarr/Sonarr. Host config, media, and temporary files have different backup needs. See [paths and permissions](../../guides/storage-and-permissions.md).

## Network choices

Choose a subnet that does not overlap your LAN, another Docker network, or VPN routes. Preset port offsets reduce collisions but do not check host availability. Edit the generated network values together. [Networking and VPN](../../guides/networking-and-vpn.md) explains downloader ports and local API access.

## VPN region selection

`PIA_AUTOCONNECT=true` selects a low-latency eligible region and ignores `PIA_PREFERRED_REGION`. To choose a region, set `PIA_AUTOCONNECT=false` and its PIA region ID in `PIA_PREFERRED_REGION`. Verify port-forwarding support when `PIA_PF=true`; the default fallback ID is `ca`.

Healthy saved settings are reused. Changing `.env` or recreating containers does not replace an existing healthy connection.

> [!CAUTION]
> Intentional regeneration interrupts the stack and replaces its saved VPN settings. Back up needed files and stop the supervisor so only one process writes the shared directory.

From the deployed directory containing `docker-compose.yml` and `.env`, after editing the region settings:

```sh
docker compose stop
docker compose run --rm --no-deps -e PRIVATEERR_AUTO_RECOVER=false -e PRIVATEERR_KEEPALIVE=false privateerr
docker compose up --detach
docker compose ps
```

Confirm the intended region and healthy tunnel in local logs. In Synology Container Manager, stop the project first; for a UI-only change, temporarily disable recovery, rebuild and confirm generation, then restore recovery and rebuild again.

## Automatic VPN recovery

[Automatic recovery](../privateerr/automatic-recovery.md) is enabled when Privateerr and Gluetun are selected. Maraudarr generates the shared key and preserves existing values and explicit opt-outs. Privateerr runs as UID 0 with capabilities dropped; Gluetun separately needs tunnel privileges. Recreate containers when changing their options; pulling an image alone does not apply them.

## Dashboard and monitoring

Set the browser address and sign in with the generated password using [Homepage login](homepage.md). After the primary workflow works, configure [Tracearr monitoring](monitoring.md), which requires its own database backup export.

## Download client selection

qBittorrent is the default torrent client. SABnzbd and NZBGet are optional Usenet clients; they need provider credentials in their own interfaces and do not use PIA's forwarded torrent peer port. All selected download clients share Gluetun's network. Configure each manager's categories and credentials explicitly.

## NZBGet first-run settings

Add provider credentials under **Settings → News-Servers**. `NZBGET_USER` and `NZBGET_PASS` from `.env` protect the Web UI/RPC endpoint, not provider access.

| Setting | Value |
| --- | --- |
| `MainDir` | `/downloads/usenet` |
| `InterDir` | `${MainDir}/incomplete` |
| `DestDir` | `${MainDir}/complete` |
| `radarr` category | `${MainDir}/complete/movies` |
| `sonarr` category | `${MainDir}/complete/tv` |

Managers connect to `gluetun:6789`, without SSL, using those generated credentials. Browsers use `NZBGET_WEBUI_PORT`. Keep the internal port at `6789` to match integrations and healthchecks.

## Music and quality synchronization

Select Lidarr for music or Recyclarr for Radarr/Sonarr quality settings in the picker. Lidarr requires amd64/arm64 and `HOST_MUSIC_PATH`. Recyclarr also selects Radarr/Sonarr and runs only under the `tools` profile.

Set Recyclarr's API keys, review `config/recyclarr/recyclarr.yml`, and start the target applications. From the generated project, preview first:

```sh
docker compose --profile tools run --rm --no-deps recyclarr sync --preview
```

After reviewing the changes, apply deliberately by running the same command without `--preview`. The seed synchronizes quality-size definitions and is preserved on regeneration. Repository users can use `make recyclarr-preview` and `make recyclarr-sync` with the selected `PRESET` instead.

## Secrets

Keep credentials, keys, VPN files, private logs, databases, and webhook URLs out of Git. Use the ignored `.env` for real settings and `example.env` only as a reference.
