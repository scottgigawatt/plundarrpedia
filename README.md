# Plundarrpedia 🏴‍☠️

Plundarrpedia is the public field guide for [Plundarr](https://github.com/scottgigawatt/plundarr), [Privateerr](https://github.com/scottgigawatt/privateerr), and the self-hosted media presets they power. It brings setup, architecture, storage, networking, and troubleshooting into one searchable wiki for Docker and NAS operators.

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
  <em>🗺️ Lost on the Styx? Ask the damned cartographers in</em>
  <a href="https://discord.gg/BpEGzWwGYf"><img src="https://img.shields.io/discord/1403601106315116626?label=%F0%9F%94%A5HADES%F0%9F%94%A5&amp;logo=discord&amp;logoColor=white&amp;color=5865F2" alt="HADES Discord community" align="absmiddle" /></a>
</p>
<!-- markdownlint-enable MD033 -->

<!-- markdownlint-disable-next-line MD033 -->
<hr />

**[Read the wiki](https://scottgigawatt.github.io/plundarrpedia/)** or [choose a route](https://scottgigawatt.github.io/plundarrpedia/start-here/). No installation is needed to read it. Project repositories own code and exact configuration; this wiki connects them with operator walkthroughs.

## Pick a reading route 🧭

| Task | Guide |
| --- | --- |
| Generate and operate a media stack | [Plundarr](https://scottgigawatt.github.io/plundarrpedia/projects/plundarr/quick-start/) |
| Generate PIA settings or recover a stale tunnel | [Privateerr](https://scottgigawatt.github.io/plundarrpedia/projects/privateerr/) |
| Choose a focused deployment | [Presets](https://scottgigawatt.github.io/plundarrpedia/projects/presets/) |
| Deploy on Linux, Synology, or TrueNAS | [Platform guides](https://scottgigawatt.github.io/plundarrpedia/guides/) |

## Run the wiki locally ⚡

You need Git, Make, Docker, and Compose. Clone a new checkout:

```sh
git clone https://github.com/scottgigawatt/plundarrpedia.git
cd plundarrpedia
cp example.env .env
```

For an existing checkout, keep its `.env`. Review the host port, then build and start the checked-out source:

```sh
make run
```

Open <http://localhost:8000>, or your chosen port. Use `make logs` for output and `make down` to stop/remove the local containers. Changing `PLUNDARRPEDIA_TAG` names the built image; it does not select a source revision.

## Write and preview the wiki ✍️

Pages live in `docs/` and navigation in `mkdocs.yml`. Follow [contributing](docs/CONTRIBUTING.md) for the required GitHub/ISO writing standard, source layout, validation, and reader-journey review.

```sh
make serve
```

Open <http://localhost:8000>. If occupied, use `make serve MKDOCS_AUTHOR_PORT=8001`. The Docker toolchain needs no host Python installation. Before submitting pages, run `make site` and `make lint`, then inspect the render; lint also requires pre-commit.

## Published images and releases 🐳

The [GHCR image](https://github.com/scottgigawatt/plundarrpedia/pkgs/container/plundarrpedia) supports amd64, arm64, and arm/v7. It serves static files with unprivileged Nginx; Compose uses a read-only runtime and dropped capabilities.

Choose `latest` for stable, `edge` for a successful `main` build, or an exact [release tag](https://github.com/scottgigawatt/plundarrpedia/releases). For immutable selection, use a digest. Set the desired tag in `.env` and run the published image without rebuilding:

```sh
docker compose pull plundarrpedia
docker compose up --detach --no-build plundarrpedia
```

See [advanced usage](docs/ADVANCED_USAGE.md) for build/publication boundaries and [the registry guide](docs/GHCR_README.md) for direct Docker usage.

## Read more and get help 📚

- [Published wiki](https://scottgigawatt.github.io/plundarrpedia/): deployment, platform, and troubleshooting guides.
- [Report a broken guide](https://github.com/scottgigawatt/plundarrpedia/issues/new/choose): include reproducible details and sanitized logs.
- [HADES Discord](https://discord.gg/BpEGzWwGYf): setup questions and community help; sanitize logs before sharing.
- [Contributing](docs/CONTRIBUTING.md), [security policy](docs/SECURITY.md), and [Code of Conduct](docs/CODE_OF_CONDUCT.md). Report vulnerabilities privately.

Maintained by [Scott Gigawatt](https://github.com/scottgigawatt); licensed under [Apache 2.0](LICENSE).
