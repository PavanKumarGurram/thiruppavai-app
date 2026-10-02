# Verification checklist

The source archive is prepared on Linux, where AppKit, SwiftUI, Xcode, and a macOS runtime are unavailable. Native compilation, the Swift unit tests, AVPlayer playback, accessibility behavior, and native screenshots have not been executed here; do not treat source validation as a passing Mac build.

## Source checks performed before delivery

Completed source-level checks:

- Swift syntax with a tree-sitter Swift parser; this does not type-check Apple APIs.
- Xcode project parsing and references; every app/core source and bundled resource is present.
- XML property lists, entitlements, shared scheme, and workspace parsing.
- All thirty verse IDs, eight Tamil and Roman lines each, English meanings, and matching audio/source URLs.
- Exact preservation of the previously delivered Tamil, transliteration, and meaning strings.
- Asset-catalog JSON, all ten Mac app-icon slots, and the bundled Tamil font.
- Shell-script syntax and an archive free of generated build folders or signing credentials.

The final source pass parsed 14 Swift files (12 application/core files, the package manifest, and the test file), 65 Xcode project objects with 28 existing file references, three shell scripts, and ten icon images. The app target includes 12 Swift compilation inputs and five resource entries. All 30 content records were compared against the previously delivered reading edition without changes to the Tamil, Roman, or English fields. These are static checks, not executed Swift tests.

The preceding web app successfully started playback for all thirty stream URLs. That establishes source availability at that time, not native AVPlayer compatibility or continued hosting availability.

## Build and core tests on your Mac

```bash
bash scripts/test-core.sh
bash scripts/build-local.sh
```

Record your macOS version, Xcode version, and the complete first compiler error if a build fails. Use the Thiruppavai app scheme in Xcode for the UI, and `swift test` for the Foundation-only core package tests.

## Native interface

- Launch from Xcode, then from the built `.app` in Finder.
- Confirm the app icon and bundled Tamil font render correctly.
- Test system, light, and dark modes, including a system theme change.
- Resize the window to its minimum size and to a wide screen; confirm no essential control is clipped.
- Open all thirty verses using the sidebar, home rows, and previous/next buttons.
- Confirm the first/last verse navigation limits and scroll reset on verse changes.
- Switch All/Tamil/Roman/Meaning and test both text-size limits.
- Select and copy Tamil, Roman, and English text.
- Test search for `மார்கழி`, `Margazhi`, `mārkaḻi`, `lotus`, `03`, and `999`.
- Test All/Saved/Unread filters, empty results, and clearing filters.
- Confirm Command-F focuses search even with the sidebar hidden.
- Check menu shortcuts, keyboard-only navigation, VoiceOver labels, Settings, and the About/reading-guide window.

## Persistence and backups

- Bookmark verses 1 and 30, mark verse 2 as read, change appearance/text size/speed/volume, and select verse 15.
- Quit normally, reopen, and confirm those values and the selected verse persist.
- Export a backup, then import it; verify marks are merged and current appearance is not changed.
- Cancel both file dialogs without side effects.
- Try a malformed JSON file and a future schema version; verify an explanatory error rather than a crash.
- Export before changing a bundle identifier. After the change, import into the new identity and verify the marks are restored.
- Note that bookmarks in a previously saved web HTML file are not imported by this native JSON backup mechanism.

## Calendar

- Core tests cover each day of December 16–January 14, both year-boundary endpoints, December 15, January 15, leap day, and Los Angeles versus Kolkata.
- For UI checking without changing the system clock, temporarily set `now` in AppStore during a debug run, then remove that change. Confirm the home feature and “Today's verse” behavior with the real clock afterward.
- Leave the app open across a local midnight or simulate it during debugging; confirm the feature refreshes. Wake the Mac and verify the active-date refresh.

## Audio

- Start and briefly play every verse, checking its title and recording source.
- Check pause/resume, seeking, speed changes, volume, mute via volume zero, and repeat.
- Seek near the end with repeat on and off; confirm looping versus completion.
- Switch verses, select Home, and quit while playing; the old audio must stop.
- Rapidly press Play and Cancel while loading; stale requests must not restart playback.
- Start playback offline; confirm timeout/failure messaging and that text remains readable.
- Restore the connection and retry. Open the source-page fallback.
- Check buffering interruptions and playback after the Mac sleeps and wakes.
- Confirm merely opening a verse does not request audio and never autoplays.

## Distribution

Complete Docs/RELEASING.md before sharing binaries. Test the signed/notarized artifact independently from the local debug app, including clean installation, offline Gatekeeper behavior, and the supported CPU architectures.
