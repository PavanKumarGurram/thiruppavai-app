# Shared code and platform boundaries

Both native targets compile the same thirteen physical shared Swift files. No remote Swift packages, generated-project utility, server, or API key is required to open the supplied Xcode project.

## Layout

```text
Thiruppavai.xcodeproj/        Two native targets and two shared schemes
Shared/
  Core/                      Models, calendar, search, preferences, companion content
    Resources/verses.json     Unchanged original Tamil, Roman and English edition
    Resources/readings.json   Five script views and six meaning languages per verse
    Resources/recordings.json Thirty verified playlist-to-pasuram mappings
    Resources/story.json      Ten sourced chapters, captions and asset references
  State/AppStore.swift       Selection, persistence, settings, backup merging
  Playback/AudioController.swift
                             YouTube consent, selection and foreground coordination
  UI/                        Shared reader, player, guide, story and design system
  Resources/                 Five fonts, six illustrations, icons, notices, privacy
iOS/App/                     Touch navigation, Dynamic Type, Files backup dialogs
Mac/App/                     Desktop navigation, menu commands, AppKit backup panels
Tests/CoreTests.swift        Fourteen core tests (run on Mac)
Package.swift                Core test harness, not an application entry point
scripts/                     Local checks and opt-in future Mac release script
Docs/                        Testing, licensing and distribution guidance
```

## Content and state

- **Original edition:** `verses.json` is unchanged from the earlier Mac source, including the Roman strings. Its legacy ibiblio fields are retained as provenance and for format compatibility; no current playback code requests those recordings.
- **Companion resources:** `CompanionContent` loads the four-language script conversions, five new meaning translations, recording mappings and story. Validation checks collection coverage at launch. Both app targets and the core test package use the same JSON files.
- **Languages:** independent `RecitationScript` and `MeaningLanguage` selections persist locally. Search includes all supplied recitation strings and meanings. Scripts are letter-based pronunciation aids; meanings are AI-assisted, not human-certified.
- **Persistence:** the original UserDefaults key and schema version remain unchanged. The custom decoder supplies defaults for missing language settings while preserving old marks and style. JSON import merges only bookmarks/read marks; it does not overwrite destination style. YouTube consent is a separate local preference and is not transferred by a reading backup.
- **Offline assets:** all reading content, story text and illustrations are bundled. Story sources, original-video links and the player require network access.

## Playback boundaries

The rest of the interface is native SwiftUI; only the official YouTube player uses WKWebView. `YouTubePlayerSection` controls consent and attribution; `YouTubeFactory` loads YouTube's iframe API with a bundle-identity base URL; the coordinator reports state/errors and monitors visibility. No audio/video streams are downloaded, extracted, proxied or cached by app code.

There is no autoplay or background-audio capability. The player pauses on loss of sufficient visibility, app inactivity, a covering app sheet, or verse navigation. The original-video link remains available for restrictions the app cannot resolve. Native WebKit behavior, ads, interruptions and all recordings must still be tested on real devices.

The two representable adapters use conditional UIKit/AppKit imports in the same file. Platform-specific code is excluded by Swift conditional compilation, not by duplicating player logic. See Docs/AUDIO-LICENSING.md for official embedding-policy sources and known verification limits.

## UI and future changes

The shared reader, language selectors, guide, privacy notice and story are compiled into both targets. iOS retains touch navigation, swipe actions and Files dialogs; Mac retains desktop commands and native file panels. System/Light/Dark appearance uses the shared adaptive asset colors.

Do not maintain the old Mac-only folder as an independent active branch without merging fixes. Build and smoke-test both targets after shared changes, retain the existing installed bundle identities for upgrades, and complete the release guides before distribution.
