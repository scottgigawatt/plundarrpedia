---
title: Portainer
description: Generate a focused Portainer Community Edition deployment for Docker host management.
icon: material/docker
status: new
---

# Portainer preset 🚢

The `portainer` preset runs only Portainer Community Edition, using the official `lts` image channel. It has no VPN or Watchtower dependency.

## Generate and configure

Choose **Portainer** in the [interactive generator](../plundarr/quick-start.md#1-open-the-interactive-generator). The project appears under `dist/portainer/`.

Review `dist/portainer/.env` before launch:

| Setting | Default | Purpose |
| --- | --- | --- |
| `PORTAINER_TAG` | `lts` | Long-term support image channel. |
| `PORTAINER_CONFIG_PATH` | `./config/portainer` | Persistent database and configuration. |
| `PORTAINER_WEB_PORT` | `9443` | HTTPS management interface. |
| `PORTAINER_EDGE_PORT` | `8888` | Host port mapped to the Edge agent tunnel on container port `8000`. |

For an existing installation, back up its data and set `PORTAINER_CONFIG_PATH` to that directory. Stop the previous Portainer server before allowing the new one to use it. Generation does not copy the old data automatically.

```sh
cd dist/portainer
docker compose config --quiet
docker compose up --detach --pull always
```

Open `https://YOUR-HOST:9443`, substituting your configured host and port. Complete the [official initial setup](https://docs.portainer.io/start/install-ce/server/setup), including a setup token if requested by your selected release. The default certificate is self-signed; keep any setup token private.

## Manage access and updates

Portainer receives the host Docker socket and can control containers on that host. Restrict its management interface to trusted administrators. The Edge tunnel port serves Edge agent connections; it is not the browser interface.

Regeneration preserves environment values and Portainer data. Recreate the service after editing `.env`. Portainer is eligible for Watchtower updates on its configured image channel if an existing host updater manages it, even though this preset does not start an updater.

Select it in the picker to add it to another compatible preset. Repository users can use `make ship PRESET=portainer` or `ADD_SERVICES=portainer`, retaining the complete intended selection. Check generated host ports because other presets may offset them.

[Compare presets](index.md){ .md-button }
