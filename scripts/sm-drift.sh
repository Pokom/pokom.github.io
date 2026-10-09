#!/usr/bin/env bash
# Compare each sm-checks/<name>.yaml against the live Synthetic Monitoring
# check of the same name.
#
# Drift mode (default): diff repo -> live. Exits 1 if any check differs or no
#   longer exists, i.e. something changed outside the repo.
# Plan mode (--plan): diff live -> repo, i.e. what applying these files would
#   change. Differences are expected and exit 0; a missing check still exits 1
#   because the apply would fail. Also writes the plan to $GITHUB_STEP_SUMMARY
#   when set.
#
# Needs gcx (authenticated), yq (mikefarah) and jq on PATH.
# Usage: scripts/sm-drift.sh [--plan] [dir]   (default dir: sm-checks)
set -euo pipefail
shopt -s nullglob

plan=false
if [ "${1:-}" = "--plan" ]; then
  plan=true
  shift
fi
dir="${1:-sm-checks}"
summary="${GITHUB_STEP_SUMMARY:-/dev/null}"
# Server-assigned stack namespace; stripped from the repo files on export.
normalize='del(.metadata.namespace)'

files=("$dir"/*.yaml)
if [ "${#files[@]}" -eq 0 ]; then
  echo "no check files in ${dir}" >&2
  exit 1
fi

if "$plan"; then
  echo "## Synthetic Monitoring plan" >>"$summary"
  echo >>"$summary"
fi

failed=0
changed=0
for f in "${files[@]}"; do
  name="$(basename "$f" .yaml)"

  if ! live="$(gcx synthetic-monitoring checks get "$name" -o json)"; then
    echo "::error file=${f}::${name}: live check not found (deleted outside the repo?)"
    if "$plan"; then
      echo "- **${name}**: live check not found, apply would fail" >>"$summary"
    fi
    failed=1
    continue
  fi

  repo_json="$(yq -o=json "$f" | jq -S "$normalize")"
  live_json="$(jq -S "$normalize" <<<"$live")"

  if "$plan"; then
    if out="$(diff -u --label "live/${name}" --label "repo/${name}" \
      <(echo "$live_json") <(echo "$repo_json"))"; then
      echo "${name}: no change"
    else
      echo "$out"
      changed=1
      {
        echo "### ${name}"
        echo '```diff'
        echo "$out"
        echo '```'
      } >>"$summary"
    fi
  else
    if diff -u --label "repo/${name}" --label "live/${name}" \
      <(echo "$repo_json") <(echo "$live_json"); then
      echo "${name}: in sync"
    else
      echo "::error file=${f}::${name}: live check differs from the repo"
      failed=1
    fi
  fi
done

if "$plan" && [ "$changed" -eq 0 ] && [ "$failed" -eq 0 ]; then
  echo "No changes: live checks already match these files." >>"$summary"
fi

exit "$failed"
