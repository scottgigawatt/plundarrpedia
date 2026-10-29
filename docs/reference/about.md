---
title: About This Wiki
description: How Plundarrpedia is organized, sourced, built, and published.
icon: material/information-slab-circle
---

# About this wiki

Plundarrpedia provides integrated operator guides for Plundarr, Privateerr, and their presets. It connects project-specific instructions with Linux, Synology, and TrueNAS deployment steps.

## Sources of truth

The source repositories own behavior and exact configuration. This wiki owns cross-project deployment, operation, and troubleshooting. Use the [Plundarr](https://scottgigawatt.github.io/plundarr/) and [Privateerr](https://scottgigawatt.github.io/privateerr/) developer sites for architecture, Python contracts, and contributor testing.

## Visual direction

Local theme overrides provide the chart-room palette and responsive architecture maps. Instructions remain readable in light/dark themes and on narrow screens.

## Material features in use

Search, navigation, tabs, card grids, and copyable code support reader tasks. See the [contribution guide](../CONTRIBUTING.md) before using renderer-specific syntax.

## Publishing model

GitHub Pages and a multi-stage container build render the site. The production image serves only static files with unprivileged Nginx; it contains no wiki source or Python authoring tools. See [publication details](../ADVANCED_USAGE.md#publishing-routes).

## Container security boundaries

Compose uses a read-only runtime, dropped capabilities, and bounded writable temporary storage. Compare scan results against the exact image digest, package inventory, and scanner database; a passing gate is not a zero-vulnerability guarantee. Linked applications maintain their own security policies and dated evidence.

## Contributing

Follow [authoring and validation](../CONTRIBUTING.md), including a rendered review and checks of the affected reader journey.
