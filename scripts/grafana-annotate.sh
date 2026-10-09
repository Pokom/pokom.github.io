#!/usr/bin/env bash
# Post a Grafana region annotation for a deploy, from <start_ms> to now. No
# dashboard is set, so it's an organization annotation: it shows on any
# dashboard with a Grafana annotation query on tags "blog" and "deploy".
#
# Needs gcx (authenticated) and jq on PATH.
# Usage: scripts/grafana-annotate.sh <sha> <outcome> <start_ms> <run_url>
#   outcome: the smoke job's status (success, failure, cancelled)
set -euo pipefail

if [ $# -ne 4 ]; then
  echo "usage: $0 <sha> <outcome> <start_ms> <run_url>" >&2
  exit 1
fi

sha="$1"
outcome="$2"
start_ms="$3"
run_url="$4"

if ! [[ "$start_ms" =~ ^[0-9]+$ ]]; then
  echo "start_ms must be epoch milliseconds, got: ${start_ms}" >&2
  exit 1
fi

end_ms="$(date +%s%3N)"

body="$(jq -nc \
  --argjson time "$start_ms" \
  --argjson timeEnd "$end_ms" \
  --arg sha "$sha" \
  --arg outcome "$outcome" \
  --arg url "$run_url" \
  '{
    time: $time,
    timeEnd: $timeEnd,
    tags: ["blog", "deploy", "smoke:\($outcome)"],
    text: "Deploy \($sha[0:7]): smoke \($outcome)\n\($url)"
  }')"

gcx api /api/annotations -d "$body" -o json
