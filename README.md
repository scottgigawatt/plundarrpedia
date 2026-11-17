# Plundarrpedia 🏴‍☠️

Plundarrpedia helps you run [Privateerr](https://github.com/scottgigawatt/privateerr), generate a media stack with [Plundarr](https://github.com/scottgigawatt/plundarr), and configure the applications on Docker or a NAS.

<!-- markdownlint-disable-next-line MD033 MD041 -->
<hr />

<!-- markdownlint-disable MD033 -->
<p align="center">
  <em>🦜 Parrot says: Found the right chart? Drop a ⭐ an' help another crew find it.</em>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/plundarrpedia/stargazers"><img src="https://img.shields.io/github/stars/scottgigawatt/plundarrpedia?label=Chart%20Collectors&amp;style=social&amp;logo=github&amp;logoColor=181717" alt="GitHub stars: Chart Collectors" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/forks"><img src="https://img.shields.io/github/forks/scottgigawatt/plundarrpedia?label=Forked%20Currents&amp;style=social&amp;logo=github&amp;logoColor=181717" alt="GitHub forks: Forked Currents" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/watchers"><img src="https://img.shields.io/github/watchers/scottgigawatt/plundarrpedia?label=Crow%27s%20Nest%20Readers&amp;style=social&amp;logo=github&amp;logoColor=181717" alt="GitHub watchers: Crow&#x27;s Nest Readers" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/releases/latest"><img src="https://img.shields.io/github/v/release/scottgigawatt/plundarrpedia?label=Latest%20Edition&amp;style=social&amp;logo=github&amp;logoColor=181717" alt="Latest Plundarrpedia release" /></a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/github/license/scottgigawatt/plundarrpedia?label=Legal%20Scroll&amp;style=flat&amp;logo=apache&amp;logoColor=white&amp;color=D7263D&amp;labelColor=D7263D" alt="Legal Scroll: Apache 2.0 license" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/commits/main"><img src="https://img.shields.io/github/last-commit/scottgigawatt/plundarrpedia?label=Last%20Revision&amp;style=flat&amp;logo=git&amp;logoColor=white&amp;color=C45100&amp;labelColor=C45100" alt="Date of the last commit to main" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia"><img src="https://img.shields.io/github/repo-size/scottgigawatt/plundarrpedia?label=Chart%20Chest&amp;style=flat&amp;logo=github&amp;logoColor=white&amp;color=8C6900&amp;labelColor=8C6900" alt="Repository size" /></a>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/validate-pr.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/plundarrpedia/validate-pr.yml?label=Chart%20Inspection&amp;event=pull_request&amp;style=flat&amp;logo=githubactions&amp;logoColor=white&amp;color=527C00&amp;labelColor=527C00" alt="Latest pull-request validation status" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/codeql-actions.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/plundarrpedia/codeql-actions.yml?label=CodeQL&amp;branch=main&amp;style=flat&amp;logo=githubactions&amp;logoColor=white&amp;color=16823B&amp;labelColor=16823B" alt="CodeQL on main" /></a>
  <a href="https://www.bestpractices.dev/projects/14769"><img src="https://img.shields.io/cii/summary/14769?label=OpenSSF%20Best%20Practices&amp;style=flat&amp;logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI%2BPHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyIDMgNnY2YzAgNSA0IDggOSAxMCA1LTIgOS01IDktMTBWNnptLTEgMTQtNC00IDItMiAyIDIgNC00IDIgMnoiLz48L3N2Zz4%3D&amp;logoColor=white&amp;color=008271&amp;labelColor=008271" alt="OpenSSF Best Practices badge" /></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Wiki%20Vessel-Docker-007D9C?style=flat&amp;logo=docker&amp;logoColor=white&amp;color=007D9C&amp;labelColor=007D9C" alt="Wiki runs in Docker" />
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/build-and-push.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/plundarrpedia/build-and-push.yml?branch=main&amp;label=Image%20build&amp;style=flat&amp;logo=githubactions&amp;logoColor=white&amp;color=3152C7&amp;labelColor=3152C7" alt="Container build status on main" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/pages.yml"><img src="https://img.shields.io/github/actions/workflow/status/scottgigawatt/plundarrpedia/pages.yml?branch=main&amp;label=Wiki%20deploy&amp;style=flat&amp;logo=githubactions&amp;logoColor=white&amp;color=5138B6&amp;labelColor=5138B6" alt="GitHub Pages deployment status on main" /></a>
</p>

<p align="center">
  <a href="https://github.com/scottgigawatt/plundarrpedia/pkgs/container/plundarrpedia"><img src="https://img.shields.io/badge/Fleet-amd64%20%7C%20arm64%20%7C%20arm%2Fv7-7C3BB3?style=flat&amp;logo=docker&amp;logoColor=white&amp;color=7C3BB3&amp;labelColor=7C3BB3" alt="Plundarrpedia images for amd64, arm64, and arm/v7" /></a>
  <a href="https://github.com/scottgigawatt/plundarrpedia/actions/workflows/build-and-push.yml"><img src="https://img.shields.io/badge/Bilge%20Check-Trivy-A32BA3?style=flat&amp;logo=aqua&amp;logoColor=white&amp;color=A32BA3&amp;labelColor=A32BA3" alt="Container images scanned with Trivy" /></a>
  <a href="https://scottgigawatt.github.io/plundarrpedia/"><img src="https://img.shields.io/badge/Read-the%20Wiki-C42878?style=flat&amp;logo=materialformkdocs&amp;logoColor=white&amp;color=C42878&amp;labelColor=C42878" alt="Read the Plundarrpedia wiki" /></a>
</p>

<p align="center">─── ⛧ ───</p>

<p align="center">
  <em>🗺️ Lost on the Styx? Ask the damned cartographers in</em>
  <a href="https://discord.gg/BpEGzWwGYf"><img src="https://img.shields.io/discord/1403601106315116626?label=%F0%9F%94%A5HADES%F0%9F%94%A5&amp;style=flat&amp;logo=discord&amp;logoColor=white&amp;color=D62F65&amp;labelColor=D62F65" alt="HADES Discord community" align="absmiddle" /></a>
</p>
<!-- markdownlint-enable MD033 -->

<!-- markdownlint-disable-next-line MD033 -->
<hr />

**[Read the wiki](https://scottgigawatt.github.io/plundarrpedia/)**. No installation is needed.

## Start using the projects

| 🎯 Your goal | 🧭 Start here |
| --- | --- |
| 🏴‍☠️ Run Privateerr, Gluetun, and qBittorrent | [Privateerr quick start](https://scottgigawatt.github.io/plundarrpedia/projects/privateerr/quick-start/) |
| 🏴‍☠️ Generate and start a complete media stack | [Interactive Plundarr quick start](https://scottgigawatt.github.io/plundarrpedia/projects/plundarr/quick-start/) |
| 🗺️ Add media servers, books, or other tools | [Choose a preset](https://scottgigawatt.github.io/plundarrpedia/projects/presets/) |
| 🖥️ Use Synology Container Manager or TrueNAS | [Choose your platform](https://scottgigawatt.github.io/plundarrpedia/guides/) |

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
