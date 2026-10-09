#!/usr/bin/env bash
# Run an SM HTTP check once (ad hoc, not saved) against the freshly deployed
# site. The target gets a cache-busting query and the body must contain this
# build's <meta name="build-sha">, so every probe proves it sees the new build.
#
# `gcx synthetic-monitoring checks test` exits 0 even when probes fail, so
# this gates on the per-probe results instead. Writes a table to
# $GITHUB_STEP_SUMMARY when set, and also to $SMOKE_REPORT when set.
#
# Needs gcx (authenticated), yq (mikefarah) and jq on PATH.
# Usage: scripts/sm-smoke.sh <check.yaml> <url> <sha>
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 <check.yaml> <url> <sha>" >&2
  exit 1
fi

check_file="$1"
url="$2"
sha="$3"
summary="${GITHUB_STEP_SUMMARY:-/dev/null}"
tmpdir="${SMOKE_TMPDIR:-${RUNNER_TEMP:-/tmp}}"
name="$(basename "$check_file" .yaml)"
smoke_file="${tmpdir}/smoke-${name}.yaml"

TARGET="${url}?cb=${sha}" REGEXP="name=\"?build-sha\"? content=\"?${sha}" \
  yq '.spec.target = strenv(TARGET)
      | .spec.settings.http.failIfBodyNotMatchesRegexp = [strenv(REGEXP)]' \
  "$check_file" >"$smoke_file"

result="$(gcx synthetic-monitoring checks test -f "$smoke_file" -o json)"

table="$(
  echo "| Probe | Status |"
  echo "|---|---|"
  jq -r '.probes[] | "| \(.probeName) | \(.status) |"' <<<"$result"
)"
{
  echo "## Smoke test: ${name} @ ${sha:0:7}"
  echo
  echo "$table"
} >>"$summary"
# Optional copy of the probe table, e.g. for a PR comment.
if [ -n "${SMOKE_REPORT:-}" ]; then
  echo "$table" >>"$SMOKE_REPORT"
fi

total="$(jq '.probes | length' <<<"$result")"
bad="$(jq -r '[.probes[] | select(.status != "success") | "\(.probeName)=\(.status)"] | join(", ")' <<<"$result")"

if [ "$total" -eq 0 ]; then
  echo "::error::${name}: no probe results"
  exit 1
fi
if [ -n "$bad" ]; then
  echo "::error::${name}: ${bad}"
  exit 1
fi
echo "${name}: all ${total} probes passed"
