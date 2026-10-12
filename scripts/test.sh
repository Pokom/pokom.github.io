#!/usr/bin/env bash
# Offline tests for the deploy smoke-test scripts. No Grafana access needed:
# gcx is replaced by testdata/fake-gcx, and pages are served locally.
# Usage: scripts/test.sh
set -uo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
td="$here/testdata"
work="$(mktemp -d)"

pass=0 fail=0
check() { # name want_exit got_exit
  if [ "$2" = "$3" ]; then pass=$((pass + 1)); echo "ok   $1"
  else fail=$((fail + 1)); echo "FAIL $1 (want exit $2, got $3)"; fi
}
has() { # name file regex
  if grep -Eq -- "$3" "$2"; then pass=$((pass + 1)); echo "ok   $1"
  else fail=$((fail + 1)); echo "FAIL $1 (no match for: $3)"; fi
}

# --- wait-for-build.sh ---------------------------------------------------
port=18765
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$td/build" >/dev/null 2>&1 &
server=$!
trap 'kill "$server" 2>/dev/null' EXIT
for _ in $(seq 50); do curl -fs "http://127.0.0.1:$port/" >/dev/null 2>&1 && break; sleep 0.1; done

wait_build() { "$here/wait-for-build.sh" "$@" >"$work/wait.out" 2>&1; }
wait_build "http://127.0.0.1:$port/match/" abc123 5 1;  check "wait: unquoted meta matches" 0 $?
wait_build "http://127.0.0.1:$port/quoted/" abc123 5 1; check "wait: quoted meta matches"   0 $?
wait_build "http://127.0.0.1:$port/stale/" abc123 2 1;  check "wait: stale build times out" 1 $?
has "wait: timeout names expected sha" "$work/wait.out" 'abc123'
wait_build "http://127.0.0.1:1/" abc123 2 1;            check "wait: unreachable times out" 1 $?
wait_build;                                            check "wait: missing args fail"     1 $?

# --- sm-smoke.sh -----------------------------------------------------------
check_file="$here/../sm-checks/blog-103862.yaml"
url="https://markpoko.dev/"
sha="abc123"

smoke() { # fixture [gcx_exit]
  : >"$work/summary.md"
  : >"$work/sent.yaml"
  PATH="$td/fake-gcx:$PATH" \
    FAKE_GCX_OUTPUT="$td/smoke/$1" FAKE_GCX_EXIT="${2:-0}" FAKE_GCX_CAPTURE="$work/sent.yaml" \
    GITHUB_STEP_SUMMARY="$work/summary.md" SMOKE_TMPDIR="$work" \
    "$here/sm-smoke.sh" "$check_file" "$url" "$sha" >"$work/smoke.out" 2>&1
}

smoke all-success.json;  check "smoke: all probes succeed"   0 $?
has "smoke: summary row per probe" "$work/summary.md" '^\| Seoul \| success \|'
has "smoke: sends cache-busted target" "$work/sent.yaml" 'target: https://markpoko.dev/\?cb=abc123$'
has "smoke: sends body regexp for sha" "$work/sent.yaml" 'failIfBodyNotMatchesRegexp'
has "smoke: regexp contains sha"       "$work/sent.yaml" 'build-sha.*abc123'
has "smoke: keeps other http settings" "$work/sent.yaml" 'method: GET'
has "smoke: keeps job"                 "$work/sent.yaml" 'job: blog'
: >"$work/report.md"
SMOKE_REPORT="$work/report.md" smoke all-success.json; check "smoke: with report file" 0 $?
has "smoke: report file has probe rows" "$work/report.md" '^\| Frankfurt \| success \|'
smoke one-failure.json;  check "smoke: a failed probe fails"  1 $?
has "smoke: names failed probe" "$work/smoke.out" 'Frankfurt'
smoke one-timeout.json;  check "smoke: a timed-out probe fails" 1 $?
smoke no-probes.json;    check "smoke: no results fails"      1 $?
smoke all-success.json 1; check "smoke: gcx error fails"      1 $?
"$here/sm-smoke.sh" >/dev/null 2>&1; check "smoke: missing args fail" 1 $?
rm -f "$work/result.json"
SMOKE_RESULT="$work/result.json" smoke all-success.json; check "smoke: with result file" 0 $?
has "smoke: result file is the raw json" "$work/result.json" '"adhoc_id"'
rm -f "$work/result.json"
SMOKE_RESULT="$work/result.json" smoke one-failure.json; check "smoke: failure with result file" 1 $?
has "smoke: result file written on failure" "$work/result.json" '"Frankfurt"'

