#!/usr/bin/env bash
# Start the browser-accessible VNC bridge for the Android emulator.
set -Eeuo pipefail

: "${VNC_PASSWORD:?VNC_PASSWORD is required}"
export DISPLAY="${DISPLAY:-:99}"
PASSFILE="${RUNNER_TEMP:-/tmp}/vnc.pass"

# Classic VNC authentication accepts at most 8 characters. Fail clearly instead
# of silently creating a password that differs from what the user entered.
length=${#VNC_PASSWORD}
if (( length == 0 || length > 8 )); then
  echo "VNC_PASSWORD must contain 1-8 characters for x11vnc (received $length)." >&2
  exit 1
fi

rm -f "$PASSFILE"
x11vnc -storepasswd "$VNC_PASSWORD" "$PASSFILE"
test -s "$PASSFILE" || { echo "x11vnc did not create $PASSFILE" >&2; exit 1; }
chmod 600 "$PASSFILE"
echo "VNC password file created (length: $length; value not printed)."

Xvfb "$DISPLAY" -screen 0 1280x800x24 -ac +extension GLX +render -noreset > xvfb.log 2>&1 &
x11vnc -display "$DISPLAY" -localhost -forever -shared -rfbport 5900 \
  -rfbauth "$PASSFILE" > x11vnc.log 2>&1 &
websockify --web=/usr/share/novnc 6080 127.0.0.1:5900 > novnc.log 2>&1 &

# Give the caller a useful failure instead of publishing a dead tunnel.
for i in {1..30}; do
  if curl -fsS http://127.0.0.1:6080/vnc.html >/dev/null; then
    echo "noVNC is ready on http://127.0.0.1:6080"
    exit 0
  fi
  sleep 1
done
echo "noVNC did not become ready" >&2
cat xvfb.log x11vnc.log novnc.log >&2 || true
exit 1
