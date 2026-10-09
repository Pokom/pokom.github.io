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
smoke one-failure.json;  check "smoke: a failed probe fails"  1 $?
has "smoke: names failed probe" "$work/smoke.out" 'Frankfurt'
smoke one-timeout.json;  check "smoke: a timed-out probe fails" 1 $?
smoke no-probes.json;    check "smoke: no results fails"      1 $?
smoke all-success.json 1; check "smoke: gcx error fails"      1 $?
"$here/sm-smoke.sh" >/dev/null 2>&1; check "smoke: missing args fail" 1 $?

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

echo "--- $pass passed, $fail failed"
[ "$fail" -eq 0 ]
