import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var verses: [Verse] = []
    @Published var preferences: ReadingPreferences { didSet { persist() } }
    @Published var selectedID: Int? = 0 {
        didSet {
            let newID = selectedID ?? 0
            if preferences.lastVerseID != newID { preferences.lastVerseID = newID }
        }
    }
    @Published var query = ""
    @Published var filter: LibraryFilter = .all
    @Published var now = Date()
    @Published var showAbout = false
    @Published var notice: String?
    @Published private(set) var libraryError: String?
    private let persistence: PreferencesStore

    init() {
        let persistence = PreferencesStore()
        self.persistence = persistence
        let saved = persistence.load()
        preferences = saved.preferences
        do {
            verses = try BundledLibrary.load()
            selectedID = saved.preferences.lastVerseID
        } catch { libraryError = error.localizedDescription }
        if saved.recovered {
            notice = "The previous save could not be read. Its original data has been retained, and fresh reading preferences are in use."
        }
    }

    var selectedVerse: Verse? { verses.first { $0.id == selectedID } }
    var daily: DailyVerse { DailyVerse.resolve(on: now) }
    var featured: Verse? { verses.first { $0.id == daily.verseID } }
    var filteredVerses: [Verse] {
        VerseSearch.filter(verses, query: query, filter: filter,
                           bookmarks: preferences.bookmarks, read: preferences.read)
    }
    func showVerse(_ id: Int) {
        guard verses.contains(where: { $0.id == id }) else { return }
        // A hidden selected row is confusing, so navigation restores the full collection.
        query = ""
        filter = .all
        selectedID = id
    }
    func showToday() { now = Date(); showVerse(daily.verseID) }
    func go(_ offset: Int) {
        guard let id = selectedVerse?.id else { return }
        showVerse(id + offset)
    }
    func toggleBookmark(_ id: Int) {
        if preferences.bookmarks.contains(id) { preferences.bookmarks.remove(id) }
        else { preferences.bookmarks.insert(id) }
    }
    func toggleRead(_ id: Int) {
        if preferences.read.contains(id) { preferences.read.remove(id) }
        else { preferences.read.insert(id) }
    }
    func resizeText(_ delta: Double) {
        preferences.fontSize = min(32, max(16, preferences.fontSize + delta))
    }
    func clearFilters() { query = ""; filter = .all }
    func persist() {
        do { try persistence.save(preferences) }
        catch { notice = "Reading preferences could not be saved: \(error.localizedDescription)" }
    }

    func exportBackup() {
        let panel = NSSavePanel()
        panel.title = "Export reading backup"
        panel.nameFieldStringValue = "Thiruppavai-reading.json"
        panel.allowedContentTypes = [.json]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        do {
            try PreferencesStore.encode(preferences).write(to: url, options: .atomic)
            notice = "Reading backup exported. Keep this file to move your bookmarks and progress to another installation."
        } catch { notice = "Export failed: \(error.localizedDescription)" }
    }
    func importBackup() {
        let panel = NSOpenPanel()
        panel.title = "Import reading backup"
        panel.message = "Bookmarks and read marks will be merged. Your current appearance and text size will stay unchanged."
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        do {
            if let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size > 1_048_576 {
                throw BackupError.tooLarge
            }
            let imported = try PreferencesStore.decode(Data(contentsOf: url))
            preferences.mergeMarks(from: imported)
            notice = "Bookmarks and read marks merged successfully."
        } catch { notice = "Import failed: \(error.localizedDescription)" }
    }
}
