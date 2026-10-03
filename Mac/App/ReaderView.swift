import SwiftUI

@MainActor
struct ReaderView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var audio: AudioController
    let verse: Verse
    var body: some View {
        ScrollView {
            PasuramReaderContent(verse: verse, textSize: CGFloat(store.preferences.fontSize))
                .padding(36).frame(maxWidth: 1040).frame(maxWidth: .infinity)
        }
        .background(AppStyle.canvas)
        .navigationTitle("\(String(format: "%02d", verse.id)) · \(verse.title)")
        .onDisappear { audio.pause() }
    }
}
