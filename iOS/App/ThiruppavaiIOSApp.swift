import SwiftUI

@main
@MainActor
struct ThiruppavaiIOSApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var audio = AudioController()

    init() { AppStyle.registerFonts() }

    var body: some Scene {
        WindowGroup {
            MobileRootView()
                .environmentObject(store)
                .environmentObject(audio)
                .preferredColorScheme(store.preferences.appearance.colorScheme)
                .tint(AppStyle.accent)
        }
    }
}
