#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
/usr/bin/time -p bash -c 'echo "capture: validating env"'
: "${CAPTURE_URL:?Set CAPTURE_URL}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR}"
/usr/bin/time -p bash -c 'echo "CAPTURE_URL=$CAPTURE_URL"'
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p ls -la "$CAPTURE_DIR" || true
# Open exact URL, wait for render, capture desktop+mobile, close own browser.
# Keep capture output outside source (CAPTURE_DIR) and leave the app running.
/usr/bin/time -p node "${RUNTIME_DIR:?}/scripts/default-capture.mjs"
STATUS=$?
/usr/bin/time -p ls -la "$CAPTURE_DIR"
/usr/bin/time -p bash -c 'test -f "$CAPTURE_DIR/final-desktop.png" && test -f "$CAPTURE_DIR/final-mobile.png" && echo "both screenshots present"'
exit $STATUS
