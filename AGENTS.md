# Plundarrpedia contributor guide

## Purpose and repository map

Plundarrpedia is a public, task-oriented wiki for self-hosted media deployment, configuration generation, and associated presets. Material for MkDocs renders the source for GitHub Pages and a production container image.

| Path | Responsibility |
| --- | --- |
| `docs/` | Public Markdown pages, front matter, and visual assets. |
| `mkdocs.yml` | Explicit navigation, theme features, and Markdown extensions. |
| `overrides/` | Material theme templates. |
| `docker/` | Multi-stage image build and production Nginx configuration. |
| `docker-compose.yml`, `example.env` | Production, authoring, and site-export services and public defaults. |
| `Makefile` | Local build, preview, validation, and runtime operations. |
| `requirements.txt` | Exact top-level Material dependency, shared by container and Pages builds. |
| `.github/`, `.pre-commit-config.yaml`, `.markdownlint-cli2.yaml` | Automation and repository checks. |

This guide applies throughout the repository. Before editing, inspect any applicable nested `AGENTS.md` and relevant `.agents/skills/` instructions if present; narrower guidance governs its subtree. Read the local [contribution guide](docs/CONTRIBUTING.md), [security policy](docs/SECURITY.md), and [PR template](.github/PULL_REQUEST_TEMPLATE.md) for context. This file contains the core agent rules without requiring guidance from another repository. Report contradictions in linked guidance rather than silently changing unrelated files.

## Scope and working tree

- Inspect branch, status, and diff before work. Start from fresh `main` for new work; use an isolated checkout or worktree when existing edits must be preserved.
- Keep changes focused on the requested outcome. Preserve unrelated staged, unstaged, and untracked work; do not reset, clean, or overwrite it.
- Consolidate duplicated guidance while retaining meaningful local constraints. Do not turn a documentation task into a tooling, dependency, workflow, or security-settings rewrite.
- Repository edits and local validation do not authorize production operations. Respect explicit manual review checkpoints; do not merge, approve, enable auto-merge, deploy, publish, or create release tags without authorization for that operation.

## Source, runtime, and secrets

- Edit Markdown, configuration, templates, and assets at their source. Do not hand-edit or commit generated `site/` HTML, local `.env`, caches, logs, or build artifacts.
- Preserve YAML front matter and navigation paths when moving or renaming pages. Update affected links and anchors together; retain compatibility routes when readers depend on them.
- Keep the production runtime distinct from authoring: production serves generated files with unprivileged Nginx on port `8080`; MkDocs live reload belongs to the opt-in authoring service. The runtime contains neither the Python toolchain nor wiki sources.
- Preserve the read-only runtime, dropped Linux capabilities, no-new-privileges setting, writable `/tmp`, health endpoint, and complete OCI metadata when relevant changes are authorized.
- Keep `linux/amd64`, `linux/arm64`, and `linux/arm/v7` support. Surface any base-image limitation for review rather than silently dropping a platform.
- Never commit credentials, tokens, webhook URLs, live WireGuard keys or `wg0.conf`, private hostnames, identifying local paths, real deployment addresses, or unsanitized logs/screenshots. Use obvious placeholders and reserved examples such as `replace-me` and `192.0.2.10`.
- Do not print secrets through environment dumps, Compose interpolation, shell tracing, or diagnostic output. Validate with public example values and keep sensitive reports private under the security policy.
- Prefer `.env` variables over hardcoded deployment values where users need a safe override. Keep public defaults in `example.env` and local deployment values in the ignored `.env` file.

## Style and code quality

