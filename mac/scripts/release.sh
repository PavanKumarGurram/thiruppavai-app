#!/bin/bash
# Explicit, opt-in Developer ID release workflow. Never runs as a build phase.
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "A Mac with Xcode is required." >&2; exit 1
fi
if [[ "${RELEASE_READY:-}" != "YES" ]]; then
  echo "First complete Docs/RELEASING.md, including testing and recording-rights review." >&2
  echo "Set RELEASE_READY=YES only when ready to make a distribution build." >&2
  exit 1
fi
: "${SIGNING_IDENTITY:?Set the name of your installed Developer ID Application certificate}"
: "${TEAM_ID:?Set your Apple Developer team ID}"
: "${BUNDLE_ID:?Set a stable bundle identifier you control}"
: "${NOTARY_PROFILE:?Set the name of your existing notarytool Keychain profile}"
case "$SIGNING_IDENTITY" in
  "Developer ID Application:"*) ;;
  *) echo "Use a Developer ID Application identity, not an ad hoc or development identity." >&2; exit 1 ;;
esac
if [[ "$BUNDLE_ID" == "com.example.Thiruppavai" ]]; then
  echo "Replace the example bundle identifier before distribution." >&2; exit 1
fi
OUT="$PWD/build/release-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
STAGING="$(mktemp -d "${TMPDIR:-/tmp}/Thiruppavai.XXXXXX")"
trap 'rm -rf "$STAGING"' EXIT
xcodebuild -project Thiruppavai.xcodeproj -scheme Thiruppavai \
  -configuration Release -destination "generic/platform=macOS" \
  -archivePath "$OUT/Thiruppavai.xcarchive" \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$SIGNING_IDENTITY" \
  DEVELOPMENT_TEAM="$TEAM_ID" PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" ONLY_ACTIVE_ARCH=NO archive
APP="$OUT/Thiruppavai.xcarchive/Products/Applications/Thiruppavai.app"
codesign --verify --deep --strict --verbose=2 "$APP"
ditto "$APP" "$STAGING/Thiruppavai.app"
ln -s /Applications "$STAGING/Applications"
DMG="$OUT/Thiruppavai.dmg"
hdiutil create -volname Thiruppavai -srcfolder "$STAGING" -format UDZO "$DMG"
codesign --sign "$SIGNING_IDENTITY" --timestamp --identifier "$BUNDLE_ID.diskimage" "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait \
  --output-format json > "$OUT/notarization.json"
STATUS="$(plutil -extract status raw -o - "$OUT/notarization.json")"
if [[ "$STATUS" != "Accepted" ]]; then
  echo "Notarization not accepted. Inspect $OUT/notarization.json and the notary log." >&2
  exit 1
fi
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
echo "Signed and notarized disk image: $DMG"
echo "Before sharing, mount it and test installation on a clean Mac, including offline Gatekeeper behavior."
