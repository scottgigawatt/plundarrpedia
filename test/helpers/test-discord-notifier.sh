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
TAGS_HELPER="${REPOSITORY_ROOT}/.github/scripts/notification-tags.sh"
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
        and ([.embeds[0].fields[] | select(.inline) | .name]
            == ["📋 Build context", "🧾 Details"])
        and all(.embeds[0].fields[]; (.value | contains("\n\n") | not))
        and (if .username | startswith("Plundarrpedia Docs") then
            any(.embeds[0].fields[]; .name == "🧾 Details"
                and (.value | startswith("**Project: 📖** Plundarrpedia\n**Target: 🗺️** GitHub Pages")))
          else any(.embeds[0].fields[]; .name == "🧾 Details"
                and (.value | startswith("**Image:** **🐳** Plundarrpedia"))) end)
        and any(.embeds[0].fields[]; .name == "🔗 Quick links"
            and (.value | contains("[View run](https://example.invalid/run)")))
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
    ([.embeds[0].fields[].value] | join("\n")) as $values
    | ($values | contains("planned-tag") | not)
        and ($values | contains("sha256:0123456789abcdef") | not)
        and ([.embeds[0].fields[].name] | index("🧾 Digest") == null)
' >/dev/null
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-tags planned-tag)
assert_payload 16705372 "${payload}"
printf '%s\n' "${payload}" | jq --exit-status '
    [.embeds[0].fields[].value] | join("\n") | contains("planned-tag") | not
' >/dev/null
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status failure --publication-status success --published-tags actual-tag \
    --published-digest sha256:0123456789abcdef --failure-stage 'provenance verification')
printf '%s\n' "${payload}" | jq --exit-status '
    (.embeds[0].description | contains("GHCR publication completed before the pipeline stopped"))
    and any(.embeds[0].fields[]; .name == "⚠️ Stage needing attention" and .value == "provenance verification")
    and any(.embeds[0].fields[]; .value | contains("**Tags: 🏷️** `actual-tag`"))
' >/dev/null

#
# Match the approved grouped layout with linked source context, compact lists,
# one image identity, and full publication evidence. Pedia has only GHCR.
#
full_digest=sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-digest "${full_digest}" \
    --published-tags "$(printf '%s\n' edge sha-0123456789abcdef)" \
    --ghcr-package-url https://example.invalid/package)
printf '%s\n' "${payload}" | jq --exit-status --arg digest "${full_digest}" '
    any(.embeds[0].fields[]; .name == "📋 Build context" and .inline
        and .value == "**Repo: 📁** [plundarrpedia](https://github.com/example/plundarrpedia)\n**Ref: 🌿** `test-ref`\n**User: 👤** [example-user](https://github.com/example-user)")
    and any(.embeds[0].fields[]; .name == "🧾 Details" and .inline
        and .value == "**Image:** **🐳** Plundarrpedia\n**GHCR:** ✅ success")
    and any(.embeds[0].fields[]; .value == "**Tags: 🏷️** `edge` · `sha-0123456789abcdef`\n**Platforms:** **🧱** `amd64` · `arm64` · `arm/v7`\n**Workflow: ⚙️** A deliberately funny workflow name")
    and any(.embeds[0].fields[]; .name == "🧾 Digest" and .value == $digest)
    and any(.embeds[0].fields[]; .name == "🔗 Quick links"
        and .value == "[View run](https://example.invalid/run) · [GHCR image](https://example.invalid/package)")
    and ([.embeds[0].fields[].value] | join("\n") | contains("**Docker Hub:**") | not)
    and ([.embeds[0].fields[].name] | index("📦 Image") == null and index("📦 Registry targets") == null)
' >/dev/null

