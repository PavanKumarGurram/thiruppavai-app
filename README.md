# Thiruppavai for iPhone, iPad, and Mac

Edition 1.1 adds multilingual recitation and meanings, visible YouTube playback, prominent theme controls, original devotional artwork, and a ten-chapter illustrated Andal story. One shared SwiftUI codebase serves separate native iOS and Mac targets.

This is a source archive, not a compiled installer or a tested device build. Static source checks were performed on Linux; Xcode compilation, unit tests, native rendering and real-device playback still need to run on your Mac.

## Open and run

1. Extract into a new folder. Keep your current working project and export a reading backup before replacing a build.
2. Open **Thiruppavai.xcodeproj**.
3. For iPhone/iPad, select **Thiruppavai-iOS** and an installed simulator, then press **Command-R**. The minimum target is iOS/iPadOS 17.
4. For Mac, select **Thiruppavai-Mac** and **My Mac**, then press **Command-R**. The minimum target is macOS 13.

No XcodeGen, CocoaPods, Homebrew, remote Swift packages, server, or API key is required. The only WebView is the official YouTube player; the rest of the app is native SwiftUI.

For your physical iPhone, choose your Personal Team under the iOS target's Signing & Capabilities, keep automatic signing enabled, and retain the unique bundle identifier you used for your existing installation, following [Apple's device setup guide](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device). Enable Developer Mode if requested using [Apple's instructions](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device.md).

Free Personal Team provisioning expires seven days after issuance, requiring another Xcode build/install, according to [Apple's account guidance](https://developer.apple.com/help/account/basics/about-your-developer-account). Do not send passwords or signing keys; no credentials are included in this archive.

## Preserve your library

The same UserDefaults key and backup schema are retained. Old saves receive Tamil recitation/English meaning defaults for the new settings; bookmarks, read marks, theme, size, and last verse are preserved by the migration decoder.

Retain your existing bundle identifier and team when upgrading. If changing identity, export a JSON reading backup first and import it into the new build; import merges marks and leaves current style choices alone.

## What changed

- **Recitation:** original Tamil plus Telugu, Kannada, Malayalam and Devanagari renderings of the same Tamil words. Roman transliteration remains unchanged in its own section.
- **Meanings:** Tamil, Telugu, Kannada, Malayalam, English and Hindi for every pasuram. Script and meaning language are independently selectable and searchable.
- **Fonts:** bundled Noto Serif fonts for all five Indic scripts, including the extended characters used in the pronunciation aids.
- **YouTube:** a visible official player per pasuram, performer/uploader credits, original links, consent/privacy notice, off-screen/inactive pausing, and no extracted audio.
- **Theme:** System/Light/Dark controls in Settings on both platforms and a reader toolbar appearance menu.
- **Artwork:** six labelled, original AI-generated devotional illustrations of Andal, Krishna and scenes from the traditional story.
- **Andal's story:** ten sourced, illustrated English chapters covering her names and tradition, discovery, upbringing, worn garland, divine acceptance, poetry, bridal dream, Srirangam journey, union and living legacy.

All text, meanings, fonts and artwork are bundled for offline reading. YouTube recordings require an internet connection, and playback depends on YouTube's current availability and embed permissions.

## Language notes

The recitation renderings are letter-based aids, not translations or a complete phonetic account of Tamil. The in-app guide explains extended letters such as ఴ, ೞ, ഴ and ऴ, short e/o in Devanagari, and Tamil distinctions that other scripts cannot fully represent.

The original English meanings are unchanged. The five new language versions were generated and reviewed with AI assistance, but have not been certified by human fluent readers or a Tamil scholar; qualified review is recommended before public distribution or scholarly use.

## Recording choice and rights

I searched for a verifiably reusable recording by an established artist and did not verify a suitable match. A LibriVox public-domain reading by Neeru Iyer was found, but it does not establish the requested popular-artist match; this edition therefore uses your approved [M. L. Vasanthakumari / Madhura Gaanam playlist](https://www.youtube.com/playlist?list=PLt2zzA2YA6ym01dYhVHUGZ1EemZO6-z1-).

See **Docs/AUDIO-LICENSING.md** for the checked candidates, source links, limits of the finding, playlist mapping, and embedding constraints. Credit is not a redistribution license, and no YouTube audio or video files are bundled.

### Player behavior

Agree to the YouTube privacy notice and load the player, then press Play inside YouTube's visible controls. There is no autoplay, audio-only extraction, background playback, or offline recording cache.

Scrolling the player substantially out of view, opening a covering sheet, switching verses, or making the app inactive pauses playback. The player must remain at least 200 by 200 points visible; keeping it in view is intentional, not a bug, under [YouTube's player requirements](https://developers.google.com/youtube/terms/required-minimum-functionality).

If an embed reports a restriction or network failure, use **Original video**. YouTube may show ads and may impose region, sign-in or rights-holder restrictions; this app does not bypass them.

Native AVPlayer speed/volume/repeat controls from the previous edition have been replaced by the controls YouTube exposes. Legacy saved speed/volume values remain in backups for compatibility but do not override YouTube.

## Build checks

```bash
bash scripts/check-ios.sh
bash scripts/check-mac.sh
```

These run the shared-core Swift Package tests and build the chosen target. The iOS script builds for Simulator without signing; the Mac script uses local ad-hoc signing. They do not upload or publish anything.

Follow **Docs/TESTING.md**, including the new language, migration and YouTube checks. The application schemes do not contain hosted XCTest targets; `bash scripts/test-core.sh` runs the core tests.

## Files and future distribution

The two targets compile the same Shared/Core, Shared/State, Shared/Playback and Shared/UI source files. The authoritative data lives in Shared/Core/Resources: `verses.json`, `readings.json`, `recordings.json`, and `story.json`.

Read **Docs/ARCHITECTURE.md**, **Docs/IOS-DISTRIBUTION.md**, and **Docs/MAC-RELEASING.md** before a public release. Revisit YouTube terms/privacy, recording rights, translation review, app ownership, and signing before distribution; this archive is not a release approval or legal clearance.
