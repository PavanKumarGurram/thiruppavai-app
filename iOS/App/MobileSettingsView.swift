import SwiftUI
import UniformTypeIdentifiers

struct ReadingBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data = Data()) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        _ = try PreferencesStore.decode(data)
        self.data = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

@MainActor
struct MobileSettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var exporting = false
    @State private var importing = false
    @State private var backup = ReadingBackupDocument()

    var body: some View {
        NavigationStack {
            Form {
                Section("Reading") {
                    Picker("Appearance", selection: $store.preferences.appearance) {
                        ForEach(Appearance.allCases) { Text($0.label).tag($0) }
                    }.pickerStyle(.segmented)
                    Picker("Reading view", selection: $store.preferences.readingMode) {
                        ForEach(ReadingMode.allCases) { Text($0.label).tag($0) }
                    }
                    ReadingSelectors()
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Base text size · \(Int(store.preferences.fontSize)) pt")
                        Slider(value: $store.preferences.fontSize, in: 16...32, step: 2)
                            .accessibilityLabel("Base reading text size")
                        Text("Reading text also follows your device's Dynamic Type setting.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section("Your library") {
                    LabeledContent("Read", value: "\(store.preferences.read.count) of 30")
                    LabeledContent("Bookmarked", value: "\(store.preferences.bookmarks.count)")
                    Button("Export reading backup") {
                        do {
                            backup = ReadingBackupDocument(data: try PreferencesStore.encode(store.preferences))
                            exporting = true
                        } catch { store.notice = error.localizedDescription }
                    }
                    Button("Import reading backup") { importing = true }
                    Text("Progress and preferences save automatically on this device. Import merges bookmarks and read marks, keeping current appearance settings. The same JSON backup works in the Mac app; there is no automatic cloud sync.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Section("Calendar & audio") {
                    Text("December 16–January 14 is the fixed Margazhi window, using your device's local date. Outside it, the daily reflection rotates through all thirty verses.")
                    Text("Recordings use YouTube's visible video player and require internet. Playback pauses when the app becomes inactive or the player scrolls out of view. No extracted audio or background playback is provided.")
                    Text("Opening a verse does not load YouTube. Fonts, all reading languages and illustrations are bundled for offline use.")
                }.font(.subheadline)
                Section {
                    NavigationLink("About, reading guide & sources") { MobileAboutView() }
                }
            }
            .scrollContentBackground(.hidden).background(AppStyle.canvas)
            .navigationTitle("Settings").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .fileExporter(isPresented: $exporting, document: backup, contentType: .json,
                      defaultFilename: "Thiruppavai-reading") { result in
            switch result {
            case .success: store.notice = "Reading backup exported."
            case .failure(let error): store.notice = "Export failed: \(error.localizedDescription)"
            }
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url): store.importBackup(from: url)
            case .failure(let error): store.notice = "Import failed: \(error.localizedDescription)"
            }
        }
        .alert("Thiruppavai", isPresented: Binding(
            get: { store.notice != nil }, set: { if !$0 { store.notice = nil } }
        )) { Button("OK", role: .cancel) { store.notice = nil } } message: { Text(store.notice ?? "") }
    }
}

@MainActor
struct MobileAboutView: View {
    var body: some View {
        ReadingGuideView().navigationTitle("About & sources").navigationBarTitleDisplayMode(.inline)
    }
}