payload=$(render --type docs-verdict --profile docs --random-value 0 \
    --build-status success --deploy-status success --site-url https://example.invalid/docs/)
printf '%s\n' "${payload}" | jq --exit-status '
    any(.embeds[0].fields[]; .name == "🧾 Details"
        and .value == "**Project: 📖** Plundarrpedia\n**Target: 🗺️** GitHub Pages\n**Build:** ✅ success\n**Pages:** ✅ success")
    and any(.embeds[0].fields[]; .name == "🔗 Quick links"
        and .value == "[View run](https://example.invalid/run) · [Open documentation](https://example.invalid/docs/)")
    and ([.embeds[0].fields[].value] | join("\n") | contains("**Platforms:**") | not)
    and ([.embeds[0].fields[].name] | index("📦 Registry targets") == null and index("🧾 Digest") == null)
' >/dev/null

#
# Invalid identifiers and unsafe Markdown link targets stay unlinked. Ref code
# spans cannot be closed by an embedded backtick; bot names stay plain text.
#
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-digest "${full_digest}" \
    --repository 'owner/repo)[forged](https://bad.invalid)' \
    --actor 'user](https://bad.invalid)' --ref-name 'ref` [forged](https://bad.invalid)' \
    --ghcr-package-url 'https://example.invalid/image)[forged](https://bad.invalid)')
printf '%s\n' "${payload}" | jq --exit-status '
    any(.embeds[0].fields[]; .name == "📋 Build context"
        and (.value | contains("https://github.com/") | not)
        and (.value | contains("**Ref: 🌿** `ref\u0027 [forged](https://bad.invalid)`")))
    and any(.embeds[0].fields[]; .name == "🔗 Quick links"
        and .value == "[View run](https://example.invalid/run)")
' >/dev/null
payload=$(render --type image-start --profile image-primary --random-value 0 --actor 'example-bot[bot]')
printf '%s\n' "${payload}" | jq --exit-status '
    any(.embeds[0].fields[]; .name == "📋 Build context"
        and (.value | contains("example-bot"))
        and (.value | contains("https://github.com/example-bot") | not))
' >/dev/null

#
# Treat untrusted workflow text as data and disable Discord mention expansion.
# The payload remains valid even when fields contain quotes and shell syntax.
#
metadata="\$(touch ${TEST_ROOT}/injection) \"quoted\" @everyone"
payload=$(render --type image-start --profile image-primary --random-value 0 \
    --workflow-name "${metadata}" --ref-name "${metadata}")
printf '%s\n' "${payload}" | jq --exit-status --arg metadata "${metadata}" '
    any(.embeds[0].fields[]; (.value | contains("**Workflow: ⚙️**"))
        and (.value | contains("touch")) and (.value | contains("quoted")))
    and (.embeds[0].description | contains($metadata) | not)
    and .allowed_mentions.parse == []
' >/dev/null
[ ! -e "${TEST_ROOT}/injection" ]
long_value=$(awk 'BEGIN {for (i = 0; i < 10000; i++) printf "x"}')
payload=$(render --type image-verdict --profile image-secondary --random-value 1 \
    --job-status failure --publication-status success --published-digest "${long_value}" \
    --published-tags bounded-tag --workflow-name "${long_value}" --ref-name "${long_value}" \
    --actor "${long_value}" --platforms "${long_value}" --failure-stage "${long_value}")
assert_payload 15548997 "${payload}"

#
# Bound combined metadata with Markdown punctuation without cutting links or code spans.
# Oversized lists visibly mark omissions, and only a leading linux/ is removed.
#
long_markdown=$(awk 'BEGIN {for (i = 0; i < 1000; i++) printf "[*](_x_)`"}')
payload=$(render --type image-verdict --profile image-secondary --random-value 1 \
    --job-status failure --publication-status success --published-digest "${full_digest}" \
    --published-tags bounded-tag --workflow-name "${long_markdown}" --ref-name "${long_markdown}" \
    --actor "${long_markdown}" --repository "${long_markdown}" --platforms "${long_markdown}" \
    --failure-stage "${long_markdown}" --ghcr-package-url "https://example.invalid/${long_value}")
assert_payload 15548997 "${payload}"

many_tags=$(awk 'BEGIN {for (i = 0; i < 100; i++) printf "tag-%03d\n", i}')
payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-digest "${full_digest}" \
    --published-tags "${many_tags}")
