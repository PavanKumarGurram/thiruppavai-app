import SwiftUI

struct DevotionalArtwork: View {
    let name: String
    let caption: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(name).resizable().scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .accessibilityLabel(caption)
            Text(caption).font(.caption).foregroundStyle(.secondary)
        }
    }
}

@MainActor
struct AndalStoryCard: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var audio: AudioController
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DevotionalArtwork(name: "andal-krishna-hero",
                caption: "Andal and Krishna · Original AI-generated devotional illustration")
            Text("Andal's story").font(.system(.title2, design: .serif))
            Text("From a tulasi garden to a garland of verses. Explore ten illustrated chapters of the traditional life of Goda Devi.")
                .font(.body).foregroundStyle(.secondary)
            Button { audio.pause(); store.showStory = true } label: {
                Label("Read the illustrated story", systemImage: "book")
            }.buttonStyle(.borderedProminent).controlSize(.large)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
struct AndalStoryView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Andal · Goda Devi").font(.system(.title2, design: .serif))
                Spacer()
                Button("Done") { dismiss() }
            }.padding(20)
            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("The garland and the song").font(.system(.largeTitle, design: .serif))
                            Text("A sourced retelling of the traditional devotional narrative, in English. Miracles and divine encounters are presented as tradition, not verified historical events; the artwork is AI-generated and not historical evidence.")
                                .foregroundStyle(.secondary)
                            Menu("Chapters") {
                                ForEach(CompanionContent.story) { chapter in
                                    Button(chapter.title) { proxy.scrollTo(chapter.id, anchor: .top) }
                                }
                            }.buttonStyle(.bordered)
                        }
                        ForEach(CompanionContent.story) { chapter in
                            VStack(alignment: .leading, spacing: 18) {
                                Text("CHAPTER \(chapter.id) · \(chapter.subtitle.uppercased())")
                                    .font(.caption.weight(.semibold)).foregroundStyle(AppStyle.gold)
                                Text(chapter.title).font(.system(.title, design: .serif))
                                DevotionalArtwork(name: chapter.image, caption: chapter.caption)
                                ForEach(Array(chapter.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                                    Text(.init(paragraph)).font(.system(.body, design: .serif))
                                        .lineSpacing(7).textSelection(.enabled)
                                }
                                DisclosureGroup("Chapter sources") {
                                    VStack(alignment: .leading, spacing: 10) {
                                        ForEach(chapter.sources) { source in
                                            if let url = URL(string: source.url) { Link(source.title, destination: url) }
                                        }
                                    }.font(.caption).padding(.top, 10)
                                }
                            }.id(chapter.id)
                            Divider()
                        }
                        Text("Original AI-generated artwork was created for this edition. It is not copied from the recording thumbnails or presented as a photograph, a temple-authorized icon, or a reconstructed historical event.")
                            .font(.caption).foregroundStyle(.secondary)
                    }.padding(24).frame(maxWidth: 900).frame(maxWidth: .infinity)
                }
            }
        }.background(AppStyle.canvas)
        #if os(macOS)
        .frame(minWidth: 780, idealWidth: 900, minHeight: 680, idealHeight: 850)
        #endif
    }
}
