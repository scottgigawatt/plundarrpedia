# Plundarrpedia contributor guide

## Purpose

Plundarrpedia is the public, task-oriented documentation hub for Plundarr,
Privateerr, Duplex, and related self-hosted media projects. It is a Material for
MkDocs site published to GitHub Pages and as a production Docker image.

## Voice and content

- Keep public prose useful first and lightly pirate-themed second.
- Explain acronyms and provide paths for both Synology and ordinary Docker
  hosts.
- Treat sibling repositories as the source of truth. Do not copy secrets,
  generated VPN material, local paths, or private logs from them.
- Clearly state that Privateerr generates configuration and Gluetun runs the
  VPN tunnel.
- Prefer task-oriented guides over copies of project READMEs.

## Repository layout

- `docs/`: Public wiki content and visual assets.
- `overrides/`: Material theme template overrides.
- `docker/`: Production image configuration.
- `.github/workflows/`: Pages deployment and image validation/publishing.
- `mkdocs.yml`: Navigation, theme features, and Markdown configuration.
- `requirements.txt`: Shared dependency pin for local and Pages builds.
- `docker-compose.yml`: One-file local and Synology deployment.

## Validation

Run the smallest relevant set:

```sh
make site
make config
make build
pre-commit run --all-files
```

Use `make build-multiarch` when Dockerfile or workflow changes affect published
platforms.

## Docker and workflow rules

- Keep the runtime unprivileged and image metadata OCI-complete.
- Keep `linux/amd64`, `linux/arm64`, and `linux/arm/v7` support unless a base
  image makes that impossible.
- Keep GitHub Actions pinned by digest and let Renovate update them.
- Published images should include SBOM and provenance attestations and pass a
  Trivy scan.

## Style boundaries

Public documentation may use nautical humor. Code comments, Dockerfile
comments, and workflow logic stay plain English. Do not let jokes obscure
commands, warnings, paths, or security advice.