assert_payload 5763719 "${payload}"
printf '%s\n' "${payload}" | jq --exit-status '
    any(.embeds[0].fields[]; (.value | startswith("**Tags: 🏷️**"))
        and (.value | split("\n")[0] | endswith(" · ..."))
        and ((.value | split("\n")[0] | [match("`"; "g")] | length) % 2 == 0)
        and (.value | split("🏷️") | length) == 2)
' >/dev/null

payload=$(render --type image-start --profile image-primary --random-value 0 \
    --platforms linux/amd64,windows/amd64,custom/linux/arm64)
printf '%s\n' "${payload}" | jq --exit-status '
    any(.embeds[0].fields[];
        .value | contains("**Platforms:** **🧱** `amd64` · `windows/amd64` · `custom/linux/arm64`"))
' >/dev/null

payload=$(render --type image-start --profile image-primary --random-value 0 \
    --run-url 'https://example.invalid/run)[forged](https://bad.invalid)')
printf '%s\n' "${payload}" | jq --exit-status '
    (.embeds[0] | has("url") | not)
    and ([.embeds[0].fields[].name] | index("🔗 Quick links") == null)
' >/dev/null

#
# Normalize only exact-image references or already valid short tags. Optional
# empty metadata remains empty, and rejected values never enter diagnostics.
#
expected_tags=$(printf '%s\n' edge sha-0123456789abcdef 2.1.8 latest)
actual_tags=$(sh "${TAGS_HELPER}" --image ghcr.io/example/plundarrpedia --tags "$(printf '%s\n' \
    ghcr.io/example/plundarrpedia:edge '' ghcr.io/example/plundarrpedia:sha-0123456789abcdef 2.1.8 latest)")
[ "${actual_tags}" = "${expected_tags}" ]
[ -z "$(sh "${TAGS_HELPER}" --image ghcr.io/example/plundarrpedia --tags '')" ]

max_tag=$(awk 'BEGIN {for (i = 0; i < 128; i++) printf "x"}')
[ "$(sh "${TAGS_HELPER}" --image ghcr.io/example/plundarrpedia --tags "${max_tag}")" = "${max_tag}" ]

for invalid in "${max_tag}x" ghcr.io/example/plundarrpedia-other:edge ghcr.io/other/image:edge 'bad tag' '-invalid' 'tag:extra' 'tag/token' "${long_value}"; do
    if sh "${TAGS_HELPER}" --image ghcr.io/example/plundarrpedia --tags "${invalid}" \
        >"${TEST_ROOT}/invalid-tags-output" 2>"${TEST_ROOT}/invalid-tags-error"; then
        echo 'Invalid notification tag unexpectedly accepted.' >&2
        exit 1
    fi

    [ ! -s "${TEST_ROOT}/invalid-tags-output" ]

    if grep -F -- "${invalid}" "${TEST_ROOT}/invalid-tags-error" >/dev/null; then
        echo 'Rejected tag value appeared in diagnostics.' >&2
        exit 1
    fi
done

payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-digest sha256:0123456789abcdef \
    --published-tags "$(printf '%s\n' ghcr.io/example/plundarrpedia:edge ghcr.io/example/plundarrpedia:sha-0123456789abcdef)")
printf '%s\n' "${payload}" | jq --exit-status '
    any(.embeds[0].fields[];
        .value | contains("**Tags: 🏷️** `edge` · `sha-0123456789abcdef`"))
' >/dev/null

payload=$(render --type image-verdict --profile image-primary --random-value 0 \
    --job-status success --publication-status success --published-digest sha256:0123456789abcdef)
printf '%s\n' "${payload}" | jq --exit-status '
    ([.embeds[0].fields[].value] | join("\n") | contains("**Tags: 🏷️**") | not)
    and any(.embeds[0].fields[]; .name == "🧾 Digest")
' >/dev/null

