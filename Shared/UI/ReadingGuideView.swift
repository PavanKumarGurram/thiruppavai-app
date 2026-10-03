import SwiftUI

@MainActor
struct ReadingGuideView: View {
    @State private var showPrivacy = false
    @State private var showNotices = false
    private var notices: String {
        guard let url = Bundle.main.url(forResource: "Notices", withExtension: "md") else { return "See Shared/Resources/Notices.md." }
        return (try? String(contentsOf: url, encoding: .utf8)) ?? "Notices could not be opened."
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DevotionalArtwork(name: "andal-krishna-hero", caption: "Original AI-generated devotional illustration")
                Text("A garland of thirty · Edition 1.1").font(.system(.title2, design: .serif))
                section("One Tamil poem, several reading scripts",
                        "Tamil is the original text. Telugu, Kannada, Malayalam and Devanagari are letter-based renderings of those Tamil words, not translations of the verses. The Roman transliteration is unchanged. Script conversion cannot fully express contextual Tamil pronunciation; listen to a reciter and compare Roman letters when a distinction is unclear.")
                section("Some less familiar letters",
                        "Tamil ழ (ḻ, “zh”) is represented as Telugu ఴ, Kannada ೞ, Malayalam ഴ and Devanagari ऴ. Tamil ற uses ఱ / ಱ / റ / ऱ. Tamil ன uses the regular n in Telugu/Kannada, but ഩ / ऩ in Malayalam/Devanagari. Short e/o in Devanagari use ऎ/ऒ and ॆ/ॊ. These extended characters preserve distinctions but may be unfamiliar to everyday readers.")
                section("Roman pronunciation guide",
                        "ā, ī, ū, ē, ō mark long vowels. ṭ, ṇ, ḷ are retroflex; ḻ is Tamil “zh”; ṟ is the strong r; ṉ distinguishes ன from ந (n). c represents ச and t represents த. Consonant voicing depends on context: the text is letter-based, not a complete phonetic transcription.")
                section("Meanings in six languages",
                        "English meanings are the original concise prose renderings. Tamil, Telugu, Kannada, Malayalam and Hindi meanings are AI-assisted translations with a second AI-assisted editorial pass. They have not been certified by a human Tamil scholar or fluent reviewers in every language. Review them before scholarly or public use; they do not replace traditional commentary.")
                section("Andal's illustrated story",
                        "The ten chapters retell devotional tradition and link their sources. Sacred dreams and divine union are not represented as documented historical events. All app illustrations were generated for this edition and are labelled AI-generated; none were copied from the YouTube thumbnails.")
                section("Calendar",
                        "December 16–January 14 is the requested fixed Margazhi convention, using the device's local date. Actual Tamil-calendar dates can vary. Outside the window, a labelled daily reflection rotates through the pasurams.")
                VStack(alignment: .leading, spacing: 12) {
                    Text("Text and recording sources").font(.headline)
                    Link("Project Madurai edition at Tamilnation", destination: URL(string: "https://tamilnation.org/sathyam/east/pirapantam/mp005baandaal")!)
                    Link("Tamil Wikisource", destination: URL(string: "https://ta.wikisource.org/wiki/திருப்பாவை")!)
                    Link("P. R. Ramachander's English translation", destination: URL(string: "https://www.hindupedia.com/en/Thiruppavai")!)
                    Link("M. L. Vasanthakumari playlist · Madhura Gaanam", destination: URL(string: "https://www.youtube.com/playlist?list=PLt2zzA2YA6ym01dYhVHUGZ1EemZO6-z1-")!)
                }
                Button("YouTube privacy, terms & credits") { showPrivacy = true }.buttonStyle(.bordered)
                DisclosureGroup("Full text provenance and font licenses", isExpanded: $showNotices) {
                    Text(notices).font(.caption).textSelection(.enabled).padding(.top, 12)
                }
            }.padding(24).frame(maxWidth: 850).frame(maxWidth: .infinity, alignment: .leading)
        }.background(AppStyle.canvas)
        .sheet(isPresented: $showPrivacy) { YouTubePrivacyView() }
    }
    private func section(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            Text(text).font(.body).foregroundStyle(.secondary).lineSpacing(4).textSelection(.enabled)
        }
    }
}
