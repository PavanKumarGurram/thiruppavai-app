#!/bin/bash
# Core tests plus an unsigned iOS Simulator build. No device registration or uploads.
set -euo pipefail
cd "$(dirname "$0")/.."
[[ "$(uname -s)" == Darwin ]] || { echo "Run this on a Mac with Xcode." >&2; exit 1; }
xcrun swift test
xcodebuild -project Thiruppavai.xcodeproj -scheme Thiruppavai-iOS \
  -configuration Debug -sdk iphonesimulator -destination "generic/platform=iOS Simulator" \
  -derivedDataPath build/iOS CODE_SIGNING_ALLOWED=NO build
echo "Simulator build completed. Run an installed iPhone/iPad simulator from Xcode."
echo "This checks compilation only; it does not launch the app or test native UI/audio."
