---
title: Advanced Usage
description: Build, publish, customize, and maintain Plundarrpedia beyond the local quick start.
icon: material/map-marker-path
---

# Advanced usage

The main README covers the shortest route to a local Plundarrpedia container.
This page keeps the deeper authoring, image, release, and maintenance details.

## Authoring routes

Use the live-reload server while writing Markdown or adjusting the Material
theme:

```console
make serve
```

Open <http://localhost:8000>. This route mounts the repository into the pinned
MkDocs Material authoring image and does not require a local `.env` file.

Use a strict build before submitting changes:

```console
cp example.env .env
make site
```

The strict build rejects broken navigation, invalid configuration, missing
pages, and MkDocs warnings. It writes the generated static site to `site/`.
Remove that generated output when it is no longer needed:

```console
make clean
```

!!! note
    The generated `site/` directory is build output. Edit the Markdown,
    overrides, or stylesheets that produced it instead of committing rendered
    HTML.

## Material features

Plundarrpedia enables several Material for MkDocs features that can make a guide
easier to follow:

- admonitions for notes, tips, warnings, and dangerous operations;
- content tabs for platform-specific commands;
- Mermaid diagrams for relationships and workflows;
- syntax highlighting and copy buttons for commands and configuration;
- footnotes, tooltips, task lists, and automatic search indexing;
- light and dark palettes with project-specific theme overrides.

Keep diagrams narrow enough for mobile readers. Prefer top-to-bottom Mermaid
flows when a left-to-right chart would require horizontal scrolling.

## Production image builds

Build the same unprivileged Nginx image used by the publishing workflow:

```console
cp example.env .env
make build
```

Published images target these platforms:

| Platform       | Typical use                                                   |
| -------------- | ------------------------------------------------------------- |
| `linux/amd64`  | Intel and AMD x86-64 Docker hosts.                            |
| `linux/arm64`  | Modern ARM64 NAS systems and Linux hosts.                     |
| `linux/arm/v7` | Older 32-bit ARM boards and compatible embedded Docker hosts. |

Verify every published architecture with Buildx:

```console
make build-multiarch
```

Override the platform list for a one-off test:

```console
make build-multiarch \
  BUILDX_PLATFORM_OPTIONS="--platform linux/amd64,linux/arm64"
```

## Publishing routes

Plundarrpedia has two independent publication lanes:

| Destination  | Source workflow       | Result                                       |
| ------------ | --------------------- | -------------------------------------------- |
| GitHub Pages | `pages.yml`           | Public Material for MkDocs website.          |
| GHCR         | `build-and-push.yml`  | Multi-platform unprivileged Nginx container. |

The image workflow scans a native image before publishing, creates an SBOM,
attaches BuildKit provenance, and adds a GitHub build attestation to the
published manifest digest.

Image tags follow these channels:

| Source                               | Published tags                    | Purpose                         |
| ------------------------------------ | --------------------------------- | ------------------------------- |
| Successful `main` build              | `edge`, `sha-<commit>`            | Preview reviewed documentation. |
| Stable tag such as `v1.2.3`          | `1.2.3`, `latest`, `sha-<commit>` | Publish a stable edition.       |
| Prerelease tag such as `v1.2.3-rc.1` | `1.2.3-rc.1`, `sha-<commit>`      | Test without replacing stable.  |

Release tags must use semantic versioning, be annotated, and point to a commit
already on `main`. Manual image publication is allowed only from `main`.

## Build notifications

The image workflow can announce its start and final state to two independent
Discord destinations. Each webhook is optional and skips cleanly when its
secret is unavailable.

| GitHub Actions secret      | Purpose                                  |
| -------------------------- | ---------------------------------------- |
| `DISCORD_WEBHOOK_URL`      | Primary image-build notifications.       |
| `DISCORD_HADES_HOOK_URL`   | HADES image-build notifications.         |

Completion messages include the job status, ref, published tags, shortened
manifest digest, and GHCR package link. Never place webhook URLs directly in a
workflow, Markdown file, issue, or log.

## Pinned build inputs

GitHub Actions use full commit SHAs, and both Dockerfile stages use pinned image
digests. Renovate proposes controlled updates for those inputs and the Python
documentation toolchain.

When reviewing a dependency pull request, confirm that:

- the human-readable version comment still matches the pinned SHA or digest;
- strict MkDocs and Markdown validation pass;
- the production image still runs unprivileged and read-only;
- all three target architectures can still be assembled when image inputs move.

## Useful maintenance commands

| Command             | Purpose                                             |
| ------------------- | --------------------------------------------------- |
| `make config`       | Render the complete Docker Compose model.           |
| `make env`          | Print evaluated Compose interpolation values.       |
| `make print-config` | Print uncommented source Compose YAML.              |
| `make print-env`    | Print uncommented example environment values.       |
| `make markdown`     | Lint every Markdown document.                       |
| `make lint`         | Run all configured repository hooks.                |
| `make clean`        | Delete the generated static-site directory.         |
| `make run`          | Build and start the complete local Compose stack.   |
| `make logs`         | Follow the production documentation container logs. |
| `make down`         | Stop and remove the complete local Compose stack.   |

See the [Command Deck](reference/commands.md) for the complete command map and
the [contribution guide](CONTRIBUTING.md) before changing public pages.
