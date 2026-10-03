# Recording search and YouTube implementation

Checked on October 2, 2026. This is a practical source-and-permission check, not a legal opinion or a guarantee that an uploader owns all rights.

## Search result

Searches covered open-license/Creative Commons Thiruppavai recordings, M. L. Vasanthakumari, Nithyasree Mahadevan, Internet Archive/LibriVox, and other established performers. No suitable popular-artist recording with a verifiable open reuse grant was confirmed; that does not establish that none exists.

| Candidate | What the checked page states | Decision |
|---|---|---|
| M. L. Vasanthakumari | An Amazon Music edition displays “℗ 2012 Saregama India Ltd © Saregama India Ltd”; no open redistribution grant is stated ([album page](https://music.amazon.in/albums/B0752KPKBX)). | Not downloaded or bundled. The notice is for that edition and is not proof about the exact YouTube upload's recording provenance. |
| Nithyasree Mahadevan | An Internet Archive upload identifies the performer but does not state a recording reuse license or rights-holder authorization ([item page](https://archive.org/details/ThiruppavaiNithyasreeMahadevan)). | Free availability alone was not treated as permission. |
| Anuradha Krishnamoorthy | The album lists 30 songs and “℗ 2009 Abirami Audio Recording Private Limited,” without an open recording license ([Apple Music](https://music.apple.com/us/album/thiruppavai/320660560)). | No verified reuse grant. |
| Mambalam Sisters | The album lists 30 songs and “℗ 2013 Times Music,” without an open recording license ([Apple Music](https://music.apple.com/us/album/thiruppavai/640003546)). | No verified reuse grant. |
| Neeru Iyer / LibriVox | The Tamil reading is labelled Public Domain ([Internet Archive recording](https://archive.org/details/tiruppavai_nr_librivox)); LibriVox says its files may be used for any purpose, with a US-public-domain geographic caveat ([LibriVox policy](https://librivox.org/pages/about-listening-to-librivox/)). | A genuine alternative worth noting, but the sources do not establish the user's requested popular-artist match. Not substituted without that match. |

The user's pre-authorized fallback is therefore used: the [Madhura Gaanam playlist presenting M. L. Vasanthakumari](https://www.youtube.com/playlist?list=PLt2zzA2YA6ym01dYhVHUGZ1EemZO6-z1-). The performer and uploader are credited separately, without describing the uploader as the verified rights holder.

## Coverage and verification limits

The fetched playlist contained 30 entries: entries 2–30 are numbered in their titles, while the first item's thumbnail displays the Margazhi Thingal text ([first video](https://www.youtube.com/watch?v=ZPXxu9sVD24&hl=en)). All thirty IDs and per-video URLs are stored in `Shared/Core/Resources/recordings.json`; no missing-verse SriPedia fallback was needed.

Watch-page metadata indicated embed playability for 29 entries during the check. The pasuram 9 request returned a sign-in/verification gate rather than a usable playability result; its playlist entry remains mapped and has an original-video link ([pasuram 9](https://www.youtube.com/watch?v=xEVsIMLuK58&hl=en)). These are metadata checks, not proof that every recording will play in every region or in the native app.

## Why the player remains visible

YouTube prohibits isolating audio/video components, downloading/caching audiovisual copies without approval, and hidden/background playback through its API services ([Developer Policies](https://developers.google.com/youtube/terms/developer-policies)). A freely viewable video is not an open-license audio download.

Native WebViews must identify the client via a Referer derived from the installed app identifier, and the player must be at least 200 by 200 pixels with its controls unobscured ([Required Minimum Functionality](https://developers.google.com/youtube/terms/required-minimum-functionality)). The implementation uses an OS-provided WKWebView, a bundle-ID HTTPS base URL, the official iframe API, visible unmodified controls, and an off-screen/inactive pause monitor.

The user explicitly loads the player after a privacy/terms notice. YouTube branding is left intact; video and uploader links accompany each player, and the app links its notice to YouTube Terms, Google Privacy, and Google account permissions, as required by [YouTube's policies](https://developers.google.com/youtube/terms/developer-policies).

## Before public distribution

Recheck the live videos, current YouTube rules, privacy disclosures, and any known rights-holder complaints or restrictions. A native-embedding implementation is not a guarantee that an uploader has cleared the underlying recording; obtain qualified advice or direct rights-holder permission if that uncertainty becomes material.

If choosing the LibriVox alternative later, first verify its exact track coverage, suitability, and relevant jurisdictional rights, then add a separate licensed native-playback source. Do not extract the YouTube videos to reproduce the prior AVPlayer interface.
