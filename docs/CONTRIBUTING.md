---
title: Writing and Contributing
description: Format, lint, preview, and validate task-oriented Plundarrpedia pages.
icon: material/text-box-edit
---

# Writing and contributing

Plundarrpedia is maintained as Markdown, but valid Markdown alone is not enough.
Pages also need stable navigation, accurate examples, safe public data, and a
clean Material for MkDocs render.

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
- Give fenced command examples the `console` language and configuration
  examples the correct format such as `yaml`, `text`, or `ini`.
- Wrap prose naturally. The linter deliberately does not enforce a fixed line
  length because tables, URLs, and Material attributes can be wider.
- Put one blank line around headings, lists, tables, code fences, and
  admonitions.
- Explain acronyms the first time they appear on a route intended for new
  users.
- Prefer ordered steps for a procedure and checklists for preflight validation.
- Do not reproduce an entire project README. Link to the source when internal
  implementation detail becomes the subject.

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

```console
make markdown
make serve
```

`make markdown` checks document structure. `make serve` provides the live
Material render at <http://localhost:8000>.

## Full validation

Before submitting a documentation change:

```console
make markdown
make site
make config
make lint
```

Run `make build` when the Docker context, theme, requirements, or production
server can be affected. Run `make build-multiarch` when Dockerfile or workflow
changes can affect the published platform set.

!!! important
    A clean Markdown lint does not prove that navigation links resolve or that
    Material extensions render. A strict MkDocs build is required as well.
