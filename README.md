# Thiruppavai App

Devotional reading app for Andal's Thiruppavai — all 30 pasurams with Tamil text, Roman transliteration, English meanings, per-pasuram audio, Margazhi day matching, search, bookmarks, and reading progress.

Built by Perplexity Computer from the owner's spec; maintained in this repo.

## What's here

- `web/` — self-contained single-file web app (`Thiruppavai.html`). Open in any browser; works offline (audio streams, needs internet).
- `mac/` — native SwiftUI macOS app source (Xcode 15+, macOS 13+). Open `Thiruppavai.xcodeproj`, select the Thiruppavai scheme and My Mac, press ⌘R. See `mac/README.md` and `mac/Docs/TESTING.md`.
- `ios/` — coming soon (native SwiftUI iOS/iPadOS app sharing the verse collection, calendar logic, search, and bookmark models with the Mac app).

## Credits

- Verse text, transliteration, meanings: verified against published texts (sources listed in-app).
- Audio (v1): streams from SriPedia's collection on ibiblio — being replaced with a credited YouTube playlist.
- Andal's Thiruppavai itself is a ~9th-century devotional work. App code: see `mac/LICENSE`.

## Status

- Web app: working.
- Mac app: source complete, needs first build/test in Xcode on a Mac.
- iOS app: in progress with Perplexity Computer.
