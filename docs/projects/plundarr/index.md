---
title: Plundarr
description: A generated, single-file Docker Compose media fleet for Synology and any compatible Docker host.
icon: material/pirate
status: updated
---

# Plundarr 🏴‍☠️

Plundarr is a complete Docker Compose media fleet generated from the services
you actually want. The output is deliberately ordinary: one commented
`docker-compose.yml`, one matching `.env`, and service configuration
directories. That makes the same artifact usable from the command line or from
Synology Container Manager.

**Maraudarr** is the shipwright. It is a short-lived Docker image and Python
application that selects a preset, resolves required companions, preserves
handwritten comments, seeds configuration directories, and asks Docker Compose
to validate the result.

## What Plundarr solves

- Keeps a large Compose stack readable without asking users to merge fragments.
- Makes qBittorrent, SABnzbd, NZBGet, or a deliberate combination explicit.
- Keeps selected download clients behind Gluetun while other apps use the
  project network.
- Preserves environment values when a stack is regenerated.
- Offers ready-made Plundarr and Boudoirr presets plus a build-your-own path.
- Produces a Synology-friendly deployment artifact without becoming
  Synology-only.

## Core output

```text
plundarr/
├── docker-compose.yml   # Generated complete deployment
├── example.env          # Safe reference values
├── .env                 # Local settings and secrets; never commit
└── config/              # Persistent application state
```

!!! important
    Review `.env` before launching. PIA credentials, user/group IDs, host media
    paths, timezone, and port choices belong to your harbor and cannot be safely
    guessed by the generator.

## Where to go next

<div class="grid cards" markdown>

- [:material-rocket-launch: **Generate the default stack**](quick-start.md)
- [:material-tune: **Understand the important settings**](configuration.md)
- [:material-view-grid-plus: **Browse available services**](services.md)
- [:material-lifebuoy: **Recover from common failures**](troubleshooting.md)

</div>

[Plundarr's developer documentation](https://scottgigawatt.github.io/plundarr/)
covers Maraudarr architecture, service-extension contracts, testing, and the
source-generated Python reference. Plundarrpedia stays focused on deployment,
configuration, and troubleshooting voyages.

[View Plundarr on GitHub](https://github.com/scottgigawatt/plundarr){ .md-button }
[Open the developer documentation](https://scottgigawatt.github.io/plundarr/){ .md-button .md-button--primary }