# --- grafana-annotate.sh ---------------------------------------------------
annotate() { # gcx_exit args...
  local gcx_exit="$1"; shift
  : >"$work/body.json"
  : >"$work/args.txt"
  PATH="$td/fake-gcx:$PATH" \
    FAKE_GCX_OUTPUT="$td/annotate/created.json" FAKE_GCX_EXIT="$gcx_exit" \
    FAKE_GCX_CAPTURE_DATA="$work/body.json" FAKE_GCX_CAPTURE_ARGS="$work/args.txt" \
    "$here/grafana-annotate.sh" "$@" >"$work/annotate.out" 2>&1
}
jqok() { # name jq-filter (must evaluate to true against the posted body)
  if jq -e "$2" "$work/body.json" >/dev/null 2>&1; then pass=$((pass + 1)); echo "ok   $1"
  else fail=$((fail + 1)); echo "FAIL $1 (jq false: $2)"; fi
}

run_url="https://github.com/Pokom/pokom.github.io/actions/runs/1"
start_ms=1791567200000
annotate 0 abc1234def success "$start_ms" "$run_url"; check "annotate: posts on success" 0 $?
has "annotate: uses annotations endpoint" "$work/args.txt" '^/api/annotations$'
jqok "annotate: org annotation (no dashboard)" '(has("dashboardUID") or has("dashboardId")) | not'
jqok "annotate: region starts at start_ms"     ".time == $start_ms"
jqok "annotate: region ends after start"       '.timeEnd > .time'
jqok "annotate: tags blog, deploy, outcome"    '.tags == ["blog", "deploy", "smoke:success"]'
jqok "annotate: text has short sha"            '.text | contains("abc1234")'
jqok "annotate: text has run url"              ".text | contains(\"$run_url\")"
annotate 0 abc1234def failure "$start_ms" "$run_url"; check "annotate: posts on failure" 0 $?
jqok "annotate: failure tag"                   '.tags[2] == "smoke:failure"'
annotate 1 abc1234def success "$start_ms" "$run_url"; check "annotate: gcx error fails" 1 $?
annotate 0 abc1234def success notanumber "$run_url"; check "annotate: bad start_ms fails" 1 $?
annotate 0 abc1234def success;                         check "annotate: missing args fail" 1 $?

# --- pr-comment.sh ----------------------------------------------------------
marker='<!-- preview-smoke -->'
comment() { # comments_fixture body_fixture [gh_exit]
  : >"$work/gh.log"
  : >"$work/sent-body.md"
  PATH="$td/fake-gh:$PATH" \
    FAKE_GH_COMMENTS="$td/comments/$1" FAKE_GH_EXIT="${3:-0}" \
    FAKE_GH_LOG="$work/gh.log" FAKE_GH_BODY_CAPTURE="$work/sent-body.md" \
    "$here/pr-comment.sh" Pokom/pokom.github.io 7 "$marker" "$td/comments/$2" >"$work/comment.out" 2>&1
}
lacks() { # name file regex
  if grep -Eq -- "$3" "$2"; then fail=$((fail + 1)); echo "FAIL $1 (unexpected match: $3)"
  else pass=$((pass + 1)); echo "ok   $1"; fi
}

