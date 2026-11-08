# Discord build and documentation notifications

Maintainers use this guide to configure destinations, edit notification copy, and test payloads without sending messages. Run commands from the repository root with a POSIX shell and `jq` available. The helper also uses standard host utilities; delivery requires `curl`.

## Configure destinations

Create optional repository secrets in **Settings → Secrets and variables → Actions**. Confirm that each webhook belongs to the intended server and channel before using it. A secret name alone does not verify its destination.

| Profile | Repository secret | Destination and content |
| --- | --- | --- |
| `image-primary` | `DISCORD_WEBHOOK_URL` | Asteres: image pipeline updates with Reading Is Fundamental copy |
| `image-secondary` | `DISCORD_HADES_HOOK_URL` | Hades: image pipeline updates with Underworld Archives copy |
| `docs` | `DISCORD_WEBHOOK_URL` | Asteres only: documentation updates with Reading Is Fundamental copy |

Missing webhooks skip their destination. Each delivery is independent and uses a bounded timeout. Workflow notification steps use `continue-on-error: true`, so delivery failures do not change image or documentation results. Check the notification step outcome if a message is missing. Never publish a webhook URL in source, issues, logs, or screenshots.

## Understand events and colors

The image workflow reports the start of the image pipeline before release validation, building, scanning, and publication. Its final notification distinguishes the pipeline result from the actual GHCR push result. The Pages workflow reports documentation updates separately from Docker image publication; a separate result job observes both the site build and deployment, including a failed build that prevents deployment.

| Event or result | Color | Meaning |
| --- | --- | --- |
| Image or documentation started | Blue `#3B82F6` | The selected pipeline started |
| Successful image publication or Pages deployment | Green `#57F287` | Required pipeline checks passed |
| Failure, timeout, or startup failure | Red `#ED4245` | The pipeline did not complete successfully |
| Warning, action required, or unrecognized result | Yellow `#FEE75C` | Review the available result and evidence |
| Cancelled, skipped, or neutral | Gray `#99AAB5` | The update stopped or has no success/failure conclusion |

A successful job without confirmed push evidence is yellow, never green. Published tags and digest appear only after a confirmed push with a digest. When a later stage fails after a push, the message states that publication already occurred and identifies the stage needing attention. No failure message promises that nothing was published or deployed.

Documentation success means the build and Pages deployment both succeeded. Failure text identifies the documentation build or Pages deployment. Cancelled and skipped updates use their own wording instead of failure copy. Workflow names remain metadata; funny workflow titles never become part of a status sentence.

## Edit copy and presentation

| Source | Responsibility |
| --- | --- |
| `themes.jq` | Project identities, fixed image color, status colors, and two joke variants per outcome |
| `payloads/common.jq` | Literal status sentences, metadata fields, length bounds, and disabled mentions |
| `payloads/*.jq` | Payload entry point for each notification type |
| `../scripts/discord-notifier.sh` | Argument validation, outcome selection, rendering, and optional delivery |
| `../../test/helpers/test-discord-notifier.sh` | Deterministic offline coverage of states, evidence, and delivery failures |

Keep the first sentence factual and put only a short joke in each catalog variant. Asteres uses light gay culture humor; Hades uses light underworld humor. Keep corrective instructions and metadata labels literal. Use the published image name **Plundarrpedia** and distinguish its container image from the GitHub Pages website.

The supported notification types are `image-start`, `image-verdict`, `docs-start`, and `docs-verdict`. Documentation types accept only the `docs` profile. The catalog maps `start`, `success`, `failure`, `cancelled`, `skipped`, `neutral`, and `warning` to presentation. Unknown source conclusions become warnings instead of success. No separate warning or skipped-run workflow is introduced.

## Preview without sending

A dry run needs no webhook and never contacts Discord. Use synthetic values only; the JSON is intended for local inspection.

1. Render the first Asteres start variant:

   ```sh
   sh .github/scripts/discord-notifier.sh \
       --type image-start \
       --profile image-primary \
       --image-name Plundarrpedia \
       --run-url https://example.invalid/run \
       --repository example/plundarrpedia \
       --ref-name example-ref \
       --ghcr-image ghcr.io/example/plundarrpedia \
       --random-value 0 \
       --dry-run
   ```

2. Confirm the sender identifies the image, the title says the pipeline started, the embed color is `3900150` (`#3B82F6`), and `allowed_mentions.parse` is empty. Select `--random-value 1` for the other joke or `--profile image-secondary` for Hades.
3. Run every supported result and variant:

   ```sh
   make test-workflows
   ```

The expected result ends with `Discord notifier checks passed`. The tests use synthetic metadata and a stubbed transport; they do not prove that a real webhook is configured or a live Discord message renders correctly. Make also requires the Docker Compose CLI while parsing, even though this suite does not use the Docker daemon. Without Compose, run `sh test/helpers/test-discord-notifier.sh` directly.

## Review changes

Run `make test-workflows`, `make markdown`, `pre-commit run --all-files`, and `git diff --check`. For changes to the public documentation journey, run the strict site build and inspect links and narrow layouts as described in [contributing](../../docs/CONTRIBUTING.md#full-validation). Record which checks ran and any unavailable tooling.

Live test sends need explicit authorization and confirmed destinations. Editing the notifier does not authorize dispatching workflows, publishing images, deploying Pages, or changing webhook secrets.
