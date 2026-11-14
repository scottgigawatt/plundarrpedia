---
title: Watchtower
description: Run the maintained Watchtower image as a persistent Plundarr preset or a deliberate update pass.
icon: material/telescope
status: updated
---

# Watchtower preset 🔭

The Watchtower preset generates one focused project for eligible container updates on a Docker host. Plundarr uses the maintained `nickfedor/watchtower` image and supports either a persistent daemon or an explicit update pass that exits.

## Run the persistent preset

Choose **Watchtower** in the [interactive generator](../plundarr/quick-start.md#1-open-the-interactive-generator). Review the update policy in `dist/watchtower/.env`, then from the parent directory containing `dist/`:

```sh
docker compose --project-directory dist/watchtower config --quiet
docker compose --project-directory dist/watchtower up --detach --pull always
```

Run only one persistent Watchtower daemon per Docker host. Review its schedule, cleanup behavior, labels, and notification settings in `dist/watchtower/.env` before launch.

## Run one update pass

Stop any persistent Watchtower daemon first. With the optional [repository helpers](../plundarr/quick-start.md#use-repository-helpers-later), use the generated project for one host-wide pass:

```sh
make watchtower-run-once PRESET=watchtower
```

The `make watchtower-run-once` target pulls the configured image, runs with `--run-once`, and removes its temporary container when the pass completes.

> [!CAUTION]
> Automatic image replacement can introduce database migrations, changed configuration, or incompatible runtime behavior. Back up application state and keep tightly coordinated services excluded unless you have tested their upgrade path.

Containers labeled `com.centurylinklabs.watchtower.enable=false` remain excluded. Plundarrpedia and Calibre-Web Automated use that boundary so their updates stay operator-controlled.

## Add Watchtower to another preset

Watchtower is a removable default in the Plundarr and Boudoirr presets. Select it in the picker for Duplex or another compatible project. The optional repository equivalent is:

```sh
make generate PRESET=duplex ADD_SERVICES=watchtower
```

Do not select Watchtower in several generated projects on the same host unless only one instance is allowed to run.
