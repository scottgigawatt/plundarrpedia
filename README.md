# Plundarrpedia 🏴‍☠️

Plundarrpedia helps you run [Privateerr](https://github.com/scottgigawatt/privateerr), generate a media stack with [Plundarr](https://github.com/scottgigawatt/plundarr), and configure the applications on Docker or a NAS.

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

**[Read the wiki](https://scottgigawatt.github.io/plundarrpedia/)**. No installation is needed.

## Start using the projects

| Your goal | Start here |
| --- | --- |
| Run Privateerr, Gluetun, and qBittorrent | [Privateerr quick start](https://scottgigawatt.github.io/plundarrpedia/projects/privateerr/quick-start/) |
| Generate and start a complete media stack | [Interactive Plundarr quick start](https://scottgigawatt.github.io/plundarrpedia/projects/plundarr/quick-start/) |
| Add media servers, books, or other tools | [Choose a preset](https://scottgigawatt.github.io/plundarrpedia/projects/presets/) |
| Use Synology Container Manager or TrueNAS | [Choose your platform](https://scottgigawatt.github.io/plundarrpedia/guides/) |

## Host the wiki

To host a local copy, you need only Docker:

```sh
docker run --detach --name plundarrpedia \
  --publish 8000:8080 \
  --read-only --tmpfs /tmp \
  --cap-drop ALL --security-opt no-new-privileges:true \
  ghcr.io/scottgigawatt/plundarrpedia:latest
```

Open <http://localhost:8000>. Stop and remove this container with `docker stop plundarrpedia` and `docker rm plundarrpedia`. The [image guide](https://scottgigawatt.github.io/plundarrpedia/GHCR_README/) covers image selection and the Compose option.

## Improve the wiki

Follow [contributing](https://scottgigawatt.github.io/plundarrpedia/CONTRIBUTING/) to clone the source, preview pages, and validate changes. [Advanced usage](https://scottgigawatt.github.io/plundarrpedia/ADVANCED_USAGE/) covers local image builds and publication. Project repositories own exact configuration and code; this wiki owns integrated operator walkthroughs.

## Get help

- [Report a documentation problem](https://github.com/scottgigawatt/plundarrpedia/issues/new/choose) with the page and sanitized reproduction steps.
- Ask setup questions in [HADES Discord](https://discord.gg/BpEGzWwGYf).
- Follow the [security policy](https://scottgigawatt.github.io/plundarrpedia/SECURITY/) for private vulnerability reports and the [Code of Conduct](https://scottgigawatt.github.io/plundarrpedia/CODE_OF_CONDUCT/) when participating.

Maintained by [Scott Gigawatt](https://github.com/scottgigawatt); licensed under [Apache 2.0](LICENSE).
