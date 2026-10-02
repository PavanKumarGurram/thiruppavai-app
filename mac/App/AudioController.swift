import AVFoundation
import Combine
import Foundation

/// One app-owned player. Selecting a verse does not request its recording.
/// Track observers are removed on every selection change and app termination.
@MainActor
final class AudioController: ObservableObject {
    @Published private(set) var verseID: Int?
    @Published private(set) var isPlaying = false
    @Published private(set) var isLoading = false
    @Published private(set) var position: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var errorMessage: String?
    @Published private(set) var didFinish = false
    @Published var repeatVerse = false

    private let player = AVPlayer()
    private var verse: Verse?
    private var wantsPlayback = false
    private var rate: Float = 1
    private var statusObservation: NSKeyValueObservation?
    private var controlObservation: NSKeyValueObservation?
    private var periodicObserver: Any?
    private var notificationObservers: [NSObjectProtocol] = []
    private var timeout: Task<Void, Never>?
    private var generation = UUID()

    var statusText: String {
        if let errorMessage { return errorMessage }
        if isLoading { return "Loading the recording… You can cancel while it loads." }
        if isPlaying { return "Playing temple recitation · SriPedia / ibiblio" }
        if didFinish { return "Recitation complete. Play again or choose another verse." }
        if position > 0 { return "Paused. Continue whenever you are ready." }
        return "Streams when you press play. Internet required; text is available offline."
    }
    var buttonTitle: String {
        isLoading ? "Cancel loading" : (isPlaying ? "Pause" : "Play recitation")
    }

    func select(_ verse: Verse?) {
        guard verseID != verse?.id else { return }
        clearItem()
        self.verse = verse
        verseID = verse?.id
    }
    func configure(rate: Double, volume: Double) {
        self.rate = Float(rate)
        player.volume = Float(volume)
        if wantsPlayback && isPlaying { player.rate = self.rate }
    }
    func toggle() {
        if wantsPlayback || isLoading {
            if isLoading { clearItem() }
            else {
                wantsPlayback = false
                player.pause()
                isPlaying = false
                timeout?.cancel(); timeout = nil
            }
        } else { play() }
    }
    func play() {
        guard let verse, let url = verse.audioURL else { return }
        if player.currentItem == nil || errorMessage != nil {
            clearItem()
            installItem(url: url)
        }
        errorMessage = nil
        if didFinish {
            didFinish = false
            player.seek(to: .zero)
            position = 0
        }
        wantsPlayback = true
        isLoading = true
        player.playImmediately(atRate: rate)
        startTimeout()
    }
    func seek(to seconds: Double) {
        guard duration > 0, seconds.isFinite else { return }
        let clamped = min(duration, max(0, seconds))
        didFinish = false
        position = clamped
        player.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
    }
    func stop() {
        clearItem()
        verse = nil
        verseID = nil
    }

    private func installItem(url: URL) {
        let item = AVPlayerItem(url: url)
        item.audioTimePitchAlgorithm = .spectral
        player.replaceCurrentItem(with: item)
        let token = generation
        statusObservation = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor [weak self] in
                guard let self, self.generation == token else { return }
                if item.status == .failed {
                    self.fail("The recording could not load. Check your connection, try again, or open its source page.")
                }
                self.updateTime()
            }
        }
        controlObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in
                guard let self, self.generation == token else { return }
                switch self.player.timeControlStatus {
                case .playing:
                    self.isPlaying = true
                    self.isLoading = false
                    self.timeout?.cancel(); self.timeout = nil
                case .waitingToPlayAtSpecifiedRate:
                    self.isPlaying = false
                    self.isLoading = self.wantsPlayback
                    if self.wantsPlayback { self.startTimeout() }
                case .paused:
                    self.isPlaying = false
                    if !self.wantsPlayback { self.isLoading = false }
                @unknown default: break
                }
            }
        }
        periodicObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.generation == token else { return }
                self.updateTime()
            }
        }
        let center = NotificationCenter.default
        notificationObservers.append(center.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.generation == token else { return }
                self.finished(token: token)
            }
        })
        notificationObservers.append(center.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, self.generation == token else { return }
                self.fail("Playback was interrupted. Try again or open the recording source.")
            }
        })
    }
    private func updateTime() {
        let current = player.currentTime().seconds
        let total = player.currentItem?.duration.seconds ?? 0
        if current.isFinite { position = max(0, current) }
        if total.isFinite && total > 0 { duration = total }
    }
    private func finished(token: UUID) {
        timeout?.cancel(); timeout = nil
        isPlaying = false
        isLoading = false
        if repeatVerse && wantsPlayback {
            player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] success in
                Task { @MainActor [weak self] in
                    guard let self, success, self.generation == token, self.wantsPlayback else { return }
                    self.position = 0
                    self.player.playImmediately(atRate: self.rate)
                    self.startTimeout()
                }
            }
        } else {
            wantsPlayback = false
            didFinish = true
            position = duration
        }
    }
    private func startTimeout() {
        guard timeout == nil else { return }
        let token = generation
        timeout = Task { @MainActor [weak self] in
            do { try await Task.sleep(nanoseconds: 25_000_000_000) }
            catch { return }
            guard let self, self.generation == token, self.wantsPlayback, !self.isPlaying else { return }
            self.fail("The recording is taking too long to load. Try again or open the source page.")
        }
    }
    private func fail(_ message: String) {
        wantsPlayback = false
        player.pause()
        isPlaying = false
        isLoading = false
        errorMessage = message
        timeout?.cancel(); timeout = nil
    }
    private func clearItem() {
        generation = UUID()
        wantsPlayback = false
        timeout?.cancel(); timeout = nil
        player.pause()
        statusObservation?.invalidate(); statusObservation = nil
        controlObservation?.invalidate(); controlObservation = nil
        if let periodicObserver { player.removeTimeObserver(periodicObserver) }
        periodicObserver = nil
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()
        player.replaceCurrentItem(with: nil)
        position = 0; duration = 0
        isPlaying = false; isLoading = false; didFinish = false; errorMessage = nil
    }
}
