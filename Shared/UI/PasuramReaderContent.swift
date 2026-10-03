import SwiftUI

@MainActor
struct PasuramReaderContent: View {
    @EnvironmentObject private var store: AppStore
    let verse: Verse
    let textSize: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 12) {
                Text("PASURAM \(String(format: "%02d", verse.id)) / 30 · \(verse.calendarLabel.uppercased())")
                    .font(.caption.weight(.semibold)).foregroundStyle(AppStyle.gold)
                Text(verse.short).font(AppStyle.tamil(textSize * 1.25))
                    .lineSpacing(8).fixedSize(horizontal: false, vertical: true)
                Text(verse.title).font(.system(.title2, design: .serif)).foregroundStyle(.secondary)
                Text(verse.theme).font(.subheadline).foregroundStyle(.secondary)
            }
            HStack {
                Picker("Sections", selection: $store.preferences.readingMode) {
                    ForEach(ReadingMode.allCases) { Text($0.label).tag($0) }
                }.pickerStyle(.menu)
                Spacer(minLength: 12)
                Menu {
                    Button("Larger text") { store.resizeText(2) }.disabled(store.preferences.fontSize >= 32)
                    Button("Smaller text") { store.resizeText(-2) }.disabled(store.preferences.fontSize <= 16)
                    Button("Reset size") { store.preferences.fontSize = 20 }
                } label: { Image(systemName: "textformat.size").frame(minWidth: 44, minHeight: 44) }
                    .accessibilityLabel("Adjust text size")
            }
            ReadingSelectors()
            YouTubePlayerSection(verse: verse)
            ReadingSections(verse: verse, textSize: textSize)
                .padding(22)
                .background(AppStyle.panel, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppStyle.rule, lineWidth: 1))
            Button { store.toggleRead(verse.id) } label: {
                Label(store.preferences.read.contains(verse.id) ? "Read · mark unread" : "Mark as read",
                      systemImage: store.preferences.read.contains(verse.id) ? "checkmark.circle.fill" : "circle")
                    .frame(maxWidth: .infinity).padding(.vertical, 8)
            }.buttonStyle(.borderedProminent).controlSize(.large)
            HStack {
                Button { store.go(-1) } label: { Label("Previous", systemImage: "chevron.left") }
                    .disabled(verse.id == 1).frame(minHeight: 44)
                Spacer()
                Button { store.go(1) } label: { Label("Next", systemImage: "chevron.right") }
                    .disabled(verse.id == 30).frame(minHeight: 44)
            }.font(.headline)
            Text("Bookmarks, read marks, script and meaning preferences save automatically.")
                .font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
