#!/usr/bin/env bash
# After a failed sm-smoke.sh run, ask Grafana Assistant why the probes failed
# and write its answer to $GITHUB_STEP_SUMMARY, and to $ASSISTANT_REPORT when
# set (preview.yaml appends that to the PR comment). The prompt carries the
# run's context and the LogQL that finds the probes' own ad-hoc result logs,
# so the Assistant can read them itself. The chat is then shared, so anyone
# in the stack can open it from the link (the service account owns it).
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

note() { # message: italic line in the report, plus a workflow warning
  printf '_%s_\n' "$1" >>"$work/report.md"
  echo "::warning::$1"
}

{
  echo "### Grafana Assistant (generated)"
  echo
} >"$work/report.md"
status=0
GRAFANA_TOKEN="$ASSISTANT_TOKEN" gcx assistant prompt "$prompt" \
  --json --no-stream --timeout "${ASSISTANT_TIMEOUT:-180}" \
  >"$work/reply.json" 2>"$work/reply.err" || status=$?

if [ "$status" -eq 0 ] && [ "$(jq -r '.status' "$work/reply.json" 2>/dev/null)" = completed ]; then
  context_id="$(jq -r '.contextId' "$work/reply.json")"
  {
    jq -r '.response' "$work/reply.json"
    echo
  } >>"$work/report.md"

  # Sharing the same chat again returns the same shared ID.
  shared_id=""
  if GRAFANA_TOKEN="$ASSISTANT_TOKEN" gcx api \
    "/api/plugins/grafana-assistant-app/resources/api/v1/chats/${context_id}/share" -X POST \
    >"$work/share.json" 2>"$work/share.err"; then
    shared_id="$(jq -r '.data.sharedChatId // empty' "$work/share.json" 2>/dev/null || true)"
  fi
  if [ -n "$shared_id" ]; then
    echo "[Open in Grafana Assistant](${GRAFANA_SERVER%/}/a/grafana-assistant-app/chats/shared/${shared_id})" >>"$work/report.md"
  else
    reason="$(head -n 1 "$work/share.err" | cut -c 1-300)"
    note "share link unavailable: ${reason:-no sharedChatId in response}"
  fi
  echo >>"$work/report.md"
  echo "Context ID: \`${context_id}\`" >>"$work/report.md"
else
  reason="$(jq -r '.error // empty' "$work/reply.json" 2>/dev/null || true)"
  if [ -z "$reason" ]; then
    reason="$(head -n 1 "$work/reply.err" | cut -c 1-300)"
  fi
  note "assistant prompt failed: ${reason:-exit ${status}}"
fi

cat "$work/report.md" >>"$summary"
if [ -n "${ASSISTANT_REPORT:-}" ]; then
  cp "$work/report.md" "$ASSISTANT_REPORT"
fi
