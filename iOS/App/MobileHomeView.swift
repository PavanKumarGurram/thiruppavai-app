import SwiftUI

@MainActor
struct MobileHomeView: View {
    @EnvironmentObject private var store: AppStore
    @ScaledMetric(relativeTo: .title2) private var tamilSize: CGFloat = 25
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 12) {
                    GarlandMark().frame(width: 35, height: 42)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("ANDAL'S SACRED VERSES").font(.caption).tracking(1.2).foregroundStyle(AppStyle.gold)
                        Text("A garland of thirty.").font(.system(.largeTitle, design: .serif))
                    }
                }.padding(.top, 8)
                Text("Begin with a verse. Return to its meaning. Make a little room for the sacred, every day.")
                    .font(.body).foregroundStyle(.secondary)
                if let verse = store.featured {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(store.daily.label.uppercased()).font(.caption.weight(.semibold)).tracking(1)
                            .foregroundStyle(Color(red: 0.88, green: 0.81, blue: 0.65))
                        Text(verse.short).font(AppStyle.tamil(tamilSize)).lineSpacing(8)
                        Text(verse.title).font(.system(.title2, design: .serif))
                        Text(store.daily.isMargazhi ? "A verse for this morning." : "Outside Margazhi, a different pasuram offers a daily reflection.")
                            .font(.subheadline).foregroundStyle(.white.opacity(0.82))
                        Button { store.showVerse(verse.id) } label: {
                            Label("Read today's verse", systemImage: "arrow.right")
                                .font(.headline).padding(14).frame(maxWidth: .infinity)
                                .foregroundStyle(Color(red: 0.10, green: 0.24, blue: 0.20))
                                .background(Color(red: 0.94, green: 0.92, blue: 0.85), in: RoundedRectangle(cornerRadius: 12))
                        }.buttonStyle(.plain)
                    }
                    .foregroundStyle(.white).padding(24).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.09, green: 0.235, blue: 0.20), in: RoundedRectangle(cornerRadius: 20))
                }
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Your reading").font(.headline)
                        Spacer()
                        Text("\(store.preferences.read.count) / 30").font(.subheadline.monospacedDigit())
                    }
                    ProgressView(value: Double(store.preferences.read.count), total: 30)
                        .accessibilityLabel("Reading progress")
                    Text("\(store.preferences.bookmarks.count) saved · Progress stays on this device")
                        .font(.caption).foregroundStyle(.secondary)
                }
                AndalStoryCard()
                Text("The thirty pasurams").font(.system(.title2, design: .serif))
                LazyVStack(spacing: 0) {
                    ForEach(store.verses) { verse in
                        Button { store.showVerse(verse.id) } label: {
                            MobileVerseRow(verse: verse).frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                        Divider()
                    }
                }
                Text("ஆண்டாள் அருளிச்செய்த திருப்பாவை").font(AppStyle.tamil(14))
                    .foregroundStyle(.secondary).padding(.vertical, 8)
            }.padding(22).frame(maxWidth: 820).frame(maxWidth: .infinity)
        }
        .background(AppStyle.canvas).navigationTitle("Daily reading")
        .navigationBarTitleDisplayMode(.inline)
    }
}
