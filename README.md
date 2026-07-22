<!-- markdownlint-disable MD033 MD041 -->

<hr />

<p align="center">
  <em>🦜 Parrot says: Star the charts or explain to the crew why we sailed into buffering!</em>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/scottgigawatt/plundarrpedia?label=Chart%20Collectors&logo=github" alt="Chart Collectors" />
  <img src="https://img.shields.io/github/forks/scottgigawatt/plundarrpedia?label=Forked%20Currents&logo=github" alt="Forked Currents" />
  <img src="https://img.shields.io/github/watchers/scottgigawatt/plundarrpedia?label=Crow%27s%20Nest%20Readers&logo=github" alt="Crow's Nest Readers" />
</p>

<p align="center">
  <img src="https://img.shields.io/github/v/release/scottgigawatt/plundarrpedia?label=Latest%20Edition&logo=github" alt="Latest Edition" />
  <img src="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/pages.yml/badge.svg" alt="GitHub Pages" />
  <img src="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/build-and-push.yml/badge.svg" alt="Container Build" />
  <img src="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/validate-pr.yml/badge.svg" alt="Validation" />
  <img src="https://img.shields.io/github/license/scottgigawatt/plundarrpedia?label=Legal%20Scroll&color=blue" alt="Legal Scroll" />
  <img src="https://img.shields.io/badge/MkDocs-Material-526CFE?logo=materialformkdocs" alt="Material for MkDocs" />
  <img src="https://img.shields.io/badge/Served-by%20Unprivileged%20Nginx-009639?logo=nginx" alt="Unprivileged Nginx" />
  <img src="https://img.shields.io/badge/Scanned-Trivy%20Bilge%20Check-teal?logo=aqua" alt="Trivy Bilge Check" />
  <img src="https://img.shields.io/badge/Multi--Arch-amd64%20%7C%20arm64%20%7C%20arm%2Fv7-blue?logo=docker" alt="Multi-Arch amd64, arm64, and arm/v7" />
  <img src="https://img.shields.io/badge/Harbors-Synology%20%7C%20TrueNAS%20%7C%20Docker-blue" alt="Synology, TrueNAS, and Docker" />
  <img src="https://img.shields.io/github/last-commit/scottgigawatt/plundarrpedia?label=Last%20Charted&logo=git" alt="Last Charted" />
  <img src="https://img.shields.io/github/repo-size/scottgigawatt/plundarrpedia?label=Sea%20Chest%20Size" alt="Sea Chest Size" />
  <img src="https://img.shields.io/badge/Sea%20Monsters-Documented-orange" alt="Sea Monsters Documented" />
</p>

<p align="center">─── ⛧ ───</p>

<p align="center">
  <em>💀 Need help or wanna trade cursed media-stack tips over lava? Step forward… <strong>Enter 🔥HADES🔥</strong>.</em>
</p>

<p align="center">
  <a href="https://discord.gg/BpEGzWwGYf">
    <img src="https://img.shields.io/discord/1403601106315116626?label=%F0%9F%94%A5HADES%F0%9F%94%A5&logo=discord&logoColor=white&color=5865F2" alt="🔥HADES🔥 Discord" />
  </a>
</p>

<hr />

# ⚓ Plundarrpedia 🏴‍☠️📚

