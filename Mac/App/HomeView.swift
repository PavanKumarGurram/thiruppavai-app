import SwiftUI

@MainActor
struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    private let columns = [GridItem(.adaptive(minimum: 265), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 14) {
                        Eyebrow(text: "Thirty days of devotion")
                        Text("A garland of thirty.").font(.system(size: 38, design: .serif))
                            .foregroundStyle(AppStyle.ink)
                        Text("Begin with a verse. Return to its meaning.\nMake a little room for the sacred, every day.")
                            .font(.system(size: 14)).foregroundStyle(AppStyle.secondary).lineSpacing(5)
                    }
                    Spacer(minLength: 16)
                    Text(store.now, format: .dateTime.month(.abbreviated).day().year())
                        .font(.system(size: 12)).foregroundStyle(AppStyle.secondary)
                }
                if let verse = store.featured {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(store.daily.label.uppercased())
                                .font(.system(size: 10, weight: .semibold)).tracking(1.2)
                                .foregroundStyle(Color(red: 0.85, green: 0.79, blue: 0.61))
                            Spacer()
                            Text(String(format: "%02d", verse.id))
                                .font(.system(size: 34, design: .serif))
                        }
                        Text(verse.short).font(AppStyle.tamil(25)).lineSpacing(7)
                        Text("\(verse.title) · \(verse.theme)")
                            .font(.system(size: 17, design: .serif)).foregroundStyle(.white.opacity(0.85))
                        Text(store.daily.isMargazhi
                             ? "A verse for this morning. Read slowly, and let its meaning stay with you."
                             : "Margazhi returns December 16. Until then, explore a different pasuram each day.")
                            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.78))
                        Button { store.showVerse(verse.id) } label: {
                            HStack(spacing: 30) {
                                Text(store.daily.isMargazhi ? "Read today's verse" : "Read today's reflection")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 18).padding(.vertical, 12)
                            .foregroundStyle(Color(red: 0.12, green: 0.23, blue: 0.19))
                            .background(Color(red: 0.93, green: 0.91, blue: 0.85), in: RoundedRectangle(cornerRadius: 6))
                        }.buttonStyle(.plain).padding(.top, 4)
                    }
                    .foregroundStyle(.white).padding(30).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 0.09, green: 0.235, blue: 0.20), in: RoundedRectangle(cornerRadius: 12))
                }
                AndalStoryCard()
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("The thirty pasurams").font(.system(size: 25, design: .serif))
                        Spacer()
                        Text("Five scripts · Six meanings · Roman").font(.system(size: 11)).foregroundStyle(AppStyle.secondary)
                    }
                    if store.filteredVerses.isEmpty {
                        EmptyLibraryView(title: "A different word may help.",
                                         description: "Try any included script, a meaning, a Roman title, or a day number.",
                                         action: store.clearFilters)
                    } else {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                            ForEach(store.filteredVerses) { verse in
                                HomeVerseRow(verse: verse)
                            }
                        }
                    }
                }
                Text("ஆண்டாள் அருளிச்செய்த திருப்பாவை")
                    .font(AppStyle.tamil(12)).foregroundStyle(AppStyle.secondary).padding(.top, 8)
            }
            .padding(36).frame(maxWidth: 1120, alignment: .leading).frame(maxWidth: .infinity)
        }
        .navigationTitle("Thiruppavai")
    }
}

@MainActor
private struct HomeVerseRow: View {
    @EnvironmentObject private var store: AppStore
    let verse: Verse
    var body: some View {
        HStack(spacing: 10) {
            Button { store.showVerse(verse.id) } label: {
                HStack(spacing: 14) {
                    Text(String(format: "%02d", verse.id)).font(.system(size: 18, design: .serif))
                        .foregroundStyle(AppStyle.gold).frame(width: 26)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(verse.short).font(AppStyle.tamil(13)).lineLimit(2)
                        Text(verse.title).font(.system(size: 11)).foregroundStyle(AppStyle.secondary).lineLimit(1)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.vertical, 18).contentShape(Rectangle())
            }.buttonStyle(.plain)
            Button { store.toggleBookmark(verse.id) } label: {
                Image(systemName: store.preferences.bookmarks.contains(verse.id) ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(AppStyle.gold).frame(width: 28, height: 38)
            }.buttonStyle(.plain).help("Bookmark pasuram \(verse.id)")
                .accessibilityLabel(store.preferences.bookmarks.contains(verse.id) ? "Remove bookmark from pasuram \(verse.id)" : "Bookmark pasuram \(verse.id)")
        }
        .overlay(alignment: .top) { Rectangle().fill(AppStyle.rule).frame(height: 1) }
    }
}
