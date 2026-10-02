import AppKit
import SwiftUI

extension Notification.Name {
    static let focusVerseSearch = Notification.Name("Thiruppavai.focusVerseSearch")
}

@main
@MainActor
struct ThiruppavaiApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var audio = AudioController()

    init() { AppStyle.registerFonts() }

    var body: some Scene {
        Window("Thiruppavai", id: "main") {
            RootView()
                .environmentObject(store)
                .environmentObject(audio)
                .preferredColorScheme(store.preferences.appearance.colorScheme)
                .tint(AppStyle.accent)
        }
        .defaultSize(width: 1160, height: 840)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Thiruppavai") { store.showAbout = true }
            }
            CommandGroup(after: .textEditing) {
                Button("Search Verses") {
                    NotificationCenter.default.post(name: .focusVerseSearch, object: nil)
                }.keyboardShortcut("f")
            }
            CommandMenu("Reading") {
                Button("Verse of the Day") { store.showToday() }.keyboardShortcut("t")
                Button("Home") { store.selectedID = 0 }.keyboardShortcut("h", modifiers: [.command, .shift])
                Divider()
                Button("Previous Pasuram") { store.go(-1) }
                    .keyboardShortcut(.leftArrow, modifiers: [.command, .option])
                    .disabled((store.selectedVerse?.id ?? 1) <= 1)
                Button("Next Pasuram") { store.go(1) }
                    .keyboardShortcut(.rightArrow, modifiers: [.command, .option])
                    .disabled(store.selectedVerse == nil || store.selectedVerse?.id == 30)
                Button("Toggle Bookmark") {
                    if let id = store.selectedVerse?.id { store.toggleBookmark(id) }
                }.keyboardShortcut("d").disabled(store.selectedVerse == nil)
                Button("Toggle Read Mark") {
                    if let id = store.selectedVerse?.id { store.toggleRead(id) }
                }.keyboardShortcut("r", modifiers: [.command, .shift]).disabled(store.selectedVerse == nil)
                Divider()
                Button("Play / Pause Recitation") { audio.toggle() }
                    .keyboardShortcut(.space, modifiers: .option).disabled(store.selectedVerse == nil)
                Button("Larger Text") { store.resizeText(2) }.keyboardShortcut("+")
                Button("Smaller Text") { store.resizeText(-2) }.keyboardShortcut("-")
                Divider()
                Button("Export Reading Backup…") { store.exportBackup() }
                Button("Import Reading Backup…") { store.importBackup() }
            }
        }
        Settings {
            SettingsView().environmentObject(store)
                .preferredColorScheme(store.preferences.appearance.colorScheme)
                .tint(AppStyle.accent)
        }
    }
}