- Honor `.editorconfig`: UTF-8, LF, final newline, and no trailing whitespace. Use two spaces for the configured Markdown, YAML, JSON/JSON5, CSS, HTML, and SVG groups; exceptions use four spaces for all `.github/` YAML, `.github/renovate.json5`, `.vscode/` JSON, `*.conf`, and Dockerfile content, and tabs for Make recipes. Preserve these numeric exceptions rather than reformatting unrelated files.
- Keep public prose useful first and lightly nautical second. Explain acronyms and platform assumptions; preserve named Synology, TrueNAS, and ordinary Docker coverage when affected. Code, Dockerfile, Compose, Makefile, and workflow operational comments stay plain English. Preserve themed workflow names and status text without carrying that voice into operational comments, commands, or warnings.
- Preserve the local top-of-file header order: copyright, blank comment separator, license, blank comment separator, then `filename: purpose`, with aligned continuation lines when needed. The current owned-source wording is `Copyright 2026 Scott Gigawatt` and `Licensed under the Apache License, Version 2.0.`; retain existing years, owners, upstream attribution, and required notices rather than blanket-rewriting them. New source files should follow the nearest applicable local header, not add headers ahead of required page front matter.
- Use language-appropriate comment delimiters and blank comment separators: `#` for YAML, Make, Dockerfile, environment, and Nginx source; `//` for JSON5; `/* ... */` with aligned asterisk-only separator lines for CSS; `<!-- ... -->` for SVG and HTML comments; and `{# ... #}` for Jinja templates. Preserve each file family's existing layout; do not retrofit headers into Markdown pages, front matter, or strict JSON that does not support them. For example, the Makefile header is:

  ```makefile
  #
  # Copyright 2026 Scott Gigawatt
  #
  # Licensed under the Apache License, Version 2.0.
  #
  # Makefile: Automation for building, previewing, validating, and running
  #           Plundarrpedia through its Docker Compose application.
  #
  ```

- Require framed separator-block comments for workflow and configuration sections: place the section explanation between blank comment lines using the file's native comment syntax. Preserve the existing layout and plain-English purpose, constraints, and non-obvious tradeoffs rather than replacing it with terse labels or syntax narration.
- Preserve the aligned inline option comments in Compose, including comments for shared anchors, build arguments, and service options. Keep explanations accurate when an authorized change modifies the option; do not strip or reflow unrelated comments.
- Use the existing formatter and linter configuration. Do not add blanket suppressions, disable checks, or expand secret baselines to hide failures; any necessary exception must be narrow and explained.
- For actual shell snippets in workflows and Make, honor the selected shell, quote expansions, and propagate failures. Put blank lines before and after control-flow blocks and logical sections, with explanatory comments above non-obvious checks, loops, or operations. Preserve Make recipe backslashes, shell continuations, and workflow YAML block semantics when adding that spacing. Validate workflow changes with the configured Actionlint hook; do not introduce unrelated application-language standards or claim application tests for this documentation site.
- When executable behavior changes, add or extend focused checks for the affected behavior. Do not introduce tests that merely repeat prose or implementation details.

## Documentation standards

