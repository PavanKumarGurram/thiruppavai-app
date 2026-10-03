import SwiftUI
import WebKit
#if os(iOS)
import UIKit
#else
import AppKit
#endif

@MainActor
struct YouTubePlayerSection: View {
    @EnvironmentObject private var audio: AudioController
    let verse: Verse
    @State private var showPrivacy = false
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Watch & listen on YouTube", systemImage: "play.rectangle").font(.headline)
            if let recording = verse.recording {
                if audio.loadedVideoID == recording.videoID {
                    YouTubeWebView(videoID: recording.videoID, audio: audio)
                        .frame(minWidth: 200, minHeight: 250, idealHeight: 290, maxHeight: 330)
                        .id(recording.videoID)
                        .accessibilityLabel("YouTube player for pasuram \(verse.id)")
                } else {
                    Text("The recording plays in a visible YouTube video player. Internet required; no audio extraction, downloads, or background playback.")
                        .font(.subheadline).foregroundStyle(.secondary)
                    if !audio.privacyAccepted {
                        Text("Loading connects to YouTube/Google, which may use cookies, receive network/device information, and show ads. By agreeing, you accept the app's YouTube privacy notice and YouTube Terms.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Button(audio.privacyAccepted ? "Load YouTube player" : "Agree & load YouTube player") {
                        audio.select(verse)
                        if audio.privacyAccepted { audio.load() }
                        else { audio.acceptPrivacyAndLoad() }
                    }.buttonStyle(.borderedProminent).controlSize(.large)
                }
                if let error = audio.errorMessage {
                    Text(error).font(.caption).foregroundStyle(.red)
                    Button("Reload player") { audio.select(nil); audio.select(verse); audio.load() }
                }
                Text("Performer: \(recording.performer)\nUploader: \(recording.uploader)")
                    .font(.subheadline).fixedSize(horizontal: false, vertical: true)
                Text("Performer credit follows the video title; uploader is not asserted to be the recording-rights owner.")
                    .font(.caption).foregroundStyle(.secondary)
                HStack {
                    if let url = recording.watchURL { Link("Original video ↗", destination: url) }
                    if let url = URL(string: recording.uploaderURL) { Link("Uploader channel ↗", destination: url) }
                }.font(.caption)
            } else {
                Text("No verified recording mapping is available.").foregroundStyle(.secondary)
            }
            Button("YouTube privacy, terms & recording credits") { showPrivacy = true }
                .font(.caption).buttonStyle(.borderless)
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(AppStyle.panel, in: RoundedRectangle(cornerRadius: 14))
        .onDisappear { audio.pause() }
        .sheet(isPresented: $showPrivacy) { YouTubePrivacyView() }
        .onChange(of: showPrivacy) { _ in if showPrivacy { audio.pause() } }
    }
}

@MainActor
struct YouTubePrivacyView: View {
    @EnvironmentObject private var audio: AudioController
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("YouTube privacy & credits").font(.title2)
                Spacer()
                Button("Done") { dismiss() }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("This app uses YouTube API Services for its optional embedded player. By using that feature, you agree to be bound by YouTube's Terms of Service. Nothing connects to YouTube until you explicitly agree and load a player.")
                    Text("The app keeps reading preferences locally and has no app analytics or account login. YouTube and Google may receive your IP address, app identity, device/browser information, cookies and playback activity, and may serve advertising. Their handling of that information is governed by Google's Privacy Policy. Player data is not extracted or sent to an app-operated server.")
                    Text("The videos credit M. L. Vasanthakumari as performer and Madhura Gaanam as uploader. No Creative Commons or redistribution license was verified for these recordings. The original videos remain hosted by YouTube; neither credit nor embedding is a claim of ownership or permission to copy the recording.")
                    Text("The player remains visible and uses YouTube's controls and branding. Playback pauses when the player leaves view or the app becomes inactive. If embedding is blocked, use the original-video link; the app does not bypass restrictions.")
                    Link("YouTube Terms of Service", destination: URL(string: "https://www.youtube.com/t/terms")!)
                    Link("Google Privacy Policy", destination: URL(string: "http://www.google.com/policies/privacy")!)
                    Link("Google account permissions", destination: URL(string: "https://security.google.com/settings/security/permissions")!)
                    Link("YouTube Developer Policies", destination: URL(string: "https://developers.google.com/youtube/terms/developer-policies")!)
                    Text("You may withdraw this app's consent below. This stops the player and requires consent again; it does not delete information already held by Google. Manage Google's stored information through your Google account and device/browser privacy controls.")
                    Button("Withdraw YouTube consent") { audio.revokePrivacy(); dismiss() }
                        .buttonStyle(.bordered)
                }.font(.body).textSelection(.enabled)
            }
        }.padding(24)
        #if os(macOS)
        .frame(width: 690, height: 640)
        #endif
    }
}

