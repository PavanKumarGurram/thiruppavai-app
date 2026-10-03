import SwiftUI

@MainActor
struct ReadingSelectors: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Recitation script", selection: $store.preferences.recitationScript) {
                ForEach(RecitationScript.allCases) { Text($0.label).tag($0) }
            }.pickerStyle(.menu)
            Picker("Meaning language", selection: $store.preferences.meaningLanguage) {
                ForEach(MeaningLanguage.allCases) { Text($0.label).tag($0) }
            }.pickerStyle(.menu)
            Text("The same Tamil sounds in another script, not a translated poem. Roman text is unchanged.")
                .font(.caption).foregroundStyle(.secondary)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
struct ReadingSections: View {
    @EnvironmentObject private var store: AppStore
    let verse: Verse
    let textSize: CGFloat
    private var mode: ReadingMode { store.preferences.readingMode }
    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            if mode == .all || mode == .tamil {
                heading("Recitation · \(store.preferences.recitationScript.label)")
                Text(verse.recitation(in: store.preferences.recitationScript))
                    .font(AppStyle.recitation(store.preferences.recitationScript, size: textSize))
                    .lineSpacing(textSize * 0.6).fixedSize(horizontal: false, vertical: true)
                if store.preferences.recitationScript != .tamil {
                    Text("Letter-based pronunciation aid. Tamil sounds and contextual voicing are not fully captured by other scripts; compare the Roman text and a reciter.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            if mode == .all { Divider() }
            if mode == .all || mode == .roman {
                heading("Roman transliteration")
                Text(verse.roman).font(.system(size: textSize, design: .serif))
                    .lineSpacing(10).fixedSize(horizontal: false, vertical: true)
                Text("ā, ī, ū, ē, ō mark long vowels; ḻ is Tamil “zh”. The original Roman transliteration is preserved.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            if mode == .all { Divider() }
            if mode == .all || mode == .meaning {
                heading("Meaning · \(store.preferences.meaningLanguage.label)")
                Text(verse.meaning(in: store.preferences.meaningLanguage))
                    .font(AppStyle.meaning(store.preferences.meaningLanguage, size: textSize))
                    .lineSpacing(9).fixedSize(horizontal: false, vertical: true)
                Text("A concise prose meaning. New language renderings received an AI-assisted review, not human scholarly certification.")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }.textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
    }
    private func heading(_ text: String) -> some View {
        Text(text).font(.headline).foregroundStyle(AppStyle.gold)
    }
}
