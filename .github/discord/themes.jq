#
# Copyright 2026 Scott Gigawatt
#
# SPDX-License-Identifier: Apache-2.0
#
# themes.jq: Store project-specific Discord identities and bounded joke variants.
#
# Usage: Loaded by .github/scripts/discord-notifier.sh with image, profile,
#        notification type, outcome, and deterministic selection inputs.
#

{
  "colors": {
    "start": 0,
    "success": 5763719,
    "failure": 15548997,
    "warning": 16705372,
    "cancelled": 10070709,
    "skipped": 10070709,
    "neutral": 10070709
  },
  "images": {
    "Plundarrpedia": {
      "color": 3900150,
      "image-primary": {
        "name": "Reading Is Fundamental",
        "jokes": {
          "start": [
            "Reading is fundamental; packaging is today’s category.",
            "The library is open. Please keep your layers in order."
          ],
          "success": [
            "The library is open, and this edition has receipts.",
            "The reference queens approve this edition."
          ],
          "failure": [
            "The librarian has placed this run on hold.",
            "This edition needs work. The librarian has notes."
          ],
          "cancelled": [
            "The bookmark is in. We can pick this up later.",
            "The reading room is taking a brief intermission."
          ],
          "skipped": [
            "This edition stayed on the shelf.",
            "No new chapter for the registry today."
          ],
          "warning": [
            "The librarian needs a little more evidence.",
            "The reference desk has a follow-up question."
          ],
          "neutral": [
            "The librarian is reserving judgment.",
            "The reading room has no verdict to announce."
          ]
        }
      },
      "image-secondary": {
        "name": "Underworld Archives",
        "jokes": {
          "start": [
            "The Underworld Archives have opened a new edition.",
            "Hades has requested a fresh copy. Eternity leaves plenty of reading time."
          ],
          "success": [
            "Filed under “surprisingly well documented.”",
            "The archives accepted this edition. The late fees remain eternal."
          ],
          "failure": [
            "The archives have requested an incident footnote.",
            "A demon has returned this edition with corrections. In red ink, naturally."
          ],
          "cancelled": [
            "The archives have paused this edition. Even eternity has scheduling conflicts.",
            "The ferryman is holding the bookmark."
          ],
          "skipped": [
            "This edition stayed in the archives.",
            "No new volume crossed the Styx today."
          ],
          "warning": [
            "The archives require one more signature from the living.",
            "The infernal librarian would like to check the paperwork."
          ],
          "neutral": [
            "The archives have filed this under “undecided.”",
            "The infernal reading committee has withheld its verdict."
          ]
        }
      }
    }
  },
  "docs": {
    "subject": "Plundarrpedia",
    "image": "Plundarrpedia",
    "name": "Reading Is Fundamental",
    "jokes": {
      "start": [
        "The reference queens are preparing a new chapter.",
        "Please silence your phones; the documentation is making an entrance."
      ],
      "success": [
        "A fresh chapter, and the references understood the assignment.",
        "The reading room has a new edition. Naturally, we brought receipts."
      ],
      "failure": [
        "The reference desk has placed this update on hold.",
        "The documentation needs an edit before its next entrance."
      ],
      "cancelled": [
        "The reference queens have called an intermission.",
        "The bookmark is in; this chapter can wait."
      ],
      "skipped": [
        "This chapter stayed in the drafts.",
        "The reading room has no new pages to share."
      ],
      "warning": [
        "The reference queens would like to check the receipts.",
        "The reading room needs a little more information."
      ],
      "neutral": [
        "The reading room is reserving its review.",
        "The reference desk has no final verdict."
      ]
    }
  }
} as $catalog
| $catalog.images[$image_name] as $image
| (if $notification_type | startswith("docs-") then
    if $profile == "docs" then $catalog.docs else null end
  elif $profile == "image-primary" or $profile == "image-secondary" then
    $image[$profile] + {subject: $image_name}
  else null end) as $identity
| ($notification_type | startswith("docs-")) as $docs
| (if $docs then "documentation update" else "image pipeline" end) as $noun
| {start: "started", success: (if $docs then "published" else "published" end), failure: "failed", cancelled: "cancelled", skipped: "skipped", neutral: "ended with a neutral result", warning: "needs attention"}[$outcome] as $state
| if $identity == null or $identity.jokes[$outcome] == null or $state == null then
    error("unsupported Discord notification definition")
  else
    {
      username: ($identity.subject + (if $docs then " Docs" else " Image Builds" end) + " • " + $identity.name),
      subject: $identity.subject,
      title: (({start: "🔨", success: "✅", failure: "❌", cancelled: "⏹️", skipped: "⏭️", neutral: "ℹ️", warning: "⚠️"}[$outcome]) + " " + $identity.subject + " " + (if $outcome == "success" and ($docs | not) then "image" else $noun end) + " " + $state),
      footer: ($identity.name + (if $docs then " • documentation updates" else " • image builds" end)),
      color: (if $outcome == "start" then (if $docs then $catalog.images[$catalog.docs.image].color else $image.color end) else $catalog.colors[$outcome] end),
      message: $identity.jokes[$outcome][$selection % ($identity.jokes[$outcome] | length)]
    }
  end
