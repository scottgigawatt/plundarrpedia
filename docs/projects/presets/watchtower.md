---
title: Watchtower
description: Run the maintained Watchtower image as a persistent Plundarr preset or a deliberate one-shot update.
icon: material/telescope
status: updated
---

# Watchtower preset 🔭

The Watchtower preset generates one focused project for eligible container updates on a Docker host. Plundarr uses the maintained `nickfedor/watchtower` image and supports either a persistent daemon or an explicit one-shot pass.

## Run the persistent preset

```sh
make ship PRESET=watchtower
make config PRESET=watchtower
make up PRESET=watchtower
```

Run only one persistent Watchtower daemon per Docker host. Review its schedule, cleanup behavior, labels, and notification settings in `dist/watchtower/.env` before launch.

## Run one update pass

Stop any persistent Watchtower daemon first, then use the generated project for one host-wide pass:

```sh
make watchtower-run-once PRESET=watchtower
```

The one-shot target pulls the configured image, runs with `--run-once`, and removes its temporary container when the pass completes.

!!! caution
    Automatic image replacement can introduce database migrations, changed configuration, or incompatible runtime behavior. Back up application state and keep tightly coordinated services excluded unless you have tested their upgrade path.

Containers labeled `com.centurylinklabs.watchtower.enable=false` remain excluded. Plundarrpedia and Calibre-Web Automated use that boundary so their updates stay operator-controlled.

## Add Watchtower to another preset

Watchtower is a removable default in the Plundarr and Boudoirr presets. Add it explicitly to Duplex or another compatible generated project:

```sh
make ship PRESET=duplex ADD_SERVICES=watchtower
```

Do not select Watchtower in several generated projects on the same host unless only one instance is allowed to run.