#
# Stub transport to cover HTTP and connection failures. The deliberately noisy
# stderr includes synthetic secrets that must never reach notification logs.
#
mkdir "${TEST_ROOT}/bin"
cat > "${TEST_ROOT}/bin/curl" <<'STUB'
#!/bin/sh
set -eu
printf '%s\n' called >> "${CURL_TEST_CALLS}"
connect_timeout=false
request_timeout=false
numeric_output=false
body_discarded=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --connect-timeout)
            [ "$2" = 10 ] || exit 91
            connect_timeout=true
            shift 2
            ;;
        --max-time)
            [ "$2" = 30 ] || exit 91
            request_timeout=true
            shift 2
            ;;
        --write-out)
            [ "$2" = '%{http_code}' ] || exit 91
            numeric_output=true
            shift 2
            ;;
        --output)
            [ "$2" = /dev/null ] || exit 91
            body_discarded=true
            shift 2
            ;;
        --retry* | --show-error | --verbose | --include)
            exit 91
            ;;
        *) shift ;;
    esac
done

[ "${connect_timeout}" = true ]
[ "${request_timeout}" = true ]
[ "${numeric_output}" = true ]
[ "${body_discarded}" = true ]
printf '%s\n' "RAW_RESPONSE_BODY RAW_HEADER PRIVATE_TOKEN PAYLOAD_PRIVATE_TOKEN ${DISCORD_WEBHOOK_URL}" >&2
printf '%s' "${CURL_TEST_HTTP_CODE:-204}"
exit "${CURL_TEST_EXIT:-0}"
STUB
chmod +x "${TEST_ROOT}/bin/curl"
export CURL_TEST_CALLS="${TEST_ROOT}/calls"
call_count=0

for scenario in success redirect client_error rate_limit server_error dns_error timeout malformed_status; do
    case "${scenario}" in
        success) http_status=204; curl_exit=0; expected_status=204 ;;
        redirect) http_status=302; curl_exit=0; expected_status=302 ;;
        client_error) http_status=400; curl_exit=22; expected_status=400 ;;
        rate_limit) http_status=429; curl_exit=22; expected_status=429 ;;
        server_error) http_status=503; curl_exit=22; expected_status=503 ;;
        dns_error) http_status=000; curl_exit=6; expected_status=000 ;;
        timeout) http_status=000; curl_exit=28; expected_status=000 ;;
        malformed_status) http_status=RAW_SECRET_STATUS; curl_exit=22; expected_status=000 ;;
    esac

    if PATH="${TEST_ROOT}/bin:${PATH}" CURL_TEST_HTTP_CODE="${http_status}" CURL_TEST_EXIT="${curl_exit}" \
        DISCORD_WEBHOOK_URL=https://example.invalid/private-hook \
        sh "${NOTIFIER}" --type image-start --profile image-primary --run-url https://example.invalid/run \
            --repository example/plundarrpedia --ref-name test-ref --ghcr-image ghcr.io/example/plundarrpedia \
            --workflow-name PAYLOAD_PRIVATE_TOKEN >"${TEST_ROOT}/transport-output" 2>&1; then
        actual_exit=0
    else
        actual_exit=$?
    fi

    [ "${actual_exit}" = "${curl_exit}" ]
    [ "$(cat "${TEST_ROOT}/transport-output")" = "Discord notification request finished: HTTP ${expected_status}; curl exit ${curl_exit}." ]
    call_count=$((call_count + 1))
done

#
# A failed primary request does not prevent a separate secondary request, and
# an absent optional webhook skips without calling transport at all.
#
PATH="${TEST_ROOT}/bin:${PATH}" CURL_TEST_EXIT=0 DISCORD_WEBHOOK_URL=https://example.invalid/public-hook \
    sh "${NOTIFIER}" --type image-start --profile image-secondary --run-url https://example.invalid/run \
        --repository example/plundarrpedia --ref-name test-ref --ghcr-image ghcr.io/example/plundarrpedia \
        >"${TEST_ROOT}/secondary-output" 2>&1
[ "$(cat "${TEST_ROOT}/secondary-output")" = 'Discord notification request finished: HTTP 204; curl exit 0.' ]
call_count=$((call_count + 1))
[ "$(wc -l < "${CURL_TEST_CALLS}" | tr -d ' ')" = "${call_count}" ]
PATH="${TEST_ROOT}/bin:${PATH}" DISCORD_WEBHOOK_URL='' sh "${NOTIFIER}" >/dev/null
[ "$(wc -l < "${CURL_TEST_CALLS}" | tr -d ' ')" = "${call_count}" ]

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