comment none.json body.md;       check "comment: creates when none exist" 0 $?
has   "comment: POSTs to the PR"        "$work/gh.log" '-X POST repos/Pokom/pokom.github.io/issues/7/comments'
lacks "comment: no PATCH when creating" "$work/gh.log" 'PATCH'
has   "comment: sends the body file"    "$work/sent-body.md" 'pr-7\.markpoko-blog'
comment others.json body.md;     check "comment: ignores unmarked comments" 0 $?
has   "comment: still POSTs"            "$work/gh.log" '-X POST'
comment has-marker.json body.md; check "comment: updates marked comment" 0 $?
has   "comment: PATCHes comment 99"     "$work/gh.log" '-X PATCH repos/Pokom/pokom.github.io/issues/comments/99'
lacks "comment: no POST when updating"  "$work/gh.log" 'POST'
has   "comment: lists with --paginate"  "$work/gh.log" '--paginate repos/Pokom/pokom.github.io/issues/7/comments'
comment paginated.json body.md;  check "comment: finds marker on page 2" 0 $?
has   "comment: PATCHes comment 77"     "$work/gh.log" 'issues/comments/77'
comment none.json body-no-marker.md; check "comment: body without marker fails" 1 $?
comment none.json body.md 1;     check "comment: gh failure fails"        1 $?
"$here/pr-comment.sh" >/dev/null 2>&1; check "comment: missing args fail" 1 $?

# --- sm-assistant.sh --------------------------------------------------------
assistant() { # result_fixture response_fixture [gcx_exit]; env: ASSISTANT_TOKEN
  : >"$work/summary.md"
  : >"$work/gcx.log"
  PATH="$td/fake-gcx:$PATH" \
    FAKE_GCX_OUTPUT="$td/assistant/$2" FAKE_GCX_EXIT="${3:-0}" FAKE_GCX_LOG="$work/gcx.log" \
    GRAFANA_TOKEN=sm-tok ASSISTANT_TOKEN="${ASSISTANT_TOKEN-asst-tok}" \
    GITHUB_SHA=abc1234def RUN_URL="https://github.com/Pokom/pokom.github.io/actions/runs/1" \
    GITHUB_STEP_SUMMARY="$work/summary.md" \
    "$here/sm-assistant.sh" "$td/smoke/$1" >"$work/assistant.out" 2>&1
}

assistant one-failure.json completed.json; check "assistant: completed" 0 $?
has   "assistant: uses its own token"       "$work/gcx.log" $'^asst-tok\tassistant\tprompt\t'
has   "assistant: single-document json"     "$work/gcx.log" $'\t--json\t--no-stream\t'
has   "assistant: prompt has failing probe" "$work/gcx.log" 'Frankfurt: failure'
lacks "assistant: prompt omits passing"     "$work/gcx.log" 'Seoul: success'
has   "assistant: prompt has adhoc id"      "$work/gcx.log" '\{type="adhoc"\} \|~ "2" \| json'
has   "assistant: prompt has target"        "$work/gcx.log" 'markpoko\.dev/\?cb=abc'
has   "assistant: prompt has sha"           "$work/gcx.log" 'abc1234def'
has   "assistant: prompt has run url"       "$work/gcx.log" 'actions/runs/1'
has   "assistant: prompt says read only"    "$work/gcx.log" 'Read only'
has   "assistant: summary heading"          "$work/summary.md" '^### Grafana Assistant \(generated\)$'
has   "assistant: summary has reply"        "$work/summary.md" 'Frankfurt received HTTP 503'
has   "assistant: summary has context id"   "$work/summary.md" 'ctx-42'

assistant one-failure.json failed.json 1; check "assistant: failed run exits 0" 0 $?
has   "assistant: notes the error"          "$work/summary.md" 'assistant prompt failed: agent run failed'
has   "assistant: warns"                    "$work/assistant.out" '::warning::'
assistant one-failure.json failed.json 0; check "assistant: non-completed status exits 0" 0 $?
has   "assistant: notes non-completed"      "$work/summary.md" 'assistant prompt failed'
lacks "assistant: no reply on failure"      "$work/summary.md" 'Context ID'

ASSISTANT_TOKEN='' assistant one-failure.json completed.json; check "assistant: no token exits 0" 0 $?
has   "assistant: notices missing token"    "$work/assistant.out" '::notice::.*ASSISTANT_TOKEN'
lacks "assistant: no call without token"    "$work/gcx.log" '.'
assistant all-success.json completed.json; check "assistant: all passed exits 0" 0 $?
lacks "assistant: no call when all passed"  "$work/gcx.log" '.'
"$here/sm-assistant.sh" >/dev/null 2>&1; check "assistant: missing args fail" 1 $?
"$here/sm-assistant.sh" "$work/nope.json" >/dev/null 2>&1; check "assistant: missing file fails" 1 $?

echo "--- $pass passed, $fail failed"
[ "$fail" -eq 0 ]
