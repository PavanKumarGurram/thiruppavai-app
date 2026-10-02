# Thiruppavai for Mac

A native SwiftUI reading companion with all thirty pasurams, Tamil text, Roman transliteration, English meanings, a daily verse, search, automatic bookmarks and read marks, and individual streamed recitations. This archive is a source project, not a precompiled or notarized installer.

## Start here

- **Runtime target:** macOS 13 or later, including Apple silicon.
- **Build tools:** Xcode 15 or later. No Homebrew, XcodeGen, CocoaPods, or third-party Swift packages are required.
- **Build status:** the project was assembled and statically checked on Linux. It has not been compiled, launched, visually tested, or signed for distribution on macOS. The first Xcode build and the native smoke tests below are still required.

The two-column interface uses Apple's native [NavigationSplitView, available from macOS 13](https://developer.apple.com/documentation/technotes/tn3154-adopting-swiftui-navigation-split-view). The chosen target lets the design remain native without assuming you have the newest macOS release.

## Open and run in Xcode

1. Extract this ZIP into a writable folder on your Mac.
2. Open **Thiruppavai.xcodeproj**. Do not open Package.swift for the main app; that package exists only for core tests.
3. Select the **Thiruppavai** scheme and **My Mac** as the run destination.
4. Press **Command-R**.
5. If Xcode asks to complete first-launch setup or install matching components, complete that setup.

Debug is configured for local ad-hoc signing (`CODE_SIGN_IDENTITY = -`, equivalent to “Sign to Run Locally”), with no development team selected. Keep that configuration for this private build; the project does not need distribution credentials to run locally.

If Xcode reports a signing problem, select the app target, open Build Settings, and confirm that the Debug Code Signing Identity is **Sign to Run Locally**, Code Signing Style is **Manual**, and Development Team is empty. Do not disable Gatekeeper globally or add arbitrary security exceptions.

If your macOS is older than 13 or your installed Xcode is older than 15, send the exact version and build error before changing the target. No newer-only Observation or SwiftData APIs are used.

## Build and install from Terminal

Open Terminal in the extracted `ThiruppavaiMac` folder and run:

```bash
bash scripts/build-local.sh
open build/DerivedData/Build/Products/Debug/Thiruppavai.app
```

The script builds for the local Apple silicon Mac and prints the app's full path. To install it, use Finder to copy **Thiruppavai.app** from that output folder into **Applications**, then launch it normally.

If Command Line Tools points to the standalone tools instead of Xcode, choose the installed Xcode under **Xcode > Settings > Locations > Command Line Tools** and retry. This source archive deliberately contains no shell script that automatically replaces an existing app in Applications.

## Included experience

- **Reading library:** a resizable native sidebar, a daily-feature home page, and all thirty verse views.
- **Languages:** all sections together, or Tamil, Roman transliteration, and English meaning separately; selectable text and adjustable reading size.
- **Daily verse:** December 16 is day 1; December 31 is day 16; January 1 is day 17; January 14 is day 30. Your Mac's local date controls the result. Outside this fixed window a labelled daily reflection rotates through the verses.
- **Search:** Tamil, Roman text, simplified titles, English meanings, and exact day numbers.
- **Persistence:** bookmarks, read marks, appearance, text size, last selected verse, speed, and volume save automatically on this Mac. There is no web-style “Save your copy” step.
- **Appearance:** system, light, and dark modes; bundled Noto Serif Tamil; a custom app icon; native menus and controls.
- **Audio:** per-verse play/pause, seek, speed, repeat, volume, load cancellation, retry/error messaging, and source-page links. Changing verse or returning home stops playback; nothing plays automatically.
- **Backup:** export/import a small JSON reading backup from the Reading menu or Settings. Import merges bookmarks and read marks and leaves current style preferences unchanged. Web HTML bookmarks do not automatically import into this native version.

The recitations use the previously verified [SriPedia / ibiblio collection](https://ibiblio.org/sripedia/ebooks/tpv/vstp01.html), played through Apple's [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer). Text and fonts are bundled for offline reading; recordings are not bundled and require internet access.

## Keyboard shortcuts

| Action | Shortcut |
|---|---|
| Focus verse search | Command-F |
| Today's verse | Command-T |
| Home | Command-Shift-H |
| Previous / next verse | Command-Option-Left / Right |
| Toggle bookmark | Command-D |
| Toggle read mark | Command-Shift-R |
| Play / pause | Option-Space |
| Larger / smaller text | Command-Plus / Minus |
| Settings | Command-Comma |

## Verify on your Mac

Run the shared-core tests:

```bash
bash scripts/test-core.sh
```

They cover all thirty Margazhi dates, year boundaries, timezone differences, leap-day fallback, collection integrity, searches, filters, persistence, corrupt-data recovery, backup merging, and future-format rejection. These are Swift Package tests; the app scheme does not include an XCTest host target, so use this command instead of Command-U on the app scheme.

Follow **Docs/TESTING.md** for native interface and audio smoke tests. The source checks performed here are documented in that file and do not replace Xcode compilation.

## Project structure

```text
Thiruppavai.xcodeproj/       Ready-to-open macOS application and shared scheme
App/                        Native SwiftUI screens, app model, AVPlayer controller
Core/                       Shared Foundation models, calendar, search, persistence
Core/Resources/verses.json   All 30 texts, meanings, and verified audio mappings
Resources/                  Tamil font, app icon, adaptive colors, notices, privacy manifest
Config/                     Debug/Release settings, entitlements, Info.plist
Tests/                      Swift Package unit tests for shared core logic
scripts/                    Local build, core tests, and opt-in future release workflow
Docs/                       Testing checklist and future signing/notarization guide
.github/workflows/          Optional macOS CI build; not run or connected here
```

The application target compiles the same `Core/*.swift` files tested by Package.swift. There is no package-resolution step in the app build, and the app has no backend or login dependency.

## Future distribution

Read **Docs/RELEASING.md** before sharing a compiled build. Release settings already separate signing configuration from application code, with sandbox and Hardened Runtime enabled; Apple's direct-distribution process uses [Developer ID signing and notarization](https://developer.apple.com/developer-id/).

The default bundle identifier is a local placeholder, `com.example.Thiruppavai`. Choose a stable identifier you control before releasing. Export a reading backup before changing the identifier, then import it into the new build; preferences are scoped to the application identity.

Recordings remain external streams. Review the host's terms and obtain any permissions needed for public distribution or future offline bundling; public availability is not a redistribution license. Text provenance and the full font license are included in **Resources/Notices.md** and the app's About window.
