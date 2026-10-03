# Personal testing now, distribution later

This project is configured for local personal-device development, not a ready-to-publish App Store release. No IPA, distribution certificate, provisioning profile, App Store record, upload, or public listing has been created.

## Personal use

Choose your own Personal Team and a unique bundle identifier in the iOS target's Signing & Capabilities settings. A free Personal Team permits personal-device testing but its provisioning expires after seven days; rebuild/reinstall as needed, according to [Apple's account guidance](https://developer.apple.com/help/account/basics/about-your-developer-account).

There are no iCloud, push-notification, app-group, associated-domain, or other optional service capabilities in this app. Keep automatic signing enabled for development and do not add credentials to source control.

## Later TestFlight or App Store release

TestFlight and App Store distribution are membership resources of the Apple Developer Program, as explained in [Apple's membership overview](https://developer.apple.com/help/account/membership/programs-overview/). Switching to a properly configured distribution team is a signing/release task; the shared reading and playback code does not need to be rewritten.

Before starting:

- **Ownership:** decide which person or organization will own the developer account, app record, and bundle identifier. If a friend helps, use the appropriate account/team workflow and document ownership rather than sharing Apple Account passwords or signing keys.
- **Identity:** choose a stable bundle identifier, version, and build number. Export a reading backup before changing identifiers or removing an old installation.
- **Testing:** compile and run on real iPhone and iPad devices, complete Docs/TESTING.md, and resolve all build or runtime issues.
- **Content:** have fluent readers review all five recitation scripts and six meaning languages, with Tamil scholarly input. Preserve source/font notices and AI-art labels; review Docs/AUDIO-LICENSING.md and YouTube terms before public distribution.
- **Privacy:** the optional YouTube player is a third-party service that may show advertising and collect information under [Google's Privacy Policy](http://www.google.com/policies/privacy). Re-audit the manifest and App Store disclosures for the final app; do not represent it as entirely ad-free or free of third-party data handling. Supply an owner-specific public privacy policy and support contact before release. The current manifest documents the app's own UserDefaults use, not a comprehensive audit of YouTube.
- **Presentation:** prepare accurate screenshots from actual devices/simulators, support and privacy URLs, and store metadata. Do not use mock screenshots as proof of a tested native app.

Use the **Thiruppavai-iOS** scheme for an iOS archive and the intended distribution team in automatic signing. Apple explains how TestFlight builds are uploaded through App Store Connect and distributed to testers in [Get started with TestFlight](https://developer.apple.com/videos/play/tech-talks/110343/).

Unlike the Mac release, this iOS workflow does not use Developer ID certificates or the included Mac DMG notarization script. Do not run `release-mac.sh` to distribute the iPhone app.

## Local signing configuration

For reproducible local settings, optionally copy `iOS/Config/Signing.local.xcconfig.example` to `iOS/Config/Signing.local.xcconfig`, set your public team ID and unique bundle identifier, and leave that file uncommitted. The file is ignored by Git; no password, private key, authentication token, or certificate belongs in it.

No automated iOS upload script is included. Distribution should be a deliberate action after testing, permissions review, and ownership decisions.
