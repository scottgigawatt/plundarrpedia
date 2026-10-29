---
title: Pick a Route
description: Choose the shortest path into the Scott Gigawatt media projects.
icon: material/map-marker-path
---

# Pick a route

Choose the smallest deployment that solves your task:

| Your task | Start here |
| --- | --- |
| Generate a media automation stack | [Plundarr quick start](../projects/plundarr/quick-start.md) |
| Run a focused media server, ebook, or utility deployment | [Compare presets](../projects/presets/index.md) |
| Generate PIA settings or operate the VPN lane | [Privateerr quick start](../projects/privateerr/quick-start.md) |
| Deploy through a NAS interface | [Platform guides](../guides/index.md) |

## A sane first voyage

Prepare storage and permissions, generate your selected services, edit the private `.env`, then validate and start the project. Confirm the VPN and download path before configuring indexers, managers, and playback. The [architecture guide](architecture.md) explains how those parts connect.

## Before you launch

- [ ] Docker with Compose v2 is available and each selected image supports your host architecture.
- [ ] Host paths exist with the intended numeric ownership.
- [ ] Host ports are free and the Docker subnet does not overlap another route.
- [ ] Secrets stay in the ignored deployment `.env`.
- [ ] Your backup plan covers databases, external state, and keys as well as configuration.
