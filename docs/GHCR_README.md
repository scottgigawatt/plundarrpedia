# Host Plundarrpedia

Plundarrpedia is a task-oriented field guide for Plundarr, Privateerr, Plex utilities, and practical self-hosted media automation. The container serves the complete Material for MkDocs site from an unprivileged Nginx runtime.

## Choose an image

The canonical image is published to GitHub Container Registry (GHCR):

```sh
docker pull ghcr.io/scottgigawatt/plundarrpedia:latest
```

Use `edge` only when intentionally testing the newest successful build from `main`:

```sh
docker pull ghcr.io/scottgigawatt/plundarrpedia:edge
```

Use `latest` for the current stable wiki, `edge` for the newest successful `main` build, or a current [release tag](https://github.com/scottgigawatt/plundarrpedia/releases). A digest selects an immutable image.

Published tags are multi-platform manifests for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`. Docker selects the correct platform automatically.

## Run it

```sh
docker run --rm \
  --name plundarrpedia \
  --publish 8000:8080 \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  ghcr.io/scottgigawatt/plundarrpedia:latest
```

Open <http://localhost:8000>.

For resource limits, health checks, log rotation, and NAS-friendly environment overrides, use the complete Compose deployment in the GitHub repository.

## Image build details

The publishing workflow:

- builds for AMD64, ARM64, and ARMv7;
- scans the runtime image with Trivy before publishing;
- creates software bill of materials (SBOM) and provenance attestations;
- attaches GitHub build provenance to the published manifest digest;
- uses pinned GitHub Actions and pinned container base-image digests.

## Links

| Resource          | Link                                                        |
| ----------------- | ----------------------------------------------------------- |
| Public wiki       | <https://scottgigawatt.github.io/plundarrpedia/>            |
| GitHub repository | <https://github.com/scottgigawatt/plundarrpedia>            |
| GHCR package      | [Plundarrpedia package][ghcr-package]                       |
| HADES Discord     | <https://discord.gg/BpEGzWwGYf>                             |

[ghcr-package]: https://github.com/scottgigawatt/plundarrpedia/pkgs/container/plundarrpedia
