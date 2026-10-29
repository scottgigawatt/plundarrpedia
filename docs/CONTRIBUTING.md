---
title: Contributing
description: Propose, format, preview, validate, and submit Plundarrpedia improvements.
icon: material/text-box-edit
---

# Contributing to Plundarrpedia 🏴‍☠️

Help readers complete a deployment or solve a problem. Accurate commands, a usable structure, and a clear rendered page matter as much as valid Markdown.

## Before you start

Check existing issues/PRs and identify the repository that owns the behavior. Read the [security policy](SECURITY.md) and [code of conduct](CODE_OF_CONDUCT.md). Use public example values throughout.

## What belongs here

Keep integrated operator guides, platform-specific deployment steps, troubleshooting, and site improvements here. Link to sibling projects for exact configuration and developer contracts. Do not copy complete READMEs, publish speculative instructions, or commit generated `site/` output.

## Local setup

You need Git, Make, Docker with Compose, and pre-commit for lint. From a new checkout:

```sh
git clone https://github.com/scottgigawatt/plundarrpedia.git
cd plundarrpedia
cp example.env .env
make serve
```

Keep an existing `.env`; never overwrite it for validation. The preview opens at <http://localhost:8000>; change the authoring port with `make serve MKDOCS_AUTHOR_PORT=8001`. Initial tool builds/hooks can need network access.

## Page structure

Public site pages start with front matter:

```yaml
---
title: Short navigation title
description: The reader task this page helps complete.
icon: material/compass
---
```

Use one H1, sentence-case headings, and a logical hierarchy. Registry copy is written for its destination rather than site front matter. Keep existing routes and anchors, or update inbound links and provide a compatibility route.

## Markdown conventions

Use descriptive relative links, language-labeled fences, and blank lines around blocks. Copyable commands use `sh` without prompts or prose comments; output uses `console`. Keep ordinary paragraphs on one physical source line with editor wrapping.

Number ordered procedures; use bullets for parallel choices and tables for genuine comparisons. Material tabs/cards belong only where `mkdocs.yml` supports them. Shared repository Markdown must render on GitHub. Give images meaningful alt text and diagrams an equivalent explanation.

## Writing standard

Project-owned documentation and related Markdown must follow [GitHub's style guide](https://docs.github.com/en/contributing/style-guide-and-content-model/style-guide), [writing best practices](https://docs.github.com/en/contributing/writing-for-github-docs/best-practices-for-github-docs), [Markdown guidance](https://docs.github.com/en/get-started/writing-on-github), and [ISO 24495-1:2023](https://www.iso.org/standard/78907.html).

Make information relevant, findable, understandable, and usable for the intended reader. State the task, prerequisites, and required decisions; lead with actions/results; use familiar words and active voice. Include expected results and recovery where needed. Keep short nautical touches outside commands and warnings.

Maintain one canonical explanation per topic. Remove obsolete, duplicate, speculative, and non-actionable content; preserve safety, compatibility, backup/restore limits, support policy, licensing, and attribution. Essential local steps should remain together.

Review the changed reader journey from its entry point through verification, including assumptions, links, failure recovery, and narrow-screen use. Record which journeys you checked and distinguish author review from actual reader feedback/testing. Lint and a strict build do not prove usability or ISO conformity. Preserve existing badge/community blocks; place H1 and purpose before them.

## GitHub alerts

Use native GitHub alerts; `pymdownx.quotes` renders them on the site. Most pages need at most one or two. Avoid consecutive alerts, routine commands inside callouts, custom titles, or MkDocs-only `!!!` syntax.

| Alert | Use |
| --- | --- |
| `[!NOTE]` | Useful context |
| `[!TIP]` | Easier way to complete a task |
| `[!IMPORTANT]` | Information required for success |
| `[!WARNING]` | A problem needing immediate attention |
| `[!CAUTION]` | Risk or destructive outcome |

Put quoted prose directly below the marker; use blank quoted lines only between paragraphs or around lists/code. State risks, affected data, backups, and recovery before disruptive commands. Keep risks visible outside collapsible content.

## Public-data boundary

Never publish credentials, webhook URLs, live VPN configuration, private hostnames/paths, identifying addresses, or unsanitized logs/screenshots. Use obvious placeholders and reserved examples such as `192.0.2.10`. Resolved Compose output can contain secrets.

## Lint and preview

`make markdown` runs markdownlint; `make serve` provides the live Material preview. Make checks Docker/Compose availability while parsing even these targets. Check GitHub rendering separately for repository-only files.

## Full validation

From the repository root:

```sh
make markdown
make site
pre-commit run --all-files
git diff --check
```

Site export needs a working Docker daemon and local `.env`; use isolated public defaults for validation. Pre-commit's hadolint hook also needs Docker. Check spelling, relative links/anchors, navigation, alerts, code, and affected light/dark/narrow-screen renders. Report unavailable checks.

Run `make config` with public defaults for Compose changes, `make build` for image/theme/requirements changes, and `make build-multiarch` when published platforms can be affected. Neither strict MkDocs nor lint proves all external links work or live instructions succeed.

## Repository style

Honor `.editorconfig` and existing copyright/license headers. Code/configuration comments stay plain English. Preserve pinned inputs, supported architectures, hardening, and operator overrides; do not turn prose cleanup into unrelated tooling changes.

## Release tags

Publication is separate from editing/validation. Follow the [publishing rules](ADVANCED_USAGE.md#publishing-routes): annotated immutable semantic-version tags on `main`, verified workflows, and no stable alias for prereleases.

## Pull requests

Explain the reader problem, resulting changes, and actual validation. Keep changes focused; review the complete diff for secrets/generated files. Use the PR checklist to record results and reader-journey coverage.

## Security reports

Report vulnerabilities privately under the [security policy](SECURITY.md). Ask for a private contact route if needed; do not post exploit details in public issues or Discord.
