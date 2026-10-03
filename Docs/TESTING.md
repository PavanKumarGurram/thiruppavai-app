# Verification status and native test checklist

This source archive was prepared on Linux without Xcode, Apple SDKs, or an iOS/macOS runtime. Static syntax/resource checks are not a successful native build; compilation, Swift unit-test execution, simulator/device launch, native visual inspection, and playback testing remain pending.

## Source-level verification

Checks cover tree-sitter Swift syntax, Xcode OpenStep parsing, project file/target references, JSON/XML/property-list validity, shell syntax, illustration/icon assets, font glyph coverage, and embedded-player JavaScript. The iOS target includes eighteen Swift files; Mac includes nineteen. Thirteen files are shared, and each target has twelve resource build entries. The package manifest and test file bring the archive to twenty-six Swift files.

The original thirty Tamil texts, Roman transliterations and English meanings remain unchanged. Companion data covers thirty verses with five script views and six meanings each; thirty unique YouTube IDs; and ten story chapters referencing six bundled illustrations. Structural checks do not certify linguistic accuracy, native font shaping, recording rights or runtime playback.

Metadata inspection found twenty-nine videos marked embeddable; pasuram 9 returned a sign-in/verification response. None was tested inside native WKWebView here. See the source links and limitations in Docs/AUDIO-LICENSING.md; availability can change.

## First build

```bash
bash scripts/check-ios.sh
bash scripts/check-mac.sh
```

Each script runs fourteen shared-core Swift Package tests, then builds the corresponding app. iOS builds for Simulator without signing; Mac uses local ad-hoc signing. The app schemes do not contain hosted XCTest targets; use `scripts/test-core.sh`, not Command-U on an app scheme.

Run both apps from Xcode after compilation. If a failure occurs, record the scheme, run destination, Xcode/OS versions and complete first compiler error.

## Reading and appearance

- Open all thirty pasurams on iPhone, iPad and Mac. Check navigation boundaries, restoration, compact back behavior and iPad split view.
- For every verse, switch among five recitation scripts, Roman, and six meaning languages. Check eight source lines, complete wrapping, copy/select, vowel marks, conjuncts and rare letters. Human language review remains outstanding.
- Confirm Roman text matches the prior version. Verify script and meaning selections are independent, persist, and appear in Settings.
- Search in Tamil, Telugu, Kannada, Malayalam, Devanagari, Roman and English; try `03` and `999`. Exercise All/Saved/Unread and clear-filter recovery.
- Test System/Light/Dark from Settings and reader toolbar, including changing system appearance while System is selected.
- Check portrait/landscape, narrow iPad multitasking, largest Dynamic Type, Bold Text, VoiceOver, keyboard navigation and touch targets. Confirm all glyphs and controls remain unclipped.
- Open Andal's story, every chapter shortcut, all six illustrations, captions and source disclosures. Verify AI labels and the distinction between tradition and history. Story text is in English.
- In airplane mode, confirm reading, meanings, search, bookmarks, artwork and story remain available. Online source links/player should not be represented as offline.

## Upgrade and backup compatibility

- Before upgrading, export a reading backup. Retain the installed bundle identifiers/team and install over the prior build without deleting it.
- Verify existing bookmarks, read marks, theme, size and last verse survive; new language settings initially default to Tamil/English.
- Bookmark 1 and 30, mark 2 read, choose dark mode, change size/script/meaning and select verse 15. Quit/relaunch and verify persistence.
- Export from iOS, import on Mac, add a bookmark, export and import back. Confirm merging changes only marks, not destination style or YouTube consent.
- Import malformed, future-version and oversized backups; expect recoverable errors. Keep raw recovery bytes if a saved preference blob cannot be decoded.

## Daily calendar

- Core tests cover every fixed December 16–January 14 day, year boundary, outside-season dates, leap day and timezone differences.
- For UI debugging inject an AppStore `now` value rather than changing the device clock.
- Verify refresh after midnight/foregrounding and that the outside-season feature is labelled a reflection.

## YouTube on real devices

- Before consent, opening a verse must not load YouTube. Inspect network traffic where possible. Read the privacy notice, agree and load, then explicitly press Play in YouTube.
- Start and listen to every verse. Verify recording correspondence, performer/uploader credits and original links. Treat metadata mapping as a starting check, not proof of all playback.
- Test seeking, volume and any speed/fullscreen controls YouTube exposes. Keep controls, branding, links and ads unobscured; do not expect the former native repeat/speed UI.
- Scroll the player below its visibility threshold; open Settings, About, story or privacy; switch verses; background/lock the device; activate another Mac window. Playback must pause and must not restart without user action.
- Rapidly switch verses and reload. Ensure stale state callbacks never play an old verse or produce simultaneous players.
- Test headphones/Bluetooth, route changes, calls and other interruptions. Verify safe foreground resumption without hidden playback; report any WebKit behavior requiring correction.
- Disable connectivity, retry and restore it. Test embed errors, sign-in restrictions and original-video fallback, especially pasuram 9. Do not bypass YouTube restrictions.
- Withdraw consent, verify the player stops and consent is required again. Confirm text and bookmarks are unaffected. Withdrawal does not delete data already held by Google.
- Change the development bundle ID in a disposable build and verify YouTube Referer identity and absence of error 153. The installed bundle ID is used dynamically.

## Before distribution

Complete the applicable release guide, qualified language review, privacy/rights review and signed-release tests. No checklist item above is pre-marked as a passing native test, and no installer or App Store upload is included.
