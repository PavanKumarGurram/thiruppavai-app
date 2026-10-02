import SwiftUI

@MainActor
struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        Form {
            Section("Reading") {
                Picker("Appearance", selection: $store.preferences.appearance) {
                    ForEach(Appearance.allCases) { Text($0.label).tag($0) }
                }
                Picker("Default reading view", selection: $store.preferences.readingMode) {
                    ForEach(ReadingMode.allCases) { Text($0.label).tag($0) }
                }
                HStack {
                    Text("Text size")
                    Slider(value: $store.preferences.fontSize, in: 16...32, step: 2)
                    Text("\(Int(store.preferences.fontSize)) pt").monospacedDigit().frame(width: 45)
                }
            }
            Section("Your library") {
                Text("Bookmarks, read marks, appearance, text size, volume, and playback speed are saved automatically on this Mac. There is no account or cloud sync.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button("Export backup…") { store.exportBackup() }
                    Button("Import backup…") { store.importBackup() }
                }
                Text("Import merges bookmarks and read marks without replacing your current settings. The backup is also useful before changing the app's bundle identifier for distribution.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section("Calendar & audio") {
                Text("December 16–January 14 is treated as the fixed Margazhi window, using your Mac's local date. Outside that window, the daily reflection rotates through the collection.")
                Text("Audio streams from SriPedia / ibiblio only after you press play. Recording availability depends on the host. No recordings are bundled or downloaded for offline use.")
            }.font(.callout).foregroundStyle(.secondary)
        }
        .formStyle(.grouped).padding(12).frame(width: 560, height: 560)
    }
}

@MainActor
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showNotices = false
    private var notices: String {
        guard let url = Bundle.main.url(forResource: "Notices", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return "See the Notices.md file in the source project." }
        return text
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                GarlandMark().frame(width: 34, height: 42)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Thiruppavai").font(.system(size: 27, design: .serif))
                    Text("A garland of thirty · Version 1.0").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }.padding(24)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    info("The collection", "Andal's thirty Tamil pasurams are presented with traditional text, letter-based Roman transliteration, and original plain-English prose meanings. Spacing and some spellings differ between editions. The English renderings convey the narrative sense, not the full range of traditional commentary.")
                    info("Reading the Roman text", "ā, ī, ū, ē, ō mark long vowels. ṭ, ṇ, and ḷ are retroflex sounds; ḻ is Tamil “zh”; ṟ is the strong r; ṉ distinguishes ன from ந (n). c represents ச and t represents த; their spoken sounds depend on context. This is a letter-based aid, not a substitute for learning pronunciation from a reciter.")
                    info("The daily verse", "The app follows the requested fixed December 16–January 14 convention. Actual Tamil-calendar dates can vary; this is not an astronomical calendar. The date is checked regularly and when the app becomes active.")
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Text and recording sources").font(.headline)
                        Link("Project Madurai edition at Tamilnation", destination: URL(string: "https://tamilnation.org/sathyam/east/pirapantam/mp005baandaal")!)
                        Link("Tamil Wikisource", destination: URL(string: "https://ta.wikisource.org/wiki/திருப்பாவை")!)
                        Link("P. R. Ramachander's English translation", destination: URL(string: "https://www.hindupedia.com/en/Thiruppavai")!)
                        Link("SriPedia / ibiblio temple recitations", destination: URL(string: "https://ibiblio.org/sripedia/ebooks/tpv/vstp01.html")!)
                    }.font(.callout)
                    info("Privacy and recording rights", "Reading preferences stay on this Mac. There are no analytics, advertisements, or accounts. Pressing play connects to ibiblio, which receives an ordinary network request; opening a source page launches your browser. Recordings are streamed, not redistributed. Before distributing the app publicly, review audio permissions and the hosts' terms.")
                    DisclosureGroup("Text provenance and font license", isExpanded: $showNotices) {
                        Text(notices).font(.system(size: 11, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 12)
                    }
                }
                .textSelection(.enabled).padding(24).frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 660, height: 660).background(AppStyle.canvas)
    }
    private func info(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(text).font(.callout).lineSpacing(4).foregroundStyle(.secondary)
        }
    }
}
