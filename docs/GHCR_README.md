# ⚓ Plundarrpedia 🏴‍☠️📚

Plundarrpedia is a task-oriented field guide for Plundarr, Privateerr, Plex
utilities, and practical self-hosted media automation. The container serves the
complete Material for MkDocs site from an unprivileged Nginx runtime.

> [!IMPORTANT]
> Privateerr generates PIA WireGuard configuration and endpoint metadata.
> Gluetun establishes and runs the VPN tunnel.

## 📦 GHCR image

The canonical image is published to GitHub Container Registry (GHCR):

```console
docker pull ghcr.io/scottgigawatt/plundarrpedia:latest
```

Use `edge` only when intentionally testing the newest successful build from
`main`:

```console
docker pull ghcr.io/scottgigawatt/plundarrpedia:edge
```

| Tag            | Purpose                                                    |
| -------------- | ---------------------------------------------------------- |
| `latest`       | Newest stable semantic-version release.                    |
| `1.0.0`        | Exact stable release.                                      |
| `edge`         | Newest successful `main` build.                            |
| `sha-cfa2fb5`  | Image produced from one source commit.                     |

Published tags are multi-platform manifests for `linux/amd64`, `linux/arm64`,
and `linux/arm/v7`. Docker selects the correct platform automatically.

## ⚡ Run it

```console
docker run --rm \
  --name plundarrpedia \
  --publish 8000:8080 \
  --read-only \
  --tmpfs /tmp \
  --tmpfs /var/cache/nginx \
  --tmpfs /var/run \
  ghcr.io/scottgigawatt/plundarrpedia:latest
```

Open <http://localhost:8000>.

For resource limits, health checks, log rotation, and NAS-friendly environment
overrides, use the complete Compose deployment in the GitHub repository.

## 🛡️ Supply-chain details

The publishing workflow:

- builds for AMD64, ARM64, and ARMv7;
- scans the runtime image with Trivy before publishing;
- creates software bill of materials (SBOM) and provenance attestations;
- attaches GitHub build provenance to the published manifest digest;
- uses pinned GitHub Actions and pinned container base-image digests.

## 🔗 Links

| Resource          | Link                                                        |
| ----------------- | ----------------------------------------------------------- |
| Public wiki       | <https://scottgigawatt.github.io/plundarrpedia/>            |
| GitHub repository | <https://github.com/scottgigawatt/plundarrpedia>            |
| GHCR package      | [Plundarrpedia package][ghcr-package]                       |
| HADES Discord     | <https://discord.gg/BpEGzWwGYf>                             |

[ghcr-package]: https://github.com/scottgigawatt/plundarrpedia/pkgs/container/plundarrpedia