Apply [GitHub's documentation style guide](https://docs.github.com/en/contributing/style-guide-and-content-model/style-guide), [writing best practices](https://docs.github.com/en/contributing/writing-for-github-docs/best-practices-for-github-docs), and [Markdown guidance](https://docs.github.com/en/get-started/writing-on-github), together with [ISO 24495-1:2023](https://www.iso.org/standard/78907.html), as mandatory writing requirements for project-owned documentation and related Markdown. Preserve this repository's renderer and operational constraints when applying them.

- Make content relevant, findable, understandable, and usable for its intended readers. State the task and audience, include required decisions and prerequisites, and show how to verify the result.
- Keep one canonical explanation for each topic. This wiki owns integrated operator walkthroughs; sibling projects own exact source, configuration, and developer contracts. Keep essential local steps together and link to detailed references. Remove obsolete, repeated, speculative, or non-actionable material; preserve warnings, backup/restore limits, support policy, licensing, and attribution.
- Review changed reader journeys from entry point through expected result, including links, assumptions, failure recovery, and narrow-screen rendering. Record the journeys and evidence checked; automated lint/build checks alone do not establish usability or ISO conformity. Obtain reader feedback when available and address it before claiming a successful reader evaluation.
- Preserve existing badge and community blocks intact. Put the project H1 and a short purpose statement before the block; keep useful technical prose ahead of decorative commentary.

- Lead with the reader's task, action, or conclusion. Use active voice and second person in procedures, put conditions before instructions, and keep one main idea per sentence or paragraph. Write concise sentence-case headings with searchable nouns and active verbs and a clear H1/H2/H3 hierarchy; use one H1 per page and do not skip heading levels.
- Public pages in `docs/` require YAML front matter with a useful `title`, `description`, and suitable `icon`. Keep navigation labels concise and maintain the explicit `mkdocs.yml` hierarchy.
- Keep ordinary prose paragraphs on one physical source line with editor wrapping. Preserve semantic blank lines and the indentation required by lists, tables, tabs, and admonitions. Surround block elements with blank lines.
- Use numbered lists for ordered procedures, checklists for preflight validation, bullets for parallel points, and readable tables only for genuine comparisons. Keep callouts sparse and direct; never hide destructive-operation warnings in collapsible content.
- Use descriptive relative links for local pages and assets, with valid case-sensitive paths and actual heading anchors. Check inbound links when headings change. Use precise authoritative evidence for product claims, verifying the relevant version and configuration rather than copying assumptions or entire READMEs.
- Choose native syntax for the renderer. Repository-facing Markdown uses GitHub-flavored Markdown. The wiki uses the Material extensions configured in `mkdocs.yml`; preserve needed tabs, card grids, attributes, Material's three-space card-list markers, and nested tab/code/fence indentation rather than forcing GitHub-only syntax onto them.
- For alerts shared by GitHub and the wiki, use native `> [!NOTE]` for useful context, `> [!TIP]` for advice that makes a task easier, `> [!IMPORTANT]` for information required for success, `> [!WARNING]` for immediate attention needed to avoid a problem, and `> [!CAUTION]` for risks or destructive outcomes. The configured `pymdownx.quotes` extension converts them to Material admonitions. Do not use custom alert titles or MkDocs-only `!!!` alerts. Verify both renderers when changing alert syntax or rendering.
- Use one or two alerts per page where possible. Do not place alerts consecutively, nest them inside other elements, wrap routine commands in them, or hide risks in collapsible content. Keep the first quoted prose line directly below the marker; use blank quoted lines only between paragraphs or to delimit lists or fenced code. State the required action or risk literally and directly; keep nautical humor outside the alert.
- Label fenced code with its actual language: `sh` for copyable commands, `console` for output/transcripts, and formats such as `yaml`, `ini`, or `text` for configuration. Omit shell prompt characters and prose comments from command blocks. Use safe, secret-free placeholders and make commands copyable from the stated working directory.
- State prerequisites, required tools, platform/version assumptions, expected results, and validation steps before a procedure. Warn before destructive operations and explain their scope, backups, and recovery. Distinguish build/preview commands from runtime-changing commands.
- Describe current stable behavior accurately and label unreleased behavior explicitly. Explain migration steps, compatibility breaks, architecture limits, persistent-data/permission effects, and backup/rollback caveats where applicable. Configuration generators produce settings; Gluetun runs the VPN tunnel. Present generated presets as presets rather than separately maintained documentation products.
- Give meaningful image alt text, redact screenshots, and keep diagrams consistent with the surrounding architecture explanation. Inspect light and dark themes for visual changes.
- Markdown lint is only one check: build the site strictly, inspect affected rendered pages and components, and check navigation, relative links, images, and anchors. A successful build does not prove all external URLs are reachable or that instructions work against a live service.

## Make and local operations

- Read the target before running it. Bare `make` currently builds the production image through `all: build`; it is not a harmless help command. Use `make help` to list targets.
- Make checks Docker Compose availability while parsing, even for `help`, `markdown`, `lint`, and `clean`. Docker and Compose must be installed; image and site builds also need a working daemon and may pull dependencies.
- Build, site, config, and runtime targets require `.env`; copy `example.env` only when `.env` is absent, and use public defaults for validation. `make serve` can fall back to `example.env`. Never overwrite an existing deployment environment.
- `make serve` runs live reload on host port `8000` by default. `make serve MKDOCS_AUTHOR_PORT=8001` avoids a local port conflict. `make site` exports a strict build to `site/`; it does not start the production server.
- `make clean` deletes the configured generated site directory. Inspect `SITE_OUTPUT_PATH` before using it; existing guards reject some unsafe paths, but they are not a reason to trust arbitrary overrides or shell input.
- `make run`/`up` builds and starts/recreates the production stack; `start`, `stop`, and `down` change container state. These are operational actions, not ordinary lint checks. Avoid them during documentation-only validation.
- For authorized Make changes, preserve `.PHONY` declarations, real prerequisites, quoted paths, failure propagation, safe cleanup checks, and separation of validation from runtime operations. Do not introduce implicit destructive or credentialed actions into default/check targets.
- Preserve Make's framed target-purpose comments in the existing `$(TARGET): Purpose.` form. Where prerequisites exist, retain the `Dependencies:` block with an aligned entry explaining each real prerequisite, enclosed by blank `#` separator lines. Update those explanations when dependencies change; do not replace the blocks with bare target names or invent prerequisites for presentation.
- Keep variable-driven target names, the `TARGETS`/`.PHONY` grouping, aligned settings, compatibility aliases, and aligned help presentation. Keep target-purpose and prerequisite documentation, actual behavior, aliases, and help output consistent when an authorized change affects them.

## Dependencies and automation

- Keep Actions pinned to full commit SHAs and container bases to reviewed version/digest pairs; keep related defaults consistent when dependency changes are authorized. Let Renovate propose updates and review their compatibility and validation.
- Describe reproducibility honestly: `requirements.txt` pins the top-level Material version, but transitive Python dependencies are not fully locked or hash-verified; hook revisions use version tags, and runtime Alpine upgrades can resolve newer packages. Do not describe the whole toolchain as immutable or silently rewrite its locking policy in an unrelated task.
- Keep default workflow permissions read-only and grant only the minimum additional job permissions needed. Avoid retained checkout credentials, untrusted interpolation into shell code, and exposing secrets to untrusted PR code.
- Preserve Trivy scanning, SBOM, provenance, and image attestations for published images. Do not bypass failing checks or change security settings to make a PR pass.
- Publishing is separate from validation: current workflows publish `edge`/commit-SHA tags for applicable `main` builds and version-derived tags for releases; stable versions update `latest`, prereleases do not. Pages and image workflows have source-path filters, so an arbitrary guidance-only merge does not imply publication. Existing mutable consumer tags are not immutable pins.
- If a release is separately authorized, follow the local annotated semantic-version tag policy from a commit already on `main`; never move or reuse published version tags. Wait for applicable Pages, image, scan, provenance, and attestation checks before announcing a release. Updating this guide does not itself authorize a release or workflow dispatch.

## Validation

Run checks appropriate to the changed files and record exact results. Use public example values only; no live VPN, media-server, credentialed integration, or production access is required for guidance or wiki validation.

| Change | Real local checks |
| --- | --- |
| Agent guidance or other Markdown | `make markdown`, `pre-commit run --all-files`, and `git diff --check`. |
| Public pages, navigation, extensions, or theme | Above checks plus `make site`; inspect affected pages, links, anchors, and components in the rendered site. |
| Compose or environment examples | `make config` using a local `.env` copied from public defaults; review output for secrets before sharing. |
| Docker context, requirements, theme, or runtime | `make build`; use `make build-multiarch` when image inputs or workflows affect published platforms. |
| Workflow or container source | Relevant pre-commit actionlint, YAML, and hadolint checks plus the build/config checks affected by the change. |

With installed dependencies or cached hook environments, Markdown and static checks can run offline. Initial pre-commit setup can need network access; the hadolint hook uses Docker. Compose config validation needs the CLI but does not start containers. Container builds need the daemon and potentially registry/package access. Report missing prerequisites rather than treating skipped checks as passing.

As used in CI, a strict site build can also run from the repository root in an isolated Python environment with the dependencies from `requirements.txt` installed:

```sh
mkdocs build --strict
```

This validates the configured source site, not the production Nginx image or all three architectures. The root `AGENTS.md` is outside `docs/` and is checked by Markdown lint rather than rendered as a wiki page. Do not claim a render review for files the site does not include. `make build-multiarch` is a cache-only Buildx validation by default, not an image publication command.

## Handoff

Review the complete diff for scope, accuracy, secrets, and generated files before committing. Summarize what changed and why, exact files, checks passed/failed/not run with reasons, any existing failures or conflicting guidance, and remaining limitations. Include branch/head SHA and PR URL when created. Keep manual review checkpoints explicit and leave requested draft PRs unmerged; do not report pending CI or checks that were not run as passing.
