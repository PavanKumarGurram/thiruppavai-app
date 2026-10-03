import Combine
import Foundation
import WebKit

/// Coordinates the official, visible YouTube player. Never extracts an audio stream.
@MainActor
final class AudioController: ObservableObject {
    @Published private(set) var verseID: Int?
    @Published private(set) var loadedVideoID: String?
    @Published private(set) var isPlaying = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var privacyAccepted = UserDefaults.standard.bool(forKey: "thiruppavai.youtube-consent.v1")
    private var verse: Verse?
    private weak var webView: WKWebView?

    func select(_ verse: Verse?) {
        guard verseID != verse?.id else { return }
        stop()
        self.verse = verse
        verseID = verse?.id
    }
    // Kept for source/back-up compatibility. Playback controls now belong to YouTube.
    func configure(rate: Double, volume: Double) {}
    func acceptPrivacyAndLoad() {
        privacyAccepted = true
        UserDefaults.standard.set(true, forKey: "thiruppavai.youtube-consent.v1")
        load()
    }
    func load() {
        guard privacyAccepted, let recording = verse?.recording else { return }
        errorMessage = nil
        loadedVideoID = recording.videoID
    }
    func toggle() {
        // Loading never autoplays. Starting playback is a tap on YouTube's own controls.
        if loadedVideoID == nil { load() }
        else if isPlaying { pause() }
    }
    func attach(_ view: WKWebView) { webView = view }
    func setPlaying(_ value: Bool) { isPlaying = value }
    func reportError(_ message: String) { isPlaying = false; errorMessage = message }
    func pause() {
        isPlaying = false
        webView?.evaluateJavaScript("window.player && window.player.pauseVideo && window.player.pauseVideo();", completionHandler: nil)
    }
    func stop() {
        pause()
        webView?.loadHTMLString("", baseURL: nil)
        webView = nil
        loadedVideoID = nil
        errorMessage = nil
        verse = nil
        verseID = nil
    }
    func revokePrivacy() {
        stop()
        privacyAccepted = false
        UserDefaults.standard.removeObject(forKey: "thiruppavai.youtube-consent.v1")
    }
}
