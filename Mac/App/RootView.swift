import AppKit
import Combine
import SwiftUI

@MainActor
struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var audio: AudioController
    @State private var visibility: NavigationSplitViewVisibility = .all
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 250, ideal: 280, max: 370)
        } detail: {
            Group {
                if let error = store.libraryError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.book.closed").font(.largeTitle)
                        Text("The collection could not be opened").font(.title2)
                        Text(error).foregroundStyle(.secondary).textSelection(.enabled)
                    }.padding(40).frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let verse = store.selectedVerse {
                    ReaderView(verse: verse).id(verse.id)
                } else {
                    HomeView()
                }
            }
            .background(AppStyle.canvas)
            .toolbar {
                ToolbarItemGroup {
                    Button { store.showToday() } label: { Label("Today's verse", systemImage: "sun.max") }
                        .help("Today's verse (⌘T)")
                    if let verse = store.selectedVerse {
                        Button { store.toggleBookmark(verse.id) } label: {
                            Label(store.preferences.bookmarks.contains(verse.id) ? "Remove bookmark" : "Bookmark",
                                  systemImage: store.preferences.bookmarks.contains(verse.id) ? "bookmark.fill" : "bookmark")
                        }.help("Toggle bookmark (⌘D)")
                    }
                    Menu {
                        Picker("Appearance", selection: $store.preferences.appearance) {
                            ForEach(Appearance.allCases) { Text($0.label).tag($0) }
                        }
                    } label: { Image(systemName: "circle.lefthalf.filled") }
                    .help("Appearance").accessibilityLabel("Appearance")
                    Button { store.showAbout = true } label: { Label("About and reading guide", systemImage: "info.circle") }
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 860, minHeight: 620)
        .onAppear { syncAudio() }
        .onChange(of: store.selectedID) { _ in syncAudio() }
        .onChange(of: store.preferences.playbackRate) { _ in configureAudio() }
        .onChange(of: store.preferences.volume) { _ in configureAudio() }
        .onReceive(clock) { store.now = $0 }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            store.now = Date()
        }
        .onReceive(NotificationCenter.default.publisher(for: .focusVerseSearch)) { _ in
            visibility = .all
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            store.persist(); audio.stop()
        }
        .sheet(isPresented: $store.showAbout) { AboutView() }
        .sheet(isPresented: $store.showStory) { AndalStoryView() }
        .onChange(of: store.showAbout) { _ in if store.showAbout { audio.pause() } }
        .onChange(of: store.showStory) { _ in if store.showStory { audio.pause() } }
        .alert("Thiruppavai", isPresented: Binding(
            get: { store.notice != nil }, set: { if !$0 { store.notice = nil } }
        )) {
            Button("OK", role: .cancel) { store.notice = nil }
        } message: { Text(store.notice ?? "") }
    }
    private func syncAudio() {
        audio.select(store.selectedVerse)
        configureAudio()
    }
    private func configureAudio() {
        audio.configure(rate: store.preferences.playbackRate, volume: store.preferences.volume)
    }
}

@MainActor
struct SidebarView: View {
    @EnvironmentObject private var store: AppStore
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                GarlandMark().frame(width: 30, height: 36)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Thiruppavai").font(.system(size: 20, design: .serif))
                    Text("ANDAL'S SACRED VERSES").font(.system(size: 9, weight: .medium)).tracking(1)
                        .foregroundStyle(AppStyle.secondary)
                }
                Spacer(minLength: 0)
            }.padding(20)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(AppStyle.secondary)
                TextField("Search verses", text: $store.query)
                    .textFieldStyle(.plain).focused($searchFocused)
                    .accessibilityLabel("Search any included script, meaning, transliteration, or day number")
                if !store.query.isEmpty {
                    Button { store.query = "" } label: { Image(systemName: "xmark.circle.fill") }
                        .buttonStyle(.plain).accessibilityLabel("Clear search")
                }
            }
            .padding(10).background(AppStyle.panel, in: RoundedRectangle(cornerRadius: 7))
            .padding(.horizontal, 16).padding(.bottom, 14)

            Picker("Collection filter", selection: $store.filter) {
                ForEach(LibraryFilter.allCases) { Text($0.label).tag($0) }
            }.pickerStyle(.segmented).padding(.horizontal, 16).padding(.bottom, 12)

            List(selection: $store.selectedID) {
                Label("Home & daily verse", systemImage: "sun.max").tag(0)
                    .padding(.vertical, 5)
                Section {
                    ForEach(store.filteredVerses) { verse in
                        HStack(alignment: .top, spacing: 11) {
                            Text(String(format: "%02d", verse.id))
                                .font(.system(size: 15, design: .serif)).foregroundStyle(AppStyle.gold)
                                .frame(width: 25).padding(.top, 2)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(verse.short).font(AppStyle.tamil(12)).lineLimit(2)
                                Text(verse.title).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
                            }
                            Spacer(minLength: 0)
                            if store.preferences.read.contains(verse.id) {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .semibold))
                                    .accessibilityLabel("Read")
                            }
                            if store.preferences.bookmarks.contains(verse.id) {
                                Image(systemName: "bookmark.fill").font(.system(size: 10))
                                    .foregroundStyle(AppStyle.gold).accessibilityLabel("Bookmarked")
                            }
                        }
                        .padding(.vertical, 8).tag(verse.id)
                        .contextMenu {
                            Button(store.preferences.bookmarks.contains(verse.id) ? "Remove bookmark" : "Bookmark") {
                                store.toggleBookmark(verse.id)
                            }
                            Button(store.preferences.read.contains(verse.id) ? "Mark unread" : "Mark as read") {
                                store.toggleRead(verse.id)
                            }
                        }
                    }
                    if store.filteredVerses.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("No matching verses").font(.callout)
                            Button("Clear filters") { store.clearFilters() }.buttonStyle(.link)
                        }.padding(.vertical, 12)
                    }
                } header: {
                    Text("\(store.filteredVerses.count) PASURAMS").font(.system(size: 10, weight: .medium))
                }
            }
            .listStyle(.sidebar).scrollContentBackground(.hidden)
            Divider()
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text("\(store.preferences.read.count) of 30 read")
                    Spacer()
                    Text("\(store.preferences.bookmarks.count) saved")
                }.font(.system(size: 11)).foregroundStyle(AppStyle.secondary)
                ProgressView(value: Double(store.preferences.read.count), total: 30)
                    .accessibilityLabel("Reading progress")
                Text("Your reading progress saves automatically.")
                    .font(.system(size: 10)).foregroundStyle(AppStyle.secondary)
            }.padding(18)
        }
        .background(AppStyle.canvas)
        .onReceive(NotificationCenter.default.publisher(for: .focusVerseSearch)) { _ in
            DispatchQueue.main.async { searchFocused = true }
        }
    }
}
