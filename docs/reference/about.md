---
title: About This Wiki
description: How Plundarrpedia is organized, sourced, built, and published.
icon: material/information-slab-circle
---

# About this wiki

Plundarrpedia is the public knowledge layer above the project repositories. It connects the architecture and recurring workflows without turning every page into a stale copy of a README.

## Sources of truth

- Current Plundarr repository documentation, generator behavior, service
  catalog, setup notes, helper scripts, and tests.
- Current Privateerr documentation, supervisor behavior, Compose handoff, image/release model, and validation workflow.
- The [Privateerr developer site](https://scottgigawatt.github.io/privateerr/) and [Maraudarr developer site](https://scottgigawatt.github.io/plundarr/) for Python contracts, architecture, and contributor testing.
- Current Plundarr preset catalog, service charts, generated output, and backup boundaries.
- Current Docker, Material for MkDocs, Synology, and TrueNAS documentation for
  behavior owned by those platforms.

## Visual direction

Plundarrpedia uses a chart-room palette, local visual assets, and responsive architecture maps. Small Material overrides and CSS keep navigation, search, accessibility, and print behavior theme-native.

## Material features in use

- Instant navigation with prefetch and a progress indicator.
- Search suggestions, highlighting, and shareable searches.
- Navigation tabs, section indexes, breadcrumbs, and footer navigation.
- Card grids, content tabs, code copy/select, annotations, responsive
  architecture maps, improved tooltips, and footnote tooltips.
- Automatic system light/dark selection with a manual palette toggle.

## Publishing model

GitHub Pages receives a static artifact built from `requirements.txt`. The Docker image uses the same pin in a multi-stage build and serves only the generated site from an unprivileged Nginx image. Architecture maps use native HTML and CSS, so they render under the same self-contained Content Security Policy on GitHub Pages and in the production container.

The container workflow follows the sibling project conventions: multi-platform Buildx output, Open Container Initiative (OCI) metadata, Trivy scanning, software bills of materials (SBOMs), provenance, GitHub Container Registry (GHCR) publishing, and Renovate-managed dependency updates.

## Container security boundaries

The production runtime removes unused Nginx modules, curl, and their transitive libraries. It keeps the unprivileged user, read-only deployment, healthcheck using BusyBox `wget`, and Content Security Policy. Builds use Alpine's stable repositories and enforce the PCRE2/zlib minimums in the Dockerfile.

Compare security results against the exact image digest, installed package inventory, and scanner database. A passing gate is not a zero-vulnerability guarantee. Consult the source [Privateerr security policy](https://scottgigawatt.github.io/privateerr/SECURITY/) and [Plundarr security policy](https://scottgigawatt.github.io/plundarr/SECURITY/) for those applications' current findings and limitations; their [dated scan evidence](https://scottgigawatt.github.io/privateerr/container-scan-review/) is an artifact record rather than the wiki's runtime status.

## Contributing

Edit Markdown under `docs/`, update `mkdocs.yml` when adding navigation, and follow the [writing guide](../CONTRIBUTING.md). Then validate:

```sh
make site
make config
make lint
```

[Edit this page](https://github.com/scottgigawatt/plundarrpedia/edit/main/docs/reference/about.md){ .md-button }
