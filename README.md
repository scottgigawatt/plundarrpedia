<!-- markdownlint-disable-next-line MD033 MD041 -->
<hr />

<!-- markdownlint-disable MD033 -->
<p align="center">
  <em>🦜 Parrot says: Found the right chart? Drop a ⭐ an' help another crew find it.</em>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/plundarrpedia/stargazers"><img src="https://img.shields.io/github/stars/scottgigawatt/plundarrpedia?style=social&amp;label=Chart%20Collectors" alt="GitHub stars: Chart Collectors" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/forks"><img src="https://img.shields.io/github/forks/scottgigawatt/plundarrpedia?style=social&amp;label=Forked%20Currents" alt="GitHub forks: Forked Currents" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/watchers"><img src="https://img.shields.io/github/watchers/scottgigawatt/plundarrpedia?style=social&amp;label=Crow%27s%20Nest%20Readers" alt="GitHub watchers: Crow's Nest Readers" /></a>
</p>

<p align="center">
  <a href="https://scottgigawatt.github.io/plundarrpedia/"><img src="https://img.shields.io/badge/Read-the%20Wiki-526CFE?logo=materialformkdocs&amp;logoColor=white" alt="Read the Plundarrpedia wiki" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/releases/latest"><img src="https://img.shields.io/github/v/release/scottgigawatt/plundarrpedia?label=Latest%20Edition&amp;logo=github&amp;color=BE123C" alt="Latest Plundarrpedia release" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/scottgigawatt/plundarrpedia?label=Legal%20Scroll&amp;color=8250DF" alt="Legal Scroll: Apache 2.0 license" /></a>
  <a href="https://www.bestpractices.dev/projects/14769"><img src="https://www.bestpractices.dev/projects/14769/badge" alt="OpenSSF Best Practices badge" /></a>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/pages.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/plundarrpedia/pages.yml?branch=main&amp;label=Wiki%20deploy&amp;logo=githubactions&amp;logoColor=white" alt="GitHub Pages deployment status on main" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/build-and-push.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/plundarrpedia/build-and-push.yml?branch=main&amp;label=Image%20build&amp;logo=githubactions&amp;logoColor=white" alt="Container build status on main" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/pkgs/container/plundarrpedia"><img src="https://img.shields.io/badge/Fleet-amd64%20%7C%20arm64%20%7C%20arm%2Fv7-6D28D9?logo=docker&amp;logoColor=white" alt="Plundarrpedia images for amd64, arm64, and arm/v7" /></a>
</p>

<p align="center">─── ⛧ ───</p>

<p align="center">
  <em>💀 Questions or cursed media-stack tips? Step forward… <strong>enter 🔥HADES🔥</strong>.</em>
</p>

<p align="center">
  <a href="https://discord.gg/BpEGzWwGYf"><img src="https://img.shields.io/discord/1403601106315116626?label=%F0%9F%94%A5HADES%F0%9F%94%A5&amp;logo=discord&amp;logoColor=white&amp;color=5865F2" alt="HADES Discord community" /></a>
</p>
<!-- markdownlint-enable MD033 -->

<!-- markdownlint-disable-next-line MD033 -->
<hr />

# Plundarrpedia 🏴‍☠️

