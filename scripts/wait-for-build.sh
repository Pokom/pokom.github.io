#!/usr/bin/env bash
# Poll a page until its <meta name="build-sha"> matches the given commit, i.e.
# the new build is actually being served. A cache-busting query string skips
# the CDN copy (GitHub Pages caches for 10 minutes).
#
# Usage: scripts/wait-for-build.sh <url> <sha> [timeout_seconds] [interval_seconds]
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <url> <sha> [timeout_seconds] [interval_seconds]" >&2
  exit 1
fi

url="$1"
sha="$2"
timeout="${3:-600}"
interval="${4:-15}"
# Minified HTML may drop the attribute quotes.
pattern="name=\"?build-sha\"? content=\"?${sha}\"?"

deadline=$((SECONDS + timeout))
while :; do
  if curl -fsS --max-time 10 "${url}?cb=${sha}" 2>/dev/null | grep -Eq "$pattern"; then
    echo "build ${sha} is live at ${url}"
    exit 0
  fi
  if [ "$SECONDS" -ge "$deadline" ]; then
    echo "::error::build ${sha} not live at ${url} after ${timeout}s"
    exit 1
  fi
  echo "waiting for build ${sha}..."
  sleep "$interval"
done
