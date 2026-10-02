#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This native app must be built on macOS with Xcode." >&2
  exit 1
fi
if ! xcrun --find xcodebuild >/dev/null 2>&1; then
  echo "Select your installed Xcode in Xcode > Settings > Locations > Command Line Tools." >&2
  exit 1
fi
xcodebuild -project Thiruppavai.xcodeproj -scheme Thiruppavai \
  -configuration Debug -destination "platform=macOS,arch=arm64" \
  -derivedDataPath build/DerivedData \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM="" build
APP="$PWD/build/DerivedData/Build/Products/Debug/Thiruppavai.app"
echo
echo "Local app built at: $APP"
echo "Open it with: open \"$APP\""
echo "For installation, copy this .app into your Applications folder in Finder."
echo "This is an ad-hoc-signed personal build, not a notarized distribution release."
