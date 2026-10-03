import Combine
import SwiftUI

@MainActor
struct MobileRootView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var audio: AudioController
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var compactColumn: NavigationSplitViewColumn = .sidebar
    @State private var showSettings = false
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility, preferredCompactColumn: $compactColumn) {
            MobileLibraryView()
                .navigationSplitViewColumnWidth(min: 260, ideal: 310, max: 400)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { showSettings = true } label: { Image(systemName: "slider.horizontal.3") }
                            .accessibilityLabel("Settings and reading backup")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { store.showToday(); compactColumn = .detail } label: { Image(systemName: "sun.max") }
                            .accessibilityLabel("Open today's verse")
                    }
                }
        } detail: {
            Group {
                if let error = store.libraryError {
                    ContentUnavailableView {
                        Label("Collection unavailable", systemImage: "book.closed")
                    } description: { Text(error) }
                } else if let verse = store.selectedVerse {
                    MobileReaderView(verse: verse).id(verse.id)
                } else {
                    MobileHomeView()
                }
            }
            .background(AppStyle.canvas)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let verse = store.selectedVerse {
                        Button { store.toggleBookmark(verse.id) } label: {
                            Image(systemName: store.preferences.bookmarks.contains(verse.id) ? "bookmark.fill" : "bookmark")
                        }.accessibilityLabel(store.preferences.bookmarks.contains(verse.id) ? "Remove bookmark" : "Bookmark this verse")
                    }
                    Button { showSettings = true } label: { Image(systemName: "slider.horizontal.3") }
                        .accessibilityLabel("Settings and reading backup")
                    Menu {
                        Picker("Appearance", selection: $store.preferences.appearance) {
                            ForEach(Appearance.allCases) { Text($0.label).tag($0) }
                        }
                    } label: { Image(systemName: "circle.lefthalf.filled") }
                        .accessibilityLabel("Light, dark, or system appearance")
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showSettings) { MobileSettingsView() }
        .sheet(isPresented: $store.showStory) { AndalStoryView() }
        .onChange(of: showSettings) { if showSettings { audio.pause() } }
        .onChange(of: store.showStory) { if store.showStory { audio.pause() } }
        .alert("Thiruppavai", isPresented: Binding(
            get: { store.notice != nil && !showSettings },
            set: { if !$0 { store.notice = nil } }
        )) { Button("OK", role: .cancel) { store.notice = nil } } message: { Text(store.notice ?? "") }
        .onAppear {
            if store.selectedVerse != nil { compactColumn = .detail }
            synchronizePlayer()
        }
        .onChange(of: store.selectedID) {
            // A compact back gesture may clear selection. Do not push detail again.
            if store.selectedID != nil { compactColumn = .detail }
            synchronizePlayer()
        }
        .onChange(of: compactColumn) {
            if compactColumn == .sidebar && sizeClass == .compact { audio.pause() }
        }
        .onChange(of: store.preferences.playbackRate) { configurePlayer() }
        .onChange(of: store.preferences.volume) { configurePlayer() }
        .onChange(of: scenePhase) {
            if scenePhase == .active { store.now = Date() }
            else { audio.pause(); store.persist() }
        }
        .onReceive(clock) { store.now = $0 }
    }
    private func synchronizePlayer() {
        audio.select(store.selectedVerse)
        configurePlayer()
    }
    private func configurePlayer() {
        audio.configure(rate: store.preferences.playbackRate, volume: store.preferences.volume)
    }
}

@MainActor
struct MobileLibraryView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        List(selection: $store.selectedID) {
            Section {
                NavigationLink(value: 0) {
                    HStack(spacing: 14) {
                        GarlandMark().frame(width: 28, height: 35)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Home & daily verse").font(.headline)
                            Text(store.daily.label).font(.caption).foregroundStyle(.secondary)
                        }
                    }.padding(.vertical, 6)
                }
                Picker("Collection", selection: $store.filter) {
                    ForEach(LibraryFilter.allCases) { Text($0.label).tag($0) }
                }.pickerStyle(.segmented).listRowBackground(Color.clear)
            }
            Section {
                ForEach(store.filteredVerses) { verse in
                    NavigationLink(value: verse.id) { MobileVerseRow(verse: verse) }
                        .swipeActions(edge: .trailing) {
                            Button {
                                store.toggleBookmark(verse.id)
                            } label: {
                                Label(store.preferences.bookmarks.contains(verse.id) ? "Unsave" : "Save", systemImage: "bookmark")
                            }.tint(AppStyle.accent)
                            Button { store.toggleRead(verse.id) } label: {
                                Label(store.preferences.read.contains(verse.id) ? "Unread" : "Read", systemImage: "checkmark")
                            }.tint(.orange)
                        }
                }
                if store.filteredVerses.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No matching verses").font(.headline)
                        Text("Try any included script, a Roman title, a meaning, or a day number.").font(.subheadline).foregroundStyle(.secondary)
                        Button("Clear filters") { store.clearFilters() }
                    }.padding(.vertical, 12)
                }
            } header: { Text("\(store.filteredVerses.count) pasurams") } footer: {
                Text("Swipe a verse to bookmark or mark it read. \(store.preferences.read.count) of 30 read. Progress saves automatically.")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden).background(AppStyle.canvas)
        .navigationTitle("Thiruppavai")
        .searchable(text: $store.query, prompt: "Script, meaning, Roman, or day")
    }
}

@MainActor
struct MobileVerseRow: View {
    @EnvironmentObject private var store: AppStore
    let verse: Verse
    @ScaledMetric(relativeTo: .body) private var tamilSize: CGFloat = 16
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(String(format: "%02d", verse.id)).font(.system(.title3, design: .serif))
                .foregroundStyle(AppStyle.gold).monospacedDigit().frame(minWidth: 28)
            VStack(alignment: .leading, spacing: 7) {
                Text(verse.short).font(AppStyle.tamil(tamilSize)).fixedSize(horizontal: false, vertical: true)
                Text(verse.title).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            VStack(spacing: 8) {
                if store.preferences.bookmarks.contains(verse.id) {
                    Image(systemName: "bookmark.fill").accessibilityLabel("Bookmarked")
                }
                if store.preferences.read.contains(verse.id) {
                    Image(systemName: "checkmark.circle").accessibilityLabel("Read")
                }
            }.font(.caption).foregroundStyle(AppStyle.gold)
        }.padding(.vertical, 9)
    }
}
