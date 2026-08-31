---
title: Security Policy
description: Supported Plundarrpedia releases and private vulnerability reporting guidance.
icon: material/shield-lock
---

# Security policy 🛡️🏴‍☠️

Security reports for Plundarrpedia may involve the public website, production
container, GitHub Actions workflows, or an unsafe example that could expose a
reader's system. Use this policy to keep sensitive details out of public issues.

## Supported versions

Security fixes target the newest stable image and the current `main`/`edge`
line rather than every historical documentation snapshot.

| Version and channel             | Supported |
| ------------------------------- | --------- |
| `latest` stable image           | ✅        |
| `edge` image and `main` branch  | ✅        |
| Current GitHub Pages deployment | ✅        |
| Older version tags              | ❌        |
| Forks and modified images       | ❌        |

Issues in Plundarr, Privateerr, a selected third-party service, MkDocs Material, Nginx, or another linked upstream project should also be reported to the repository that owns the affected code. Plundarrpedia can correct unsafe guidance but cannot patch an upstream application.

## Reporting a vulnerability

Do not open a public GitHub issue for credential exposure, workflow privilege
escalation, container escape, exploitable configuration, or another report that
could help someone attack users.

Use GitHub private vulnerability reporting:

1. Open the repository's **Security** tab.
2. Choose **Report a vulnerability**.
3. Include reproduction steps, affected pages or files, tested image tags, and
   a clear description of the impact.

You may also ask for a private reporting route through the
[🔥HADES🔥 Discord](https://discord.gg/BpEGzWwGYf). Do not paste exploit details
or secret material into a public Discord channel.

If private vulnerability reporting is unavailable, open a public issue that
contains only a request for a secure contact method.

## What to include

Helpful private reports include:

- what you found and the security impact;
- exact reproduction steps;
- the page URL, commit, image tag, or workflow run involved;
- the affected platform and deployment method;
- minimal, sanitized logs or screenshots;
- whether the issue belongs to Plundarrpedia or a linked upstream project.

!!! danger
    Never include real passwords, API tokens, webhook URLs, WireGuard private
    keys, live `wg0.conf` files, public IP addresses, or unsanitized logs in a
    public report.

## Response expectations

This is a small maintainer project rather than a staffed security team. The
maintainer will make a reasonable effort to:

- acknowledge valid private reports within seven days;
- identify affected pages, images, releases, and upstream projects;
- correct accepted issues on `main` and publish an updated `edge` image;
- publish a stable release when a container fix is ready for `latest`;
- credit reporters when requested and safe to do so.

## Website and container boundaries

The GitHub Pages deployment is a static documentation site. It has no project
login, database, server-side API, or reader-supplied data store. Reports about
GitHub account security or GitHub Pages infrastructure belong to GitHub unless
Plundarrpedia's checked-in content or configuration caused the issue.

The production container serves generated static files with unprivileged Nginx.
The supplied Compose project runs the container read-only, drops capabilities,
enables `no-new-privileges`, and provides writable temporary filesystems only
where Nginx requires them.

## Build and publication security

The protected build path:

- runs pre-commit, Markdown, YAML, Dockerfile, and workflow validation;
- uses CodeQL to analyze GitHub Actions source;
- builds and scans the runtime image with Trivy before publication;
- supports `linux/amd64`, `linux/arm64`, and `linux/arm/v7`;
- publishes `edge` from successful `main` builds;
- publishes exact versions and `latest` from stable annotated tags;
- creates SBOM and provenance data and attaches a GitHub build attestation;
- pins GitHub Actions and container base images to immutable revisions.

Renovate proposes dependency changes for review instead of allowing published
build inputs to drift silently.

!!! tip
    Pull `latest` for the newest stable edition. Use `edge` only when you
    intentionally want the newest successful `main` build.

Fair winds, sharp eyes, and may every example keep its secrets redacted. ☠️
