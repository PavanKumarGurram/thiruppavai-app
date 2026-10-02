import SwiftUI

@MainActor
struct ReaderView: View {
    @EnvironmentObject private var store: AppStore
    let verse: Verse
    private var mode: ReadingMode { store.preferences.readingMode }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                HStack {
                    Button { store.selectedID = 0 } label: { Label("All pasurams", systemImage: "arrow.left") }
                        .buttonStyle(.plain).foregroundStyle(AppStyle.secondary)
                    Spacer()
                    Text(verse.calendarLabel).font(.system(size: 12)).foregroundStyle(AppStyle.secondary)
                }
                VStack(alignment: .leading, spacing: 12) {
                    Eyebrow(text: "Pasuram \(String(format: "%02d", verse.id)) / 30 · \(verse.chapter)")
                    Text(verse.short).font(AppStyle.tamil(29)).lineSpacing(8).foregroundStyle(AppStyle.ink)
                    Text(verse.title).font(.system(size: 20, design: .serif)).foregroundStyle(AppStyle.secondary)
                }.padding(.vertical, 8)
                Divider()
                HStack(spacing: 16) {
                    Picker("Reading language", selection: $store.preferences.readingMode) {
                        ForEach(ReadingMode.allCases) { Text($0.label).tag($0) }
                    }.pickerStyle(.segmented).frame(maxWidth: 365)
                    Spacer(minLength: 8)
                    Button { store.resizeText(-2) } label: { Image(systemName: "textformat.size.smaller") }
                        .help("Smaller text (⌘−)").disabled(store.preferences.fontSize <= 16)
                    Button { store.resizeText(2) } label: { Image(systemName: "textformat.size.larger") }
                        .help("Larger text (⌘+)").disabled(store.preferences.fontSize >= 32)
                }
                AudioPlayerView(verse: verse)
                VStack(alignment: .leading, spacing: 28) {
                    if mode == .all || mode == .tamil {
                        VStack(alignment: .leading, spacing: 22) {
                            Eyebrow(text: "The pasuram · தமிழ்")
                            Text(verse.tamil)
                                .font(AppStyle.tamil(store.preferences.fontSize))
                                .lineSpacing(store.preferences.fontSize * 0.7)
                                .fixedSize(horizontal: false, vertical: true)
                                .environment(\.locale, Locale(identifier: "ta"))
                        }
                    }
                    if mode == .all { Divider() }
                    if mode == .all || mode == .roman {
                        VStack(alignment: .leading, spacing: 20) {
                            Eyebrow(text: "Roman transliteration")
                            Text(verse.roman).font(.system(size: store.preferences.fontSize, design: .serif))
                                .lineSpacing(11).fixedSize(horizontal: false, vertical: true)
                            HStack(alignment: .firstTextBaseline) {
                                Text("Letter-based transliteration; ā, ī, ū, ē, ō are long vowels.")
                                    .font(.system(size: 11)).foregroundStyle(AppStyle.secondary)
                                Button("Reading guide") { store.showAbout = true }.buttonStyle(.link)
                            }
                        }
                    }
                    if mode == .all { Divider() }
                    if mode == .all || mode == .meaning {
                        VStack(alignment: .leading, spacing: 20) {
                            Eyebrow(text: "English meaning")
                            Text(verse.meaning).font(.system(size: store.preferences.fontSize, design: .serif))
                                .lineSpacing(10).fixedSize(horizontal: false, vertical: true)
                            Text("An original plain-English prose rendering, not a word-for-word translation.")
                                .font(.system(size: 11)).foregroundStyle(AppStyle.secondary)
                        }
                    }
                }
                .textSelection(.enabled)
                .padding(32).frame(maxWidth: .infinity, alignment: .leading)
                .background(AppStyle.panel, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppStyle.rule, lineWidth: 1))
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(verse.theme).font(.system(size: 18, design: .serif))
                        Text("Read marks and bookmarks save automatically.")
                            .font(.system(size: 11)).foregroundStyle(AppStyle.secondary)
                    }
                    Spacer()
                    Button { store.toggleRead(verse.id) } label: {
                        Label(store.preferences.read.contains(verse.id) ? "Read · mark unread" : "Mark as read",
                              systemImage: store.preferences.read.contains(verse.id) ? "checkmark.circle.fill" : "circle")
                    }.buttonStyle(FilledButtonStyle())
                }
                HStack {
                    Button { store.go(-1) } label: { Label("Previous", systemImage: "arrow.left") }
                        .disabled(verse.id == 1)
                    Spacer()
                    Button { store.go(1) } label: {
                        HStack { Text("Next pasuram"); Image(systemName: "arrow.right") }
                    }.disabled(verse.id == 30)
                }.buttonStyle(.bordered).controlSize(.large).padding(.top, 8)
            }
            .padding(36).frame(maxWidth: 1040, alignment: .leading).frame(maxWidth: .infinity)
        }
        .navigationTitle("\(String(format: "%02d", verse.id)) · \(verse.title)")
    }
}

