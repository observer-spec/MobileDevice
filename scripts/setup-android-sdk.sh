#!/usr/bin/env bash
# Install only the Android components required by this workflow.
set -Eeuo pipefail
sdkmanager --install \
  'platform-tools' \
  'emulator' \
  'platforms;android-30' \
  'system-images;android-30;google_apis;x86_64'
yes | sdkmanager --licenses >/dev/null || true
