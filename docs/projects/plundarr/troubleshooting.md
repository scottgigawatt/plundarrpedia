---
title: Troubleshoot Plundarr
description: Find generation, Compose, VPN, permissions, login, and import failures.
icon: material/lifebuoy
---

# Troubleshoot Plundarr

Start with the first failing service. Run commands from the deployed directory containing `docker-compose.yml` and `.env`; inspect logs locally because they can contain secrets.

```sh
docker compose ps
docker compose logs --tail 100 SERVICE
```

Replace `SERVICE` with the service name reported by `ps`.

## Generator problems

Read Maraudarr's first error. A registry or Docker-daemon failure is different from invalid generated Compose. Check that the output folder exists, is mounted at `/output`, and is writable by the `--user` identity. Run the [published-image command](quick-start.md#1-open-the-interactive-generator) with `--pull always` when refreshing the catalog.

Source builds and generator unit tests belong to [developer documentation](https://scottgigawatt.github.io/plundarr/development/maraudarr/). They are not prerequisites for using the published image.

## Compose problems

```sh
docker compose config --quiet
```

Check that `.env` is beside the Compose file, host ports are available, paths refer to this deployment, and the subnet does not overlap another route. Quiet validation avoids printing secrets. Inspect resolved configuration privately only when the error requires it.

## Permission problems

Compare numeric host ownership with the generated user/group settings, then check access to the exact mounted directory. A parent folder being writable does not prove a child database is writable. On NAS hosts, account for ACLs and mapped identities. Do not weaken read-only filesystems or grant broad permissions before identifying the denied path. See [paths and permissions](../../guides/storage-and-permissions.md).

## VPN lane never becomes healthy

Check in order:

1. Privateerr installs its scripts and prepares `config/gluetun/wireguard/wg0.conf` and matching `privateerr.env`.
2. Gluetun reads the complete shared directory and establishes a healthy tunnel.
3. The selected region supports forwarding when `PIA_PF=true`.
4. qBittorrent starts, signs in, and receives the forwarded port/interface.

```sh
docker compose logs --tail 100 privateerr gluetun qbittorrent
```

Use [Privateerr troubleshooting](../privateerr/troubleshooting.md) for the failing step. Repository users can run `make test-vpn PRESET=YOUR-PRESET` against their selected running deployment; that check uses live provider configuration.

## The Web UI is unreachable

Use the host address and `.env` host port in your browser. A downloader sharing `service:gluetun` publishes its port on Gluetun and has no independent container address. Check the host firewall, especially DSM rules for the Compose subnet.

## Homepage login fails

Read the generated password from `.env`; no username is required. Match `HOMEPAGE_EXTERNAL_URL` to the browser URL and `HOMEPAGE_ALLOWED_HOSTS` to its hostname/port without scheme. Recreate Homepage after changes. For HTTPS proxies, preserve host and forwarded scheme. See [Homepage login](homepage.md).

## Kometa or PATTRMM Neo cannot read or write configuration

`KOMETA_RUNTIME_CONFIG_PATH` must name an existing readable YAML file. Maraudarr does not create the external checkout. Neo also needs settings plus writable cache/output, and every selected settings run must complete. See [Duplex configuration](../presets/duplex.md#prepare-pattrmm-neo).

## NZBGet is healthy but managers cannot connect

Use `gluetun:6789` internally, with SSL off and generated `NZBGET_USER`/`NZBGET_PASS`. Keep categories `radarr` and `sonarr` and the internal listener at `6789`; the browser host port is separate. See [NZBGet setup](configuration.md#nzbget-first-run-settings).

## Downloads finish but never import

Check matching container paths, categories, manager read/write permissions, and the final root folder. Default separate mounts import through copies. Keep playback libraries out of incomplete downloads. [Connect your applications](connect-applications.md) shows the default path and internal addresses.

## Safe reset

Stop with `docker compose down` while preserving state. Back up private settings and export databases before destructive cleanup. Repository `make remove-stack` removes scoped Docker resources/cache while preserving application volumes, deployment files, VPN configuration, and backups. `make delete-config` deletes the selected host config tree and exports there. See [updates and backups](upgrading.md); cleanup does not replace recovery.
