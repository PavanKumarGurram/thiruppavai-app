import SwiftUI

@MainActor
struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showPrivacy = false
    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Theme", selection: $store.preferences.appearance) {
                    ForEach(Appearance.allCases) { Text($0.label).tag($0) }
                }.pickerStyle(.segmented)
            }
            Section("Reading") {
                ReadingSelectors()
                Picker("Default sections", selection: $store.preferences.readingMode) {
                    ForEach(ReadingMode.allCases) { Text($0.label).tag($0) }
                }
                HStack {
                    Text("Text size")
                    Slider(value: $store.preferences.fontSize, in: 16...32, step: 2)
                    Text("\(Int(store.preferences.fontSize)) pt").monospacedDigit()
                }
            }
            Section("Your library") {
                Text("Bookmarks, read marks, theme, text size and language choices save on this Mac. No automatic cloud sync.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button("Export backup…") { store.exportBackup() }
                    Button("Import backup…") { store.importBackup() }
                }
            }
            Section("YouTube") {
                Text("Recordings play in YouTube's visible player, not as extracted audio. YouTube controls availability and may show advertisements; internet is required.")
                    .font(.callout).foregroundStyle(.secondary)
                Button("Privacy, terms & credits") { showPrivacy = true }
            }
        }
        .formStyle(.grouped).padding(12).frame(width: 600, height: 650)
        .sheet(isPresented: $showPrivacy) { YouTubePrivacyView() }
    }
}

@MainActor
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Thiruppavai · Guide & sources").font(.title2)
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }.padding(20)
            Divider()
            ReadingGuideView()
        }.frame(width: 740, height: 760)
    }
}
