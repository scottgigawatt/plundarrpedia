---
title: Contributing
description: Propose, format, preview, validate, and submit Plundarrpedia improvements.
icon: material/text-box-edit
---

# Contributing to Plundarrpedia 🏴‍☠️

Plundarrpedia is maintained as Markdown, but valid Markdown alone is not enough.
Pages also need stable navigation, accurate examples, safe public data, and a
clean Material for MkDocs render.

## Before you start

- Read the [repository README](https://github.com/scottgigawatt/plundarrpedia#readme)
  for the repository and image overview.
- Read the [security policy](SECURITY.md) before sharing logs, screenshots, or
  infrastructure details.
- Keep to the [code of conduct](CODE_OF_CONDUCT.md).
- Check existing issues and pull requests before opening a duplicate chart.
- Confirm the sibling project that owns the behavior you want to document.

## What belongs here

Good contributions include:

- task-oriented guides for Plundarr, Privateerr, and generated Plundarr presets;
- Linux Docker, Synology, TrueNAS, and other platform-specific deployment help;
- corrected commands, links, screenshots, diagrams, and troubleshooting steps;
- accessibility, navigation, search, or theme improvements;
- container, workflow, linting, and supply-chain hardening for the wiki itself.

Questionable cargo includes:

- copying a sibling project's entire README into the wiki;
- undocumented platform assumptions presented as universal requirements;
- generated HTML from `site/` instead of its Markdown or theme source;
- speculative instructions that have not been checked against the owning
  project;
- credentials, private logs, live VPN configuration, or identifiable paths.

## Local setup

```sh
git clone https://github.com/scottgigawatt/plundarrpedia.git
cd plundarrpedia
cp example.env .env
```

Useful authoring and validation commands:

```sh
make serve
make markdown
make site
make clean
make config
pre-commit run --all-files
```

Open <http://localhost:8000> while `make serve` is running.

## Page structure

Start every public page with YAML front matter:

```yaml
---
title: Short Navigation Title
description: One sentence that explains the task and helps search results.
icon: material/compass
---
```

Then use exactly one H1 heading. Keep headings in sentence case and organize the
page around a reader's task rather than the source repository's file layout.

## Markdown conventions

- Use relative links for pages and assets inside Plundarrpedia.
- Use descriptive link text instead of “click here.”
- Give copyable commands the `sh` language without prompt characters or prose comments. Use `console` only for command output or a terminal transcript, and use the correct format such as `yaml`, `text`, or `ini` for configuration.
- Wrap prose naturally. The linter deliberately does not enforce a fixed line
  length because tables, URLs, and Material attributes can be wider.
- Put one blank line around headings, lists, tables, code fences, and
  admonitions.
- Explain acronyms the first time they appear on a route intended for new
  users.
- Prefer ordered steps for a procedure and checklists for preflight validation.
- Do not reproduce an entire project README. Link to the source when internal
  implementation detail becomes the subject.

## Writing standard

Write for the reader and the outcome rather than mirroring the source tree. Lead with the required action or conclusion, use active voice and second person in procedures, put conditions before instructions, and keep one main idea in each sentence or paragraph.

Use sentence-case headings with searchable nouns and active verbs. Keep short navigation labels concise, use numbered lists for procedures, use tables only for genuine comparisons, and link to the most specific useful source.

Reserve callouts for information that justifies interrupting the reading flow. Most pages need no more than one or two, and the warning itself must state the required action or risk without relying on nautical humor.

These choices follow the practical parts of [GitHub's documentation style guide](https://docs.github.com/en/contributing/style-guide-and-content-model/style-guide), [GitHub's content design principles](https://docs.github.com/en/contributing/writing-for-github-docs/content-design-principles), and the [Google developer documentation style highlights](https://developers.google.com/style/highlights). Plundarrpedia keeps its existing light nautical voice, Material components, and task-oriented structure rather than copying another site's editorial system wholesale.

## Material callouts

Use callouts when the reader needs to distinguish optional advice from a
security or data-loss boundary:

```markdown
!!! note
    Context that helps explain the surrounding instructions.

!!! tip
    A useful shortcut or operational improvement.

!!! warning
    A credible security, privacy, or service interruption risk.

!!! danger
    A likely destructive or irreversible action.
```

Keep the callout itself direct. Nautical humor belongs in the surrounding prose,
not in the part that tells a reader how to avoid losing data.

## Public-data boundary

Never commit:

- `.env` files or credentials;
- API keys, tokens, or webhook URLs;
- live WireGuard keys or generated `wg0.conf` files;
- private hostnames, public IP addresses, or identifiable local paths;
- raw logs that have not been reviewed and sanitized.

Use obvious placeholders such as `replace-me`, `/mnt/tank/media`, and
`192.0.2.10` when an example requires a value.

## Lint and preview

The repository uses markdownlint-cli2 through pre-commit. The shared rules in
`.markdownlint-cli2.yaml` understand the project's Markdown scope and permit the
inline HTML required for Material card grids and README badges. It also permits
Material's three-space card-list markers and mixed fenced/indented code inside
tabs and admonitions; MkDocs owns the rendering rules for those constructs.

```sh
make markdown
make serve
```

`make markdown` checks document structure. `make serve` provides the live
Material render at <http://localhost:8000>.

## Full validation

Before submitting a documentation change:

```sh
make markdown
make site
make clean
make config
make lint
```

Run `make build` when the Docker context, theme, requirements, or production
server can be affected. Run `make build-multiarch` when Dockerfile or workflow
changes can affect the published platform set.

!!! important
    A clean Markdown lint does not prove that navigation links resolve or that
    Material extensions render. A strict MkDocs build is required as well.

## Repository style

- Use an editor that honors the repository's root `.editorconfig` so source
  files keep consistent encoding, line endings, whitespace, and indentation.
- Public documentation may be lightly nautical, but the task comes first.
- Code, Dockerfile, Compose, Makefile, and workflow comments use plain English.
- Preserve the repository's copyright and file-purpose header style.
- Use separator-block comments to explain workflow and configuration sections.
- Keep GitHub Actions pinned to full commit SHAs.
- Keep container base images pinned by version and digest.
- Preserve `linux/amd64`, `linux/arm64`, and `linux/arm/v7` support unless a
  reviewed base-image constraint makes that impossible.
- Prefer `.env` variables over hardcoded deployment values where users may need
  a safe override.

## Release tags

- Create annotated semantic-version tags from commits already on `main`.
- Never move or reuse a published version tag.
- Successful `main` builds publish `edge` and a commit-SHA tag.
- Stable version tags publish the exact version and replace `latest`.
- Prerelease tags publish the prerelease and commit-SHA tags without replacing
  `latest`.
- Wait for Pages, image, scan, provenance, and attestation checks before
  announcing a release.

## Pull requests

Before opening a pull request:

- run the smallest relevant `make` targets;
- run `pre-commit run --all-files`;
- inspect the rendered light and dark themes for visual changes;
- confirm navigation and relative links resolve in a strict build;
- remove `.env`, `site/`, logs, and other generated or private files;
- explain what changed, why it changed, and how it was validated.

Smaller, focused pull requests are easier to review than a kraken-sized rewrite
with six unrelated tentacles.

## Security reports

Do not report vulnerabilities in public issues or pull requests. Use the
[security policy](SECURITY.md), or ask for a private route in the
[🔥HADES🔥 Discord](https://discord.gg/BpEGzWwGYf).

Fair winds, clean diffs, and may your YAML indent on the first try. ☠️
