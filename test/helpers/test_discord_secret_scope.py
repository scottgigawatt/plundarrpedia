#
# Copyright 2026 Scott Gigawatt
#
# SPDX-License-Identifier: Apache-2.0
#
# test_discord_secret_scope.py: Guard explicit notification credentials and
#                              isolate optional image and documentation routes.
#

"""Reject broad secret access and cross-server fallback in static notifier steps."""

import os
import re
import subprocess
import tempfile
import unittest
from collections.abc import Mapping
from pathlib import Path

REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ("build-and-push.yml", "pages.yml")
EXPECTED_ROUTES = {
    ("image-start", "image-primary"): "DISCORD_WEBHOOK_URL",
    ("image-start", "image-secondary"): "DISCORD_HADES_HOOK_URL",
    ("image-verdict", "image-primary"): "DISCORD_WEBHOOK_URL",
    ("image-verdict", "image-secondary"): "DISCORD_HADES_HOOK_URL",
    ("docs-start", "docs"): "DISCORD_WEBHOOK_URL",
    ("docs-verdict", "docs"): "DISCORD_WEBHOOK_URL",
}
SECRET_EXPRESSION = re.compile(r"\$\{\{(.*?)}}", re.DOTALL)


def literal_webhook(expression: str, values: Mapping[str, str]) -> str:
    """Resolve only a named webhook; an absent destination has no fallback."""
    match = re.fullmatch(r"secrets\.([A-Z_]+)", expression.strip())

    if match is None or match[1] not in set(EXPECTED_ROUTES.values()):
        raise ValueError("Notification credentials must use one literal webhook name.")

    return values.get(match[1], "")


def workflow_steps(source: str) -> list[tuple[int, int, str]]:
    """Locate the repository's block-style steps without evaluating YAML or shell."""
    # Retain newline characters so expression offsets stay exact.
    lines = source.splitlines(True)
    offsets = [0]

    for line in lines:
        offsets.append(offsets[-1] + len(line))

    steps = []

    # Workflows use four-space YAML indentation and named, block-style steps.
    # Stop at the next step or job, leaving their contents outside this scope.
    for index, line in enumerate(lines):
        if not line.startswith("            - name:"):
            continue

        end = index + 1

        while end < len(lines):
            candidate = lines[end]
            content = candidate.strip()

            if content and not content.startswith("#"):
                indentation = len(candidate) - len(candidate.lstrip())

                if indentation <= 12:
                    break

            end += 1

        steps.append((offsets[index], offsets[end], "".join(lines[index:end])))

    return steps


def notification_bindings(sources: Mapping[str, str]) -> dict[tuple[str, str], str]:
    """Validate the six real routes and the scope of every secret expression."""
    bindings = {}

    for filename, source in sources.items():
        steps = workflow_steps(source)

        # Publishing steps may use their own named credentials. Notification
        # steps must not inherit them or export a broad secret context.
        for expression in SECRET_EXPRESSION.finditer(source):
            if not re.search(r"\bsecrets\b", expression[1], re.IGNORECASE):
                continue

            owner = next(
                (block for start, end, block in steps if start <= expression.start() < end),
                None,
            )

            if owner is None:
                raise ValueError("Credentials must not be inherited by notification steps.")

            if ".github/scripts/discord-notifier.sh" not in owner:
                named = re.fullmatch(r"secrets\.([A-Z_]+)", expression[1].strip())

                if named is None or named[1] in set(EXPECTED_ROUTES.values()):
                    raise ValueError("Publishing steps need their own named credentials.")

        for _, _, block in steps:
            if ".github/scripts/discord-notifier.sh" not in block:
                continue

            webhook = re.findall(
                r"^\s+DISCORD_WEBHOOK_URL:\s*\$\{\{\s*(.*?)\s*}}\s*$",
                block,
                re.MULTILINE,
            )
            types = re.findall(r"--type\s+([^\s\\]+)", block)
            profiles = re.findall(r"--profile\s+([^\s\\]+)", block)
            secret_access = [
                match[1].strip()
                for match in SECRET_EXPRESSION.finditer(block)
                if re.search(r"\bsecrets\b", match[1], re.IGNORECASE)
            ]

            if (
                len(webhook) != 1
                or len(types) != 1
                or len(profiles) != 1
                or secret_access != webhook
            ):
                raise ValueError("Each notifier step needs one event, profile, and scoped webhook.")

            route = (types[0], profiles[0])
            expected = EXPECTED_ROUTES.get(route)

            if route in bindings or expected is None or webhook[0] != "secrets." + expected:
                raise ValueError("Notification profile does not match its literal destination.")

            if filename != ("pages.yml" if route[0].startswith("docs-") else "build-and-push.yml"):
                raise ValueError("Image and documentation notifications must retain their workflows.")

            literal_webhook(webhook[0], {})
            bindings[route] = webhook[0]

    if set(bindings) != set(EXPECTED_ROUTES):
        raise ValueError("Both image destinations and Asteres-only documentation need complete routes.")

    return bindings