Plundarrpedia is the public field guide for [Plundarr](https://github.com/scottgigawatt/plundarr), [Privateerr](https://github.com/scottgigawatt/privateerr), and the self-hosted media presets they power. It brings setup, architecture, storage, networking, and troubleshooting into one searchable wiki for Docker and NAS operators.

**[Read the wiki](https://scottgigawatt.github.io/plundarrpedia/)** or [start here](https://scottgigawatt.github.io/plundarrpedia/start-here/) to choose the smallest project that solves your job. No installation is needed to read the published guides.

The project repositories remain the source of truth for code and exact configuration. Plundarrpedia connects those pieces with task-oriented guides and examples. Privateerr generates PIA WireGuard configuration; Gluetun runs the VPN tunnel.

## Pick a reading route 🧭

| Guide | What you'll find |
| --- | --- |
| [Plundarr](https://scottgigawatt.github.io/plundarrpedia/projects/plundarr/) | Generate and operate a media automation stack. |
| [Privateerr](https://scottgigawatt.github.io/plundarrpedia/projects/privateerr/) | Generate PIA settings and recover stale Gluetun connections. |
| [Presets](https://scottgigawatt.github.io/plundarrpedia/projects/presets/) | Choose Boudoirr, Jellyfin, Plex, Calibre-Web Automated, Duplex, Watchtower, Portainer, or a custom stack. |
| [Platform guides](https://scottgigawatt.github.io/plundarrpedia/guides/) | Deploy on Linux Docker, Synology, or TrueNAS. |

## Run the wiki locally ⚡

You need Git, Make, and Docker with Docker Compose. The repository includes one Compose file for serving the production site and running the authoring tools.

Clone the repository and create your local environment file:

```sh
git clone https://github.com/scottgigawatt/plundarrpedia.git
cd plundarrpedia
cp example.env .env
```

Review `.env` for your host, especially `PLUNDARRPEDIA_HOST_PORT` if port `8000` is already in use. Then build and start the production site from your checkout:

```sh
make run
```

Open <http://localhost:8000>, using your chosen port if you changed it. This command builds the checked-out source; changing `PLUNDARRPEDIA_TAG` changes its image tag, not the source revision it builds.

Use `make logs` to follow the container logs and `make down` to stop and remove the local Compose containers. See [advanced usage](docs/ADVANCED_USAGE.md) for build, deployment, and maintenance details.

## Write and preview the wiki ✍️

Pages live in `docs/`, navigation lives in `mkdocs.yml`, and theme customizations live in `overrides/` and `docs/assets/`. Follow the [contribution guide](docs/CONTRIBUTING.md) for front matter, sentence-case headings, relative links, and accessible Markdown.

From the cloned repository, start the live-reload preview:

```sh
make serve
```

Open <http://localhost:8000>. The preview uses the pinned Material for MkDocs toolchain in Docker, so you do not need to install Python or MkDocs locally. If the production site is already using port `8000`, stop it with `make down` first or use `make serve MKDOCS_AUTHOR_PORT=8001` and open <http://localhost:8001>.

Before opening a pull request, run the strict site build, Compose validation, and repository checks. These commands assume you created `.env` above; `make lint` also needs [pre-commit](https://pre-commit.com/#install) installed:

```sh
make site
make config
make lint
```

The strict build catches navigation and configuration warnings, while the lint checks validate source formatting and other repository rules. Review the rendered result as well: successful checks cannot tell you whether a guide makes sense to its reader.

When adding new behavior, add or extend automated checks for it. New documentation is covered by the full-site build and lint checks. Keep examples public-safe: replace credentials, tunnel keys, private hostnames, and other deployment details before committing.

Use `make help` for the complete command list. Generated HTML goes in `site/`; edit its sources and use `make clean` when you want to remove that generated output.

## Published images and releases 🐳

The [GHCR package](https://github.com/scottgigawatt/plundarrpedia/pkgs/container/plundarrpedia) supports `linux/amd64`, `linux/arm64`, and `linux/arm/v7`. A pinned Material for MkDocs build renders the site, and an unprivileged Nginx image serves the static files. The supplied Compose configuration uses a read-only runtime and drops all Linux capabilities.

| Image tag | Use |
| --- | --- |
| `ghcr.io/scottgigawatt/plundarrpedia:latest` | Latest stable release. |
| `ghcr.io/scottgigawatt/plundarrpedia:edge` | Preview from a successful build of `main`. |
| `ghcr.io/scottgigawatt/plundarrpedia:<version>` | A specific published version; choose its tag from the [releases](https://github.com/scottgigawatt/plundarrpedia/releases). |

To run a published image instead of building your checkout, set `PLUNDARRPEDIA_TAG` in `.env`, then pull and start the service without building:

```sh
docker compose pull plundarrpedia
docker compose up --detach --no-build plundarrpedia
```

`latest` and `edge` move as new builds are published. Choose a release tag for a specific version, or an image digest when you need immutable image selection.

Changes merged to `main` publish the wiki to GitHub Pages and trigger the container workflow. The image workflow scans with Trivy and publishes multi-platform images with a software bill of materials (SBOM) and provenance. See the [publishing guide](docs/ADVANCED_USAGE.md#publishing-routes) for release details.

## Help, security, and contributions 🤝

For a broken guide or a feature request, [open an issue](https://github.com/scottgigawatt/plundarrpedia/issues/new/choose). For setup questions, join the [HADES Discord community](https://discord.gg/BpEGzWwGYf) with any secrets removed from your logs.

Report vulnerabilities privately using the [security policy](docs/SECURITY.md). It also explains supported releases and the boundary between this documentation project and the tools it describes.

Corrections, clearer examples, and new guides are welcome. Read the [contribution guide](docs/CONTRIBUTING.md) and [code of conduct](docs/CODE_OF_CONDUCT.md) before sending a pull request. Plundarrpedia is maintained by [Scott Gigawatt](https://github.com/scottgigawatt) and released under the [Apache 2.0 license](LICENSE).

Every fleet needs good charts. Help keep these ones seaworthy. 🏴‍☠️
