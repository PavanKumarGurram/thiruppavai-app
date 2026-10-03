#!/bin/bash
# Build only. Does not install apps or upload anything.
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "$(uname -s)" == Darwin ]] || { echo "Run this on a Mac with Xcode." >&2; exit 1; }
xcrun swift test
xcodebuild -project Thiruppavai.xcodeproj -scheme Thiruppavai-Mac \
  -configuration Debug -destination "platform=macOS,arch=arm64" \
  -derivedDataPath build/Mac \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM="" build
echo "Mac app: $PWD/build/Mac/Build/Products/Debug/Thiruppavai.app"
