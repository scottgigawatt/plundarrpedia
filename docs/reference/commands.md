---
title: Command Deck
description: Quick command reference across Plundarr, Privateerr, Duplex, and Plundarrpedia.
icon: material/console
---

# Command deck

## Plundarr

| Command                 | Purpose                                                 |
| ----------------------- | ------------------------------------------------------- |
| `make ship`             | Generate the default Plundarr project.                  |
| `make configure`        | Open Maraudarr's interactive generator.                 |
| `make presets`          | Show available presets and their service sets.          |
| `make services`         | List selectable services.                               |
| `make config`           | Render and validate the generated Compose project.      |
| `make up` / `make down` | Start or stop the stack.                                |
| `make backup-config`    | Archive persistent service configuration.               |
| `make test-maraudarr`   | Validate generator behavior and representative outputs. |
| `make test-vpn`         | Validate an already-running VPN/download lane.          |
| `make test-e2e`         | Launch and validate the focused live VPN path.          |

## Privateerr

| Command                            | Purpose                                         |
| ---------------------------------- | ----------------------------------------------- |
| `make run-privateerr`              | Generate fresh `wg0.conf` and `privateerr.env`. |
| `make up` / `make down`            | Start or stop Privateerr + Gluetun.             |
| `make env`                         | Print evaluated environment values.             |
| `make config`                      | Render the fully resolved Compose model.        |
| `make reset-config`                | Restore checked-in example generated files.     |
| `make test-e2e` / `make test-down` | Run and clean up live VPN validation.           |
| `make build-multiarch`             | Validate the published CPU architecture set.    |

## Duplex

```console
git clone --recurse-submodules https://github.com/scottgigawatt/duplex.git
cp example.env .env
docker compose config
docker compose up -d
docker compose logs --tail=100 SERVICE
```

## Plundarrpedia

| Command                    | Purpose                                            |
| -------------------------- | -------------------------------------------------- |
| `make serve`               | Run the Compose live-reload authoring service.     |
| `make site`                | Export the static site into `site/` via Compose.   |
| `make clean`               | Delete the generated static site.                  |
| `make build`               | Build the unprivileged Nginx image via Compose.    |
| `make build-multiarch`     | Validate all published platforms.                  |
| `make config`              | Validate the one-file Compose deployment.          |
| `make run` / `make down`   | Start or stop the complete production wiki stack.  |

## Universal diagnostics

```console
docker compose config
docker compose ps
docker compose logs --tail=100 SERVICE
docker inspect CONTAINER
docker network ls
git status --short
```