@MainActor
struct AudioPlayerView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var audio: AudioController
    let verse: Verse
    @State private var scrubValue: Double = 0
    @State private var isScrubbing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Listen to this pasuram", systemImage: "waveform").font(.system(size: 13, weight: .semibold))
                Spacer()
                if let url = verse.sourceURL {
                    Link("Recording source ↗", destination: url).font(.system(size: 11))
                }
            }
            HStack(spacing: 16) {
                Button { audio.toggle() } label: {
                    HStack(spacing: 9) {
                        Image(systemName: audio.isLoading ? "xmark" : (audio.isPlaying ? "pause.fill" : "play.fill"))
                        Text(audio.buttonTitle)
                    }.frame(minWidth: 104)
                }.buttonStyle(FilledButtonStyle()).help("Play or pause (⌥Space)")
                VStack(spacing: 4) {
                    Slider(value: Binding(
                        get: { isScrubbing ? scrubValue : min(audio.position, max(audio.duration, 1)) },
                        set: {
                            scrubValue = $0
                            // Keyboard/accessibility adjustments can arrive outside a drag.
                            if !isScrubbing { audio.seek(to: $0) }
                        }
                    ), in: 0...max(audio.duration, 1), onEditingChanged: { editing in
                        if editing { scrubValue = audio.position; isScrubbing = true }
                        else { isScrubbing = false; audio.seek(to: scrubValue) }
                    })
                    .disabled(audio.duration <= 0)
                    .accessibilityLabel("Recitation position")
                    .accessibilityValue("\(time(audio.position)) of \(time(audio.duration))")
                    HStack {
                        Text(time(isScrubbing ? scrubValue : audio.position))
                        Spacer()
                        Text(audio.duration > 0 ? time(audio.duration) : "--:--")
                    }.font(.system(size: 10, design: .monospaced)).foregroundStyle(AppStyle.secondary)
                }
            }
            HStack(spacing: 14) {
                Picker("Speed", selection: $store.preferences.playbackRate) {
                    Text("0.75×").tag(0.75)
                    Text("1×").tag(1.0)
                    Text("1.25×").tag(1.25)
                    Text("1.5×").tag(1.5)
                }.frame(width: 120)
                Toggle(isOn: $audio.repeatVerse) {
                    Label("Repeat", systemImage: "repeat")
                }.toggleStyle(.button).help("Repeat this verse")
                Spacer(minLength: 10)
                Image(systemName: store.preferences.volume == 0 ? "speaker.slash" : "speaker.wave.2")
                    .foregroundStyle(AppStyle.secondary).accessibilityHidden(true)
                Slider(value: $store.preferences.volume, in: 0...1).frame(width: 85).accessibilityLabel("Volume")
            }.font(.system(size: 12))
            Text(audio.statusText)
                .font(.system(size: 11))
                .foregroundStyle(audio.errorMessage == nil ? AppStyle.secondary : Color.red)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20).background(AppStyle.panel.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppStyle.rule, lineWidth: 1))
    }
    private func time(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let value = Int(seconds)
        return String(format: "%d:%02d", value / 60, value % 60)
    }
}