Ahoy! Plundarrpedia is the public field guide for the Scott Gigawatt media
fleet: [Plundarr](https://github.com/scottgigawatt/plundarr),
[Privateerr](https://github.com/scottgigawatt/privateerr),
[Duplex](https://github.com/scottgigawatt/duplex), and the practical Docker,
storage, networking, and NAS knowledge that connects them.

The project repositories remain the source of truth for code and exact
configuration. Plundarrpedia is where those pieces become task-oriented guides,
architecture maps, examples, and troubleshooting routes for humans.

> [!IMPORTANT]
> **Privateerr is a configuration generator, not a VPN client.** It writes PIA
> WireGuard configuration and endpoint metadata. Gluetun establishes and runs
> the VPN tunnel.

## ⚡ Fastest Path

Run the production site locally with the same one-file Compose project used on
ordinary Docker hosts, Synology Container Manager, and compatible NAS systems:

```console
❯ git clone https://github.com/scottgigawatt/plundarrpedia.git
❯ cd plundarrpedia
❯ cp example.env .env
❯ make up
```

Open <http://localhost:8000>.

The defaults in `.env` are ready for a normal local run. Every setting keeps a
shell fallback, so it can also be overridden for one command:

```console
❯ PLUNDARRPEDIA_HOST_PORT=8888 PLUNDARRPEDIA_TAG=edge make up
```

> [!TIP]
> Use `make env` to see the values Docker Compose will use after shell and
> `.env` interpolation.

## 🧭 Pick a Reading Route

| 🗺️ Route                                                                         | 🎯 What it covers                                                   |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| [Start Here](https://scottgigawatt.github.io/plundarrpedia/start-here/)          | Choose the smallest project path that solves the job.               |
| [Plundarr](https://scottgigawatt.github.io/plundarrpedia/projects/plundarr/)     | Generate and operate a complete media automation stack.             |
| [Privateerr](https://scottgigawatt.github.io/plundarrpedia/projects/privateerr/) | Generate PIA WireGuard configuration for Gluetun.                   |
| [Duplex](https://scottgigawatt.github.io/plundarrpedia/projects/duplex/)         | Operate Plex curation, cleanup, monitoring, and notification tools. |
| [Platform Guides](https://scottgigawatt.github.io/plundarrpedia/guides/)         | Deploy on Linux Docker, Synology, or TrueNAS.                       |

## ✍️ Write and Preview the Wiki

Markdown pages live under `docs/`. Each page uses a small YAML front matter
block, one H1 heading, sentence-case headings, fenced code blocks, and relative
links for pages inside this site.

```console
❯ make serve
```

Open <http://localhost:8000>. Material for MkDocs reloads the site as files
change.

Before opening a pull request:

```console
❯ make markdown
❯ make site
❯ make config
❯ make lint
```

The rules live in [`.markdownlint-cli2.yaml`](./.markdownlint-cli2.yaml), and
the complete writing conventions live in
[`docs/CONTRIBUTING.md`](./docs/CONTRIBUTING.md).

> [!NOTE]
> MkDocs strict mode catches broken navigation and configuration warnings.
> Markdownlint catches document structure and formatting problems. Both checks
> are intentional because they detect different classes of mistakes.

## 🐳 Build the Production Image

Plundarrpedia uses a multi-stage Dockerfile:

1. A pinned Material for MkDocs image renders the site with `--strict`.
2. Responsive architecture maps render without a third-party JavaScript CDN.
3. A pinned unprivileged Nginx image serves only the generated static files.

```console
❯ make build
❯ make build-multiarch
```

Published images support `linux/amd64`, `linux/arm64`, and `linux/arm/v7`.

| 📦 Channel      | 🐳 Image                                          |
| --------------- | ------------------------------------------------- |
| Stable          | `ghcr.io/scottgigawatt/plundarrpedia:latest`      |
| Preview         | `ghcr.io/scottgigawatt/plundarrpedia:edge`        |
| Exact release   | `ghcr.io/scottgigawatt/plundarrpedia:1.0.0`       |
| Source revision | `ghcr.io/scottgigawatt/plundarrpedia:sha-cfa2fb5` |

> [!CAUTION]
> `edge` follows successful builds from `main`. Use a semantic-version tag when
> you need reproducible deployment behavior.

## ⚙️ Useful Commands

| ⚙️ Command              | ✅ Use it when                                     |
| ----------------------- | -------------------------------------------------- |
| `make serve`            | You want live-reload authoring on port 8000.       |
| `make markdown`         | You want to lint every Markdown document.          |
| `make site`             | You want a strict static build in `site/`.         |
| `make build`            | You want the production Nginx image.               |
| `make build-multiarch`  | You changed image inputs or published platforms.   |
| `make config`           | You want the fully rendered Compose model.         |
| `make env`              | You want Compose interpolation values.             |
| `make print-config`     | You want uncommented raw Compose YAML.             |
| `make print-env`        | You want uncommented example environment values.   |
| `make up` / `make down` | You want to start or stop the local site.          |
| `make logs`             | You want to follow the production container logs.  |
| `make lint`             | You want every repository validation hook.         |

## 🚀 Publishing

Changes merged to `main` follow two lanes:

- GitHub Pages builds and publishes the static site.
- The image workflow scans a local image, publishes the multi-platform GHCR
  manifest, and attaches SBOM and provenance information.

GitHub Actions are pinned to full commit digests. Renovate proposes controlled
updates for Actions, Python dependencies, Compose images, and Dockerfile base
digests.

## 🛡️ Security and Scope

- Never copy `.env`, credentials, API keys, live `wg0.conf`, private logs, or
  local hostnames into the wiki.
- Treat sibling repositories as the technical source of truth.
- Keep commands and warnings sober even when the surrounding prose is nautical.
- Keep the runtime read-only, unprivileged, capability-free, and intentionally
  updated.

> [!WARNING]
> Documentation examples are public. Replace real tokens, hostnames, account
> IDs, tunnel keys, and private network details before committing a page.

## ⚖️ License and Community

Plundarrpedia is licensed under Apache 2.0; see [LICENSE](LICENSE).

Need a second pair of eyes? Join the
[🔥HADES🔥 Discord](https://discord.gg/BpEGzWwGYf) and bring the logs with the
secrets removed.

---

```text
                 __|__
          ______/_____|_______
          \              o  /
       ~~~~\_______________/~~~~
          PLUNDARRPEDIA
    Every fleet needs good charts.
```

🏝️ Cast yer pull requests ashore, or send a message in a bottle.

<!-- markdownlint-disable-next-line MD036 -->
_The sea calls, the docs answer. Fair winds and searchable containers! 🌊🏴‍☠️_
