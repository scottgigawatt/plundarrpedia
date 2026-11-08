#!/bin/sh

#
# Copyright 2026 Scott Gigawatt
#
# SPDX-License-Identifier: Apache-2.0
#
# test-discord-notifier.sh: Exercise notification colors, facts, metadata,
#                           and delivery isolation with synthetic fixtures.
#
# Usage: sh test/helpers/test-discord-notifier.sh
#

#
# Fail immediately and keep all temporary fixtures inside one owned directory.
#
set -eu

REPOSITORY_ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
NOTIFIER="${REPOSITORY_ROOT}/.github/scripts/discord-notifier.sh"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/plundarrpedia-discord.XXXXXX")
trap 'rm -rf "${TEST_ROOT}"' EXIT HUP INT TERM

#
# render: Render a synthetic notification without a webhook or network access.
#
# Parameters: $@ - Notification arguments, including type and profile.
#
# Returns: Prints JSON or exits on invalid inputs.
#
render() {
    DISCORD_WEBHOOK_URL='' sh "${NOTIFIER}" \
        --run-url https://example.invalid/run \
        --repository example/plundarrpedia \
        --ref-name test-ref \
        --image-name Plundarrpedia \
        --ghcr-image ghcr.io/example/plundarrpedia \
        --workflow-name 'A deliberately funny workflow name' \
        --actor example-user \
        --platforms linux/amd64,linux/arm64,linux/arm/v7 \
        --dry-run "$@"
}

#
# assert_payload: Require the expected color and Discord-safe payload bounds.
#
# Parameters: $1 - Expected integer embed color.
#             $2 - Rendered JSON payload.
#
# Returns: 0 for a valid payload; otherwise exits through jq's failure status.
#
assert_payload() {
    printf '%s\n' "$2" | jq --exit-status --argjson color "$1" '
        .allowed_mentions.parse == []
        and (.embeds | length) == 1
        and .embeds[0].color == $color
        and (.username | length) <= 80
        and (.embeds[0] | (.title | length) <= 256
            and (.description | length) <= 4096
            and (.fields | length) <= 25
            and all(.fields[]; (.value | length) > 0 and (.value | length) <= 1024)
            and ((.title | length) + (.description | length) + (.footer.text | length)
                + ([.fields[] | (.name | length) + (.value | length)] | add)) <= 6000)
        and ([.embeds[0].fields[].name] | index("🔗 View run")) != null
    ' >/dev/null
}

#
# Exercise every image conclusion and both joke variants for each destination.
#
for profile in image-primary image-secondary; do
    for selection in 0 1; do
        payload=$(render --type image-start --profile "${profile}" --random-value "${selection}")
        assert_payload 3900150 "${payload}"
        printf '%s\n' "${payload}" | jq --exit-status '
            .embeds[0].description | startswith("The Plundarrpedia image pipeline has started.")
        ' >/dev/null

        for status in success failure timed_out startup_failure cancelled skipped neutral action_required unknown; do
            case "${status}" in
                success) color=5763719 ;;
                failure | timed_out | startup_failure) color=15548997 ;;
                cancelled | skipped | neutral) color=10070709 ;;
                *) color=16705372 ;;
            esac

            payload=$(render --type image-verdict --profile "${profile}" \
                --random-value "${selection}" --job-status "${status}" \
                --publication-status success --published-digest sha256:0123456789abcdef \
                --published-tags ghcr.io/example/plundarrpedia:edge)
            assert_payload "${color}" "${payload}"
        done
    done
done

#
# Distinguish documentation build failures, deployment failures, and cancellation.
# A failed build followed by a skipped deployment remains a red build failure.
#
for selection in 0 1; do
    payload=$(render --type docs-start --profile docs --random-value "${selection}")
    assert_payload 3900150 "${payload}"

    for build_status in success failure cancelled skipped neutral unknown; do
        for deploy_status in success failure cancelled skipped neutral unknown; do
            effective_status=${build_status}

            if [ "${build_status}" = success ]; then
                effective_status=${deploy_status}
            fi

            case "${effective_status}" in
                success) color=5763719 ;;
                failure) color=15548997 ;;
                cancelled | skipped | neutral) color=10070709 ;;
                *) color=16705372 ;;
            esac

            payload=$(render --type docs-verdict --profile docs --random-value "${selection}" \
                --build-status "${build_status}" --deploy-status "${deploy_status}" \
                --site-url https://example.invalid/docs/)
            assert_payload "${color}" "${payload}"
        done
    done
done

payload=$(render --type docs-verdict --profile docs --random-value 0 \
    --build-status failure --deploy-status skipped)
printf '%s\n' "${payload}" | jq --exit-status '
    .embeds[0].description | contains("failed during documentation build")
' >/dev/null
payload=$(render --type docs-verdict --profile docs --random-value 0 \
    --build-status success --deploy-status failure)
printf '%s\n' "${payload}" | jq --exit-status '
    .embeds[0].description | contains("failed during pages deployment")
' >/dev/null

#
# Reject unsupported destination combinations instead of silently selecting copy.
#
if render --type docs-start --profile image-secondary --random-value 0 >/dev/null 2>&1; then
    echo 'Documentation unexpectedly accepted the Hades profile.' >&2
    exit 1
fi

if render --type image-start --profile unknown --random-value 0 >/dev/null 2>&1; then
    echo 'Unknown destination unexpectedly accepted.' >&2
    exit 1
fi

#
# Metadata actions can calculate tags before any registry accepts the image.
# Failed or unconfirmed pushes must never expose those as published tags.
#
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status failure --publication-status failure --published-tags planned-tag \
    --published-digest sha256:0123456789abcdef)
