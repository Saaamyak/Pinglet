#!/bin/bash
# Pinglet — weekly refresh for the free Apple ID.
# The free signing certificate expires every 7 days; run this (phone plugged in,
# unlocked) to rebuild and reinstall. Your tasks are kept.
#
#   ./scripts/refresh.sh
#
set -e
cd "$(dirname "$0")/.."

DEVICE="00008150-001809062228C01C"   # Samyak's iPhone

echo "→ Regenerating project…"
xcodegen generate >/dev/null

echo "→ Building for your iPhone…"
xcodebuild -project Pinglet.xcodeproj -scheme Pinglet -configuration Debug \
  -destination "id=$DEVICE" -allowProvisioningUpdates build >/dev/null

APP=$(xcodebuild -project Pinglet.xcodeproj -scheme Pinglet -configuration Debug \
  -destination "id=$DEVICE" -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ CODESIGNING_FOLDER_PATH = /{print $2; exit}')

echo "→ Installing…"
xcrun devicectl device install app --device "$DEVICE" "$APP" >/dev/null

echo "✅ Pinglet refreshed on your iPhone. Good for another 7 days."
