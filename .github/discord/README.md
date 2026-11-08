# Discord build notifications

Workflow maintainers use this guide to configure optional Docker image and GitHub Pages notifications, edit copy, and preview messages locally. Run commands from the repository root with a POSIX shell, `jq`, and standard host utilities available. Delivery also requires `curl`.

## Configure destinations

You need permission to manage the intended Discord webhook and the repository’s Actions secrets. Keep webhook URLs out of files, command arguments, screenshots, and logs.

1. Create or select a webhook in the intended server and channel.
2. Confirm the server and channel in Discord; a secret name alone does not verify the destination.
3. In the repository’s **Settings → Secrets and variables → Actions**, store each optional webhook URL under the matching secret name below.
4. Follow [Preview without sending](#preview-without-sending) to inspect synthetic messages before a separately authorized live check.

| Profile | Destination | Repository Actions secret | Content |
| --- | --- | --- | --- |
| `image-primary` | Private Asteres | `DISCORD_WEBHOOK_URL` | Image notices with Reading Is Fundamental copy |
| `image-secondary` | Public Hades | `DISCORD_HADES_HOOK_URL` | Image notices with Underworld Archives copy |
| `docs` | Private Asteres | `DISCORD_WEBHOOK_URL` | GitHub Pages notices with Reading Is Fundamental copy |

Missing webhooks skip their destination. Each delivery is independent and uses a bounded timeout. Workflow notification steps use `continue-on-error: true`, so delivery failures do not change image or documentation results. Check the notification step outcome if a message is missing. Never publish a webhook URL in source, issues, logs, or screenshots.

## Understand events and colors

Image senders are **Plundarrpedia Image Builds • Reading Is Fundamental** for Asteres and **Plundarrpedia Image Builds • Underworld Archives** for Hades. The documentation sender is **Plundarrpedia Docs • Reading Is Fundamental**.

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
| [themes.jq](themes.jq) | Project identities, fixed image color, status colors, and two joke variants per outcome |
| [payloads/common.jq](payloads/common.jq) | Literal status sentences, metadata fields, length bounds, and disabled mentions |
| [payloads/](payloads/) | Payload entry point for each notification type |
| [discord-notifier.sh](../scripts/discord-notifier.sh) | Argument validation, outcome selection, rendering, and optional delivery |
| [test-discord-notifier.sh](../../test/helpers/test-discord-notifier.sh) | Deterministic offline coverage of states, evidence, and delivery failures |
| [test_discord_secret_scope.py](../../test/helpers/test_discord_secret_scope.py) | Guards explicit webhook names, destination profiles, and credential isolation |

Keep the first sentence factual and put only a short joke in each catalog variant. Asteres uses light gay culture humor; Hades uses light underworld humor. Keep corrective instructions and metadata labels literal. Use the published image name **Plundarrpedia** and distinguish its container image from the GitHub Pages website.

The supported notification types are `image-start`, `image-verdict`, `docs-start`, and `docs-verdict`. Documentation types accept only the `docs` profile. The catalog maps `start`, `success`, `failure`, `cancelled`, `skipped`, `neutral`, and `warning` to presentation. Unknown source conclusions become warnings instead of success. No separate warning or skipped-run workflow is introduced.

## Preview without sending

A dry run needs no webhook and never contacts Discord. Use synthetic values only; the JSON is intended for local inspection. The complete test suite also requires Python 3. Make requires the Docker Compose CLI while parsing, even though `make test-workflows` does not use the Docker daemon.

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
3. Run the credential scope guards and every supported result and variant:

   ```sh
   make test-workflows
   ```

Without the Compose CLI, run the same checks directly:

```sh
python3 test/helpers/test_discord_secret_scope.py
sh test/helpers/test-discord-notifier.sh
```

The expected result reports `OK` for the credential scope tests, then ends with `Discord notifier checks passed`. The scope guards reject wrong destination bindings, broad or computed secret access, and cross-server fallback. Both suites use synthetic metadata and stubbed transport; they do not prove that a real webhook is configured or a live Discord message renders correctly.

## Review changes

Run `make test-workflows`, `make markdown`, `pre-commit run --all-files`, and `git diff --check`. For changes to the public documentation journey, run the strict site build and inspect links and narrow layouts as described in [contributing](../../docs/CONTRIBUTING.md#full-validation). Record which checks ran and any unavailable tooling.

Live test sends need explicit authorization and confirmed destinations. Editing the notifier does not authorize dispatching workflows, publishing images, deploying Pages, or changing webhook secrets.
