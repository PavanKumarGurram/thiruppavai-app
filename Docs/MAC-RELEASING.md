# Preparing a distribution release

This is a future release workflow, not a claim that this project has already been compiled, notarized, or approved. Local Debug builds are kept separate from distribution signing so the application and content code do not need to be rewritten.

## Before distribution

- **Mac verification:** compile with Xcode and complete Docs/TESTING.md, including every recording and preference persistence.
- **Stable identity:** set an owned reverse-DNS bundle identifier, version, and build number. Export/import a reading backup if moving from the placeholder local identity.
- **Content review:** obtain fluent-reader review of every script and meaning language, with Tamil scholarly input. Keep source/font notices and AI-art labels intact.
- **Audio rights:** verify that streaming the collection in a publicly distributed app is permitted. Obtain permission for any bundled/offline audio, or replace it with recordings licensed for that use. Nothing in this source archive licenses the recordings.
- **Privacy review:** the optional YouTube player can involve third-party advertising and data handling under [Google's Privacy Policy](http://www.google.com/policies/privacy). Review Docs/AUDIO-LICENSING.md, re-audit the manifest, and provide your own public privacy policy and support contact. The app does not operate analytics or cloud accounts, but do not describe embedded YouTube as ad-free or offline.
- **Release credentials:** install your own Developer ID Application certificate and private key in your Mac's Keychain. Do not email credentials, put them in the repository, or include them in this archive.

Apple documents the account and certificate requirements in its [Developer ID guide](https://developer.apple.com/developer-id/). It requires appropriate Developer ID signing, a secure timestamp, Hardened Runtime, and valid entitlements for modern direct-distribution notarization in [Notarizing macOS software before distribution](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

## Settings already separated

`Mac/Config/Base.xcconfig` holds the bundle identity, version, deployment target, resource settings, sandbox, and Hardened Runtime. `Debug.xcconfig` is local ad-hoc signing; `Release.xcconfig` can optionally include the ignored `Signing.local.xcconfig`. Select the **Thiruppavai-Mac** scheme in the combined project.

Copy `Mac/Config/Signing.local.xcconfig.example` to `Mac/Config/Signing.local.xcconfig` when ready, and fill in public signing identifiers. The example contains no secrets; certificates and private keys remain in Keychain.

The entitlements permit only:

- App Sandbox.
- Outbound network connections for audio.
- Read/write access to files explicitly chosen by the user for backup import/export.

There are no microphone, contacts, incoming-network, arbitrary filesystem, or cloud-container entitlements. `get-task-allow` is not included in the source entitlements; inspect the final Release signature to ensure Xcode has not added a development-only entitlement.

`PrivacyInfo.xcprivacy` declares the app's own UserDefaults usage with reason CA92.1, as defined by [Apple's required-reason API documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). Re-audit the manifest whenever features or dependencies change; it is not an automated compliance guarantee.

## Xcode Organizer route

Use a configured Release identity, choose a generic Mac destination, and create an archive with **Product > Archive**. Follow Xcode Organizer's direct-distribution / Developer ID flow, whose exact labels vary by Xcode version, as described in [Apple's distribution-signing guide](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac).

The Release configuration builds standard macOS architectures rather than only the active architecture. Confirm the output includes the architectures you actually intend to support, and test them.

## Optional scripted route

The opt-in `scripts/release-mac.sh` archives the app, verifies its signature, creates a read-only DMG with an Applications shortcut, signs the DMG, submits it to the notary service, and staples/validates the accepted ticket. This follows Apple's [packaging and notarization guidance](https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution).

First create a named `notarytool` Keychain profile on your own Mac, following Apple's documentation. The script uses only that profile name; it does not accept a password in the source files.

```bash
export SIGNING_IDENTITY='Developer ID Application: Your Name (YOURTEAMID)'
export TEAM_ID='YOURTEAMID'
export BUNDLE_ID='com.yourdomain.Thiruppavai'
export NOTARY_PROFILE='ThiruppavaiNotary'
export RELEASE_READY=YES
bash scripts/release-mac.sh
```

Do not run this until you intend to upload the built app to Apple for notarization. The script is not an Xcode build phase and is never invoked automatically by the app or local build.

If notarization is not accepted, inspect the saved JSON response and retrieve the corresponding notary log. Resolve the issue and rebuild; do not distribute the rejected artifact.

## Final release checks

Mount the resulting DMG and copy the app into Applications on a clean test Mac. Test Gatekeeper behavior both online and offline, audio permission/dependency behavior, app settings, clean install, upgrades, and restoring a reading backup.

For Mac App Store distribution, revisit distribution signing, store metadata, sandbox/privacy declarations, content rights, and review requirements. This project is structured to support that work, but this guide does not claim App Store readiness or approval.
