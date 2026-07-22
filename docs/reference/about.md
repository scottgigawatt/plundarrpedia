---
title: About This Wiki
description: How Plundarrpedia is organized, sourced, built, and published.
icon: material/information-slab-circle
---

# About this wiki

Plundarrpedia is the public knowledge layer above the project repositories. It
connects the architecture and recurring workflows without turning every page
into a stale copy of a README.

## Sources of truth

- Current Plundarr repository documentation, generator behavior, service
  catalog, setup notes, helper scripts, and tests.
- Current Privateerr documentation, Compose handoff, image/release model, and
  validation workflow.
- Current Duplex README and Compose service set.
- Current Docker, Material for MkDocs, Synology, and TrueNAS documentation for
  behavior owned by those platforms.

## Visual direction

The earlier wiki used a cosmic photographic background. Plundarrpedia uses a
new chart-room system: navy ink, sea-glass teal, brass, parchment, a custom
compass rose, layered grids, and project accents. The styling is implemented as
small Material overrides and CSS, so navigation, search, accessibility, and
print behavior remain theme-native.

## Material features in use

- Instant navigation with prefetch and a progress indicator.
- Search suggestions, highlighting, and shareable searches.
- Navigation tabs, section indexes, breadcrumbs, and footer navigation.
- Card grids, content tabs, code copy/select, annotations, responsive
  architecture maps, improved tooltips, and footnote tooltips.
- Automatic system light/dark selection with a manual palette toggle.

## Publishing model

GitHub Pages receives a static artifact built from `requirements.txt`.
The Docker image uses the same pin in a multi-stage build and serves only the
generated site from an unprivileged Nginx image. Architecture maps use native
HTML and CSS, so they render under the same self-contained Content Security
Policy on GitHub Pages and in the production container.

The container workflow follows the sibling project conventions: multi-platform
Buildx output, OCI metadata, Trivy scanning, SBOM/provenance, GHCR publishing,
and Renovate-managed dependency updates.

## Contributing

Edit Markdown under `docs/`, update `mkdocs.yml` when adding navigation, and
follow the [writing guide](../CONTRIBUTING.md). Then validate:

```console
make site
make config
make lint
```

[Edit this page](https://github.com/scottgigawatt/plundarrpedia/edit/main/docs/reference/about.md){ .md-button }
