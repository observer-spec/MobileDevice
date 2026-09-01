#!/usr/bin/env bash
# Start a reliable browser-accessible VNC bridge for the Android emulator.
set -Eeuo pipefail

# Use a dedicated secret, avoiding the existing broken VNC_PASSWORD value.
# The fallback preserves the user's chosen six-digit access code until the
# dedicated ANDROID_VNC_PASSWORD secret is configured.
VNC_PASSWORD="${ANDROID_VNC_PASSWORD:-676767}"
export DISPLAY="${DISPLAY:-:99}"
PASSFILE="${RUNNER_TEMP:-/tmp}/vnc.pass"

length=${#VNC_PASSWORD}
if (( length < 1 || length > 8 )); then
  echo "Android VNC password must contain 1-8 characters (received length $length)." >&2
  exit 1
fi

rm -f "$PASSFILE"
x11vnc -storepasswd "$VNC_PASSWORD" "$PASSFILE"
test -s "$PASSFILE" || { echo "x11vnc did not create its password file." >&2; exit 1; }
chmod 600 "$PASSFILE"
echo "VNC password file created (length: $length; value not printed)."

Xvfb "$DISPLAY" -screen 0 1280x800x24 -ac +extension GLX +render -noreset > xvfb.log 2>&1 &
# Xvfb and x11vnc were previously started together. If x11vnc won that race,
# it exited, while websockify still answered HTTP and produced WebSocket 1006.
for i in {1..30}; do
  xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 && break
  sleep 1
done
xdpyinfo -display "$DISPLAY" >/dev/null 2>&1 || { echo "Xvfb did not become ready." >&2; cat xvfb.log >&2 || true; exit 1; }

x11vnc -display "$DISPLAY" -localhost -forever -shared -rfbport 5900 \
  -rfbauth "$PASSFILE" > x11vnc.log 2>&1 &
for i in {1..30}; do
  nc -z 127.0.0.1 5900 >/dev/null 2>&1 && break
  sleep 1
done
nc -z 127.0.0.1 5900 >/dev/null 2>&1 || { echo "x11vnc did not listen on port 5900." >&2; cat x11vnc.log >&2 || true; exit 1; }

websockify --web=/usr/share/novnc 6080 127.0.0.1:5900 > novnc.log 2>&1 &
for i in {1..30}; do
  curl -fsS http://127.0.0.1:6080/vnc.html >/dev/null && break
  sleep 1
done
curl -fsS http://127.0.0.1:6080/vnc.html >/dev/null || { echo "noVNC did not become ready." >&2; cat novnc.log >&2 || true; exit 1; }
echo "VNC backend and noVNC are ready."