printf '%s\n' "${payload}" | jq --exit-status '
    [.embeds[0].fields[].name] | index("🏷️ Published tags") == null and index("🧾 Digest") == null
' >/dev/null
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-tags planned-tag)
assert_payload 16705372 "${payload}"
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status failure --publication-status success --published-tags actual-tag \
    --published-digest sha256:0123456789abcdef --failure-stage 'provenance verification')
printf '%s\n' "${payload}" | jq --exit-status '
    (.embeds[0].description | contains("GHCR publication completed before the pipeline stopped"))
    and any(.embeds[0].fields[]; .name == "⚠️ Stage needing attention" and .value == "provenance verification")
    and any(.embeds[0].fields[]; .name == "🏷️ Published tags" and .value == "actual-tag")
' >/dev/null

#
# Treat untrusted workflow text as data and disable Discord mention expansion.
# The payload remains valid even when fields contain quotes and shell syntax.
#
metadata="\$(touch ${TEST_ROOT}/injection) \"quoted\" @everyone"
payload=$(render --type image-start --profile image-primary --random-value 0 \
    --workflow-name "${metadata}" --ref-name "${metadata}")
printf '%s\n' "${payload}" | jq --exit-status --arg metadata "${metadata}" '
    any(.embeds[0].fields[]; .name == "⚙️ Workflow" and .value == $metadata)
    and (.embeds[0].description | contains($metadata) | not)
    and .allowed_mentions.parse == []
' >/dev/null
[ ! -e "${TEST_ROOT}/injection" ]
long_value=$(awk 'BEGIN {for (i = 0; i < 10000; i++) printf "x"}')
payload=$(render --type image-verdict --profile image-secondary --random-value 1 \
    --job-status failure --publication-status success --published-digest "${long_value}" \
    --published-tags "${long_value}" --workflow-name "${long_value}" --ref-name "${long_value}" \
    --actor "${long_value}" --platforms "${long_value}" --failure-stage "${long_value}")
assert_payload 15548997 "${payload}"

#
# Stub only transport to prove delivery failures return nonzero without logging
# the URL; independent calls and absent optional webhooks remain usable.
#
mkdir "${TEST_ROOT}/bin"
cat > "${TEST_ROOT}/bin/curl" <<'STUB'
#!/bin/sh
printf '%s\n' called >> "${CURL_TEST_CALLS}"
exit "${CURL_TEST_EXIT:-0}"
STUB
chmod +x "${TEST_ROOT}/bin/curl"
export CURL_TEST_CALLS="${TEST_ROOT}/calls"

if PATH="${TEST_ROOT}/bin:${PATH}" CURL_TEST_EXIT=22 DISCORD_WEBHOOK_URL=https://example.invalid/private-hook \
    sh "${NOTIFIER}" --type image-start --profile image-primary --run-url https://example.invalid/run \
        --repository example/plundarrpedia --ref-name test-ref --ghcr-image ghcr.io/example/plundarrpedia \
        >"${TEST_ROOT}/transport-output" 2>&1; then
    echo 'Failed transport unexpectedly returned success.' >&2
    exit 1
fi

[ ! -s "${TEST_ROOT}/transport-output" ]
PATH="${TEST_ROOT}/bin:${PATH}" CURL_TEST_EXIT=0 DISCORD_WEBHOOK_URL=https://example.invalid/public-hook \
    sh "${NOTIFIER}" --type image-start --profile image-secondary --run-url https://example.invalid/run \
        --repository example/plundarrpedia --ref-name test-ref --ghcr-image ghcr.io/example/plundarrpedia
[ "$(wc -l < "${CURL_TEST_CALLS}" | tr -d ' ')" = 2 ]
PATH="${TEST_ROOT}/bin:${PATH}" DISCORD_WEBHOOK_URL='' sh "${NOTIFIER}" >/dev/null
[ "$(wc -l < "${CURL_TEST_CALLS}" | tr -d ' ')" = 2 ]

#
# Protect workflow-level result isolation and Asteres-only documentation routing.
#
[ "$(awk '/name: "Notify / {notify++} /continue-on-error: true/ {isolated++} END {print (notify == isolated)}' "${REPOSITORY_ROOT}/.github/workflows/build-and-push.yml")" = 1 ]
[ "$(awk '/name: "Notify / {notify++} /continue-on-error: true/ {isolated++} END {print (notify == isolated)}' "${REPOSITORY_ROOT}/.github/workflows/pages.yml")" = 1 ]

if grep -q 'DISCORD_HADES_HOOK_URL\|image-secondary' "${REPOSITORY_ROOT}/.github/workflows/pages.yml"; then
    echo 'Pages workflow unexpectedly contains a Hades route.' >&2
    exit 1
fi

grep -q 'needs: \[build, deploy\]' "${REPOSITORY_ROOT}/.github/workflows/pages.yml"
grep -q 'PUBLICATION_STATUS:.*steps.publish-plundarrpedia.outcome' "${REPOSITORY_ROOT}/.github/workflows/build-and-push.yml"
printf '%s\n' 'Discord notifier checks passed: both image destinations, all states and copy variants, documentation results, payload bounds, evidence, and isolated transport.'
