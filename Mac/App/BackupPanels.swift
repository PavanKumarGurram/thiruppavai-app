import AppKit
import UniformTypeIdentifiers

extension AppStore {
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
            notice = "Reading backup exported."
        } catch { notice = "Export failed: \(error.localizedDescription)" }
    }
    func importBackup() {
        let panel = NSOpenPanel()
        panel.title = "Import reading backup"
        panel.message = "Bookmarks and read marks will be merged. Current appearance will stay unchanged."
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        importBackup(from: url)
    }
}
