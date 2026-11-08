# Workflow notification helper

Maintainers use `discord-notifier.sh` to validate metadata, render a selected payload, and optionally deliver it to Discord. The helper reads repository-owned data; it never evaluates message text as shell code.

Follow the [notification guide](../discord/README.md) for destination secrets, profiles, colors, copy ownership, safe dry runs, and delivery troubleshooting. Use `sh .github/scripts/discord-notifier.sh --help` from the repository root for supported arguments.

Image verdict callers pass `--job-status` for the pipeline result, `--publication-status` for the actual push outcome, and `--failure-stage` when a stage needs attention. `--published-tags` and `--published-digest` are publication evidence only after a confirmed push. Documentation verdict callers pass independent `--build-status` and `--deploy-status` values.

Run `make test-workflows` to exercise synthetic payloads and stubbed transport without contacting Discord. A dry run validates local rendering; it does not verify a server destination or successful publication.
