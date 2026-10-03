import SwiftUI

@MainActor
struct MobileReaderView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var audio: AudioController
    @ScaledMetric(relativeTo: .body) private var scaledBody: CGFloat = 20
    let verse: Verse
    var body: some View {
        ScrollView {
            PasuramReaderContent(verse: verse, textSize: scaledBody * CGFloat(store.preferences.fontSize / 20))
                .padding(20).frame(maxWidth: 900).frame(maxWidth: .infinity)
        }
        .background(AppStyle.canvas)
        .navigationTitle("Pasuram \(verse.id)").navigationBarTitleDisplayMode(.inline)
        .onDisappear { audio.pause() }
    }
}