class NotificationSecretScopeTests(unittest.TestCase):
    """Exercise actual bindings and synthetic routing/security regressions."""

    def setUp(self) -> None:
        """Read maintained workflows; test fixtures never contain real secrets."""
        self.sources = {
            name: (REPOSITORY_ROOT / ".github/workflows" / name).read_text()
            for name in WORKFLOWS
        }

    def test_actual_routes_with_missing_optional_webhooks(self) -> None:
        """Neither server can inherit the other destination's configured webhook."""
        bindings = notification_bindings(self.sources)

        for primary, secondary in (("asteres", "hades"), ("", "hades"), ("asteres", ""), ("", "")):
            values = {"DISCORD_WEBHOOK_URL": primary, "DISCORD_HADES_HOOK_URL": secondary}

            for route, expression in bindings.items():
                with self.subTest(route=route, configured=values):
                    self.assertEqual(
                        literal_webhook(expression, values), values[EXPECTED_ROUTES[route]]
                    )

    def test_notification_context_arguments(self) -> None:
        """Every actual notice supplies linked user and workflow context."""
        notices = 0

        for source in self.sources.values():
            for _, _, block in workflow_steps(source):
                if ".github/scripts/discord-notifier.sh" not in block:
                    continue

                notices += 1
                self.assertIn("ACTOR: ${{ github.actor }}", block)
                self.assertIn('--actor "${ACTOR}"', block)
                self.assertIn('--workflow-name "${WORKFLOW_NAME}"', block)

                if "--type image-" in block:
                    self.assertIn('--platforms "${IMAGE_PLATFORMS}"', block)

        self.assertEqual(notices, len(EXPECTED_ROUTES))

    def test_reject_wrong_destination_or_unrelated_secret(self) -> None:
        """Swapping a static destination is unsafe even without a broad context."""
        for name in WORKFLOWS:
            for secret in ("DISCORD_HADES_HOOK_URL", "UNRELATED_TOKEN"):
                sources = dict(self.sources)
                sources[name] = sources[name].replace(
                    "secrets.DISCORD_WEBHOOK_URL", "secrets." + secret, 1
                )

                with self.subTest(workflow=name, secret=secret), self.assertRaises(ValueError):
                    notification_bindings(sources)

    def test_reject_dynamic_context_or_cross_server_fallback(self) -> None:
        """Mutation fixtures cover computed lookup, context export, and fallback."""
        for expression in (
            "secrets[matrix.webhook]",
            "toJSON(secrets)",
            "secrets.*",
            "secrets",
            "secrets.DISCORD_WEBHOOK_URL || secrets.DISCORD_HADES_HOOK_URL",
        ):
            sources = dict(self.sources)
            sources["build-and-push.yml"] = sources["build-and-push.yml"].replace(
                "secrets.DISCORD_WEBHOOK_URL", expression, 1
            )

            with self.subTest(expression=expression), self.assertRaises(ValueError):
                notification_bindings(sources)

    def test_reject_profile_or_documentation_mismatch(self) -> None:
        """A correct webhook must still match its event and destination profile."""
        for filename, old, new in (
            ("build-and-push.yml", "--profile image-primary", "--profile image-secondary"),
            ("pages.yml", "--profile docs", "--profile image-secondary"),
        ):
            sources = dict(self.sources)
            sources[filename] = sources[filename].replace(old, new, 1)

            with self.subTest(workflow=filename), self.assertRaises(ValueError):
                notification_bindings(sources)

    def test_reject_extra_or_inherited_secret_access(self) -> None:
        """Reject extra contexts, including case-insensitive Actions lookups."""
        for inherited in (False, True):
            for expression in (
                "secrets.GITHUB_TOKEN",
                "toJSON(SeCrEtS)",
                "SeCrEtS.UNRELATED_TOKEN",
            ):
                sources = dict(self.sources)

                if inherited:
                    sources["pages.yml"] = sources["pages.yml"].replace(
                        "jobs:\n",
                        "env:\n    TOKEN: ${{ " + expression + " }}\n\njobs:\n",
                        1,
                    )
                else:
                    sources["pages.yml"] = sources["pages.yml"].replace(
                        "                  DISCORD_WEBHOOK_URL:",
                        "                  TOKEN: ${{ " + expression + " }}\n"
                        "                  DISCORD_WEBHOOK_URL:",
                        1,
                    )

                with self.subTest(inherited=inherited, expression=expression):
                    with self.assertRaises(ValueError):
                        notification_bindings(sources)

    def test_named_publishing_credentials_remain_independent(self) -> None:
        """The notifier guard must not forbid unrelated named registry tokens."""
        sources = dict(self.sources)
        sources["build-and-push.yml"] = sources["build-and-push.yml"].replace(
            "secrets.GITHUB_TOKEN", "secrets.REGISTRY_TOKEN"
        )
        self.assertEqual(set(notification_bindings(sources)), set(EXPECTED_ROUTES))

    def test_missing_selected_webhook_skips_real_helper(self) -> None:
        """A synthetic opposite hook must not cause transport when input is empty."""
        with tempfile.TemporaryDirectory(prefix="discord-secret-scope-") as directory:
            root = Path(directory)
            marker = root / "transport-called"
            transport = root / "curl"
            transport.write_text('#!/bin/sh\nprintf called > "$NOTIFICATION_CALL_MARKER"\nexit 99\n')
            transport.chmod(0o755)
            environment = {
                "PATH": str(root) + os.pathsep + os.environ["PATH"],
                "DISCORD_WEBHOOK_URL": "",
                "DISCORD_HADES_HOOK_URL": "synthetic-opposite-hook",
                "NOTIFICATION_CALL_MARKER": str(marker),
            }

            for event, profile in EXPECTED_ROUTES:
                result = subprocess.run(
                    [
                        "sh",
                        str(REPOSITORY_ROOT / ".github/scripts/discord-notifier.sh"),
                        "--type",
                        event,
                        "--profile",
                        profile,
                    ],
                    env=environment,
                    capture_output=True,
                    text=True,
                    check=True,
                    timeout=10,
                )

                with self.subTest(event=event, profile=profile):
                    self.assertIn("skipping notification", result.stdout)
                    self.assertEqual(result.stderr, "")
                    self.assertFalse(marker.exists())


if __name__ == "__main__":
    unittest.main()
