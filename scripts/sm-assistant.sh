#!/usr/bin/env bash
# After a failed sm-smoke.sh run, ask Grafana Assistant why the probes failed
# and write its answer to $GITHUB_STEP_SUMMARY. The prompt carries the run's
# context and the LogQL that finds the probes' own ad-hoc result logs, so the
# Assistant can read them itself.
#
# Runs as $ASSISTANT_TOKEN (a Viewer service account) instead of
# $GRAFANA_TOKEN. Diagnostic only: a missing token or a failed prompt is
# noted and the script still exits 0. Only bad arguments exit 1.
#
# Needs gcx (with GRAFANA_SERVER) and jq on PATH.
# Usage: scripts/sm-assistant.sh <smoke-result.json>
set -euo pipefail

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "usage: $0 <smoke-result.json>" >&2
  exit 1
fi

result_file="$1"
summary="${GITHUB_STEP_SUMMARY:-/dev/null}"

job="$(jq -r '.job' "$result_file")"
target="$(jq -r '.target' "$result_file")"
adhoc_id="$(jq -r '.adhoc_id' "$result_file")"
failed="$(jq -r '.probes[] | select(.status != "success") | "- \(.probeName): \(.status)"' "$result_file")"

if [ -z "$failed" ]; then
  echo "${job}: all probes passed, nothing to ask"
  exit 0
fi
if [ -z "${ASSISTANT_TOKEN:-}" ]; then
  echo "::notice::ASSISTANT_TOKEN not set; skipping Grafana Assistant"
  exit 0
fi

prompt="A Synthetic Monitoring HTTP check was run once (ad hoc) from each probe \
against a freshly deployed site in CI, and some probes failed.

- Job: ${job}
- Target: ${target}
- Commit: ${GITHUB_SHA:-unknown}
- CI run: ${RUN_URL:-unknown}

Failing probes:
${failed}

Each probe's own result, including its request log, is in the Synthetic \
Monitoring Loki logs datasource: {type=\"adhoc\"} |~ \"${adhoc_id}\" | json \
(one line per probe, field \"probe\" is the probe name, \"logs\" its log \
entries). Read those lines, then say in at most five sentences what most \
likely failed and what to check next. Read only; do not create or change \
anything."

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

{
  echo "### Grafana Assistant (generated)"
  echo
} >>"$summary"
status=0
GRAFANA_TOKEN="$ASSISTANT_TOKEN" gcx assistant prompt "$prompt" \
  --json --no-stream --timeout "${ASSISTANT_TIMEOUT:-180}" \
  >"$work/reply.json" 2>"$work/reply.err" || status=$?

if [ "$status" -eq 0 ] && [ "$(jq -r '.status' "$work/reply.json" 2>/dev/null)" = completed ]; then
  {
    jq -r '.response' "$work/reply.json"
    echo
    echo "Context ID: \`$(jq -r '.contextId' "$work/reply.json")\`"
  } >>"$summary"
  exit 0
fi

reason="$(jq -r '.error // empty' "$work/reply.json" 2>/dev/null || true)"
if [ -z "$reason" ]; then
  reason="$(head -n 1 "$work/reply.err" | cut -c 1-300)"
fi
echo "_assistant prompt failed: ${reason:-exit ${status}}_" >>"$summary"
echo "::warning::assistant prompt failed: ${reason:-exit ${status}}"
