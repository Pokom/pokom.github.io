#!/usr/bin/env bash
# Create or update one PR comment, found by a hidden marker line in its body,
# so each PR keeps a single comment that's edited on every run.
#
# Needs gh (authenticated via GH_TOKEN) and jq on PATH.
# Usage: scripts/pr-comment.sh <owner/repo> <pr_number> <marker> <body_file>
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "usage: $0 <owner/repo> <pr_number> <marker> <body_file>" >&2
  exit 1
fi

repo="$1"
pr="$2"
marker="$3"
body_file="$4"

# Without the marker the next run couldn't find this comment again.
if ! grep -qF -- "$marker" "$body_file"; then
  echo "${body_file} does not contain marker ${marker}" >&2
  exit 1
fi

# --paginate prints one JSON array per page; jq reads them as a stream.
comments="$(gh api --paginate "repos/${repo}/issues/${pr}/comments")"
id="$(jq -r --arg m "$marker" '.[] | select(.body | contains($m)) | .id' <<<"$comments" | head -n1)"

if [ -n "$id" ]; then
  gh api -X PATCH "repos/${repo}/issues/comments/${id}" -F "body=@${body_file}" >/dev/null
  echo "updated comment ${id} on ${repo}#${pr}"
else
  gh api -X POST "repos/${repo}/issues/${pr}/comments" -F "body=@${body_file}" >/dev/null
  echo "created comment on ${repo}#${pr}"
fi
