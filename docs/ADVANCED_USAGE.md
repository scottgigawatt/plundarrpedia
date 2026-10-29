---
title: Advanced Usage
description: Build, publish, customize, and maintain Plundarrpedia beyond the local quick start.
icon: material/map-marker-path
---

# Advanced usage

Use this page to build or host Plundarrpedia and review its publication model. For Markdown authoring, follow [contributing](CONTRIBUTING.md). Work from the repository root with Git, Make, Docker, and Compose available.

## Authoring routes

`make serve` starts the Docker-based live preview at <http://localhost:8000>, using `example.env` if no local `.env` exists. Use `make serve MKDOCS_AUTHOR_PORT=8001` for a port conflict.

For other build/runtime targets, create `.env` from `example.env` only if absent and review host-specific values. Keep existing assignments. `make site` exports a strict build to `site/`; `make clean` deletes that generated directory, so inspect any `SITE_OUTPUT_PATH` override first. Edit sources, not generated HTML.

## Material features

Use tabs for real alternatives and cards for route choices. Keep required steps and warnings visible. Confirm custom syntax renders under `mkdocs.yml`; shared GitHub Markdown has fewer supported features. Diagrams need an equivalent explanation and must fit narrow screens.

## Production image builds

Build the checkout after preparing `.env`:

```sh
make build
```

The image serves static files on port `8080` through unprivileged Nginx. It supports amd64, arm64, and arm/v7. Validate all published platforms when image inputs change:

```sh
make build-multiarch
```

This Buildx target is cache-only by default, not publication. The [README](https://github.com/scottgigawatt/plundarrpedia#readme) explains running a published image without rebuilding source.

## Publishing routes

| Destination | Workflow | Output |
| --- | --- | --- |
| GitHub Pages | `pages.yml` | Static website |
| GHCR | `build-and-push.yml` | Multi-platform Nginx image |

Applicable `main` changes publish `edge` and `sha-<commit>`. Stable annotated semantic-version tags publish the exact version, `latest`, and a SHA tag; prereleases omit `latest`. Tags must reference a commit already on `main` and must never be moved or reused. Manual image publication is restricted to `main`.

Workflows have source-path filters. A merge alone does not prove both publication lanes ran. Check the relevant workflow results before announcing an update. Image publication includes Trivy scanning, SBOM/provenance, and a manifest-bound build attestation.

## Build notifications

Optional Discord build notifications use repository secrets `DISCORD_WEBHOOK_URL` and `DISCORD_HADES_HOOK_URL`. Missing secrets skip their destination. Never put actual webhook URLs in source, issues, or logs.

## Pinned build inputs

Actions use immutable SHAs and container bases use version/digest pairs. Renovate proposes updates. `requirements.txt` pins the top-level Material version; transitive Python dependencies are not fully locked or hash-verified.

For dependency changes, verify matching version comments, strict site/lint checks, read-only/unprivileged runtime behavior, and the affected published architectures.

## Useful maintenance commands

Use `make help` for the complete list. `make config` prints resolved Compose and `make env` prints interpolation values; keep output private. `make logs` follows the production container.

`make run` builds and recreates the local production stack; `make down` stops/removes it. These change container state and are separate from documentation validation.