@MainActor
private final class YouTubeCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    weak var webView: WKWebView?
    let audio: AudioController
    var timer: Timer?
    init(audio: AudioController) { self.audio = audio }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: Any] else { return }
        if let state = data["state"] as? Int {
            if state == 1 && !isVisible { audio.pause() }
            else { audio.setPlaying(state == 1) }
        }
        if let code = data["error"] as? Int {
            audio.reportError("YouTube could not play this video (code \(code)). Use Original video to open YouTube, or reload. Availability depends on YouTube and the rights holder.")
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        audio.reportError("The YouTube player could not load. Check your connection or use Original video.")
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, ["https", "http"].contains(url.scheme ?? "") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #else
            NSWorkspace.shared.open(url)
            #endif
        }
        return nil
    }
    var isVisible: Bool {
        guard let view = webView, let window = view.window, !view.isHidden else { return false }
        #if os(iOS)
        var visible = view.convert(view.bounds, to: window).intersection(window.bounds.inset(by: window.safeAreaInsets))
        var parent = view.superview
        while let current = parent {
            if current.isHidden || current.alpha < 0.01 { return false }
            if current.clipsToBounds { visible = visible.intersection(current.convert(current.bounds, to: window)) }
            parent = current.superview
        }
        return !visible.isNull && visible.width >= 200 && visible.height >= 200 && UIApplication.shared.applicationState == .active
        #else
        return view.visibleRect.width >= 200 && view.visibleRect.height >= 200
            && window.isVisible && window.isKeyWindow && NSApplication.shared.isActive
        #endif
    }
    func startMonitoring() {
        timer = Timer(timeInterval: 0.3, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if !self.isVisible && self.audio.isPlaying { self.audio.pause() }
            }
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
    }
    func tearDown(_ view: WKWebView) {
        timer?.invalidate(); timer = nil
        view.evaluateJavaScript("window.player && window.player.pauseVideo && window.player.pauseVideo();", completionHandler: nil)
        view.stopLoading()
        view.loadHTMLString("", baseURL: nil)
        view.configuration.userContentController.removeScriptMessageHandler(forName: "youtube")
        view.navigationDelegate = nil; view.uiDelegate = nil
        webView = nil
    }
}

@MainActor
private enum YouTubeFactory {
    static func make(videoID: String, audio: AudioController, coordinator: YouTubeCoordinator) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        #if os(iOS)
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        #endif
        configuration.userContentController.add(coordinator, name: "youtube")
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = coordinator; view.uiDelegate = coordinator
        coordinator.webView = view
        audio.attach(view)
        let appID = (Bundle.main.bundleIdentifier ?? "com.example.Thiruppavai").lowercased()
        // YouTube's native-app identity format: HTTPS + the installed bundle identifier.
        let baseURL = URL(string: "https://\(appID)")!
        let html = """
        <!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
        <meta name="referrer" content="strict-origin-when-cross-origin">
        <style>html,body{margin:0;width:100%;height:100%;background:#111}#player{width:100%;height:100%;min-width:200px;min-height:200px}</style>
        </head><body><div id="player"></div>
        <script>
        function notify(x){window.webkit.messageHandlers.youtube.postMessage(x)}
        var ready=false;
        var loadTimeout=setTimeout(function(){if(!ready)notify({error:-1})},20000);
        function onYouTubeIframeAPIReady(){
          window.player=new YT.Player('player',{videoId:'\(videoID)',
            playerVars:{autoplay:0,playsinline:1,controls:1,origin:'\(baseURL.absoluteString)'},
            events:{onReady:()=>{ready=true;clearTimeout(loadTimeout)},
              onStateChange:e=>notify({state:e.data}),onError:e=>notify({error:e.data})}});
        }
        </script><script src="https://www.youtube.com/iframe_api"></script></body></html>
        """
        view.loadHTMLString(html, baseURL: baseURL)
        coordinator.startMonitoring()
        return view
    }
}

#if os(iOS)
@MainActor
private struct YouTubeWebView: UIViewRepresentable {
    let videoID: String
    let audio: AudioController
    func makeCoordinator() -> YouTubeCoordinator { YouTubeCoordinator(audio: audio) }
    func makeUIView(context: Context) -> WKWebView { YouTubeFactory.make(videoID: videoID, audio: audio, coordinator: context.coordinator) }
    func updateUIView(_ view: WKWebView, context: Context) {}
    static func dismantleUIView(_ view: WKWebView, coordinator: YouTubeCoordinator) { coordinator.tearDown(view) }
}
#else
@MainActor
private struct YouTubeWebView: NSViewRepresentable {
    let videoID: String
    let audio: AudioController
    func makeCoordinator() -> YouTubeCoordinator { YouTubeCoordinator(audio: audio) }
    func makeNSView(context: Context) -> WKWebView { YouTubeFactory.make(videoID: videoID, audio: audio, coordinator: context.coordinator) }
    func updateNSView(_ view: WKWebView, context: Context) {}
    static func dismantleNSView(_ view: WKWebView, coordinator: YouTubeCoordinator) { coordinator.tearDown(view) }
}
#endif
