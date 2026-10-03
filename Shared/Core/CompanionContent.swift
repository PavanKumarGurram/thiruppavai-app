import Foundation

public enum RecitationScript: String, Codable, CaseIterable, Identifiable {
    case tamil = "ta", telugu = "te", kannada = "kn", malayalam = "ml", devanagari = "hi"
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .tamil: return "தமிழ் · Tamil"
        case .telugu: return "తెలుగు · Telugu"
        case .kannada: return "ಕನ್ನಡ · Kannada"
        case .malayalam: return "മലയാളം · Malayalam"
        case .devanagari: return "देवनागरी · Devanagari"
        }
    }
    public var fontName: String {
        switch self {
        case .tamil: return "NotoSerifTamil-Regular"
        case .telugu: return "NotoSerifTelugu-Regular"
        case .kannada: return "NotoSerifKannada-Regular"
        case .malayalam: return "NotoSerifMalayalam-Regular"
        case .devanagari: return "NotoSerifDevanagari-Regular"
        }
    }
}
public enum MeaningLanguage: String, Codable, CaseIterable, Identifiable {
    case tamil = "ta", telugu = "te", kannada = "kn", malayalam = "ml", english = "en", hindi = "hi"
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .tamil: return "தமிழ் · Tamil"
        case .telugu: return "తెలుగు · Telugu"
        case .kannada: return "ಕನ್ನಡ · Kannada"
        case .malayalam: return "മലയാളം · Malayalam"
        case .english: return "English"
        case .hindi: return "हिन्दी · Hindi"
        }
    }
    public var script: RecitationScript? { RecitationScript(rawValue: rawValue) }
}
public struct LocalizedVerse: Codable {
    public let id: Int
    public let scripts: [String: String]
    public let meanings: [String: String]
}
public struct Recording: Codable {
    public let id: Int
    public let videoID: String
    public let title: String
    public let performer: String
    public let uploader: String
    public let uploaderURL: String
    public let sourceURL: String
    public let selectionNote: String
    public var watchURL: URL? { URL(string: "https://www.youtube.com/watch?v=\(videoID)") }
}
public struct StorySource: Codable, Identifiable {
    public let title: String
    public let url: String
    public var id: String { url }
}
public struct StoryChapter: Codable, Identifiable {
    public let id: Int
    public let title: String
    public let subtitle: String
    public let image: String
    public let caption: String
    public let paragraphs: [String]
    public let sources: [StorySource]
}
public enum CompanionContent {
    private static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
    public static func load<T: Decodable>(_ name: String, as type: T.Type) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json") else { throw LibraryError.missingResource }
        return try JSONDecoder().decode(type, from: Data(contentsOf: url))
    }
    public static let translations = (try? load("readings", as: [LocalizedVerse].self)) ?? []
    public static let recordings = (try? load("recordings", as: [Recording].self)) ?? []
    public static let story = (try? load("story", as: [StoryChapter].self)) ?? []
    public static func validate() throws {
        guard translations.count == 30, recordings.count == 30, story.count >= 8,
              Set(translations.map(\.id)) == Set(1...30),
              Set(recordings.map(\.id)) == Set(1...30),
              translations.allSatisfy({ value in
                  RecitationScript.allCases.allSatisfy { value.scripts[$0.rawValue]?.components(separatedBy: "\n").count == 8 }
                  && MeaningLanguage.allCases.allSatisfy { !(value.meanings[$0.rawValue] ?? "").isEmpty }
              }),
              recordings.allSatisfy({ $0.videoID.range(of: "^[A-Za-z0-9_-]{11}$", options: .regularExpression) != nil })
        else { throw LibraryError.invalidCollection }
    }
}
extension Verse {
    public func recitation(in script: RecitationScript) -> String {
        CompanionContent.translations.first { $0.id == id }?.scripts[script.rawValue] ?? tamil
    }
    public func meaning(in language: MeaningLanguage) -> String {
        CompanionContent.translations.first { $0.id == id }?.meanings[language.rawValue] ?? meaning
    }
    public var recording: Recording? { CompanionContent.recordings.first { $0.id == id } }
    public var additionalSearchText: String {
        guard let entry = CompanionContent.translations.first(where: { $0.id == id }) else { return "" }
        return (Array(entry.scripts.values) + Array(entry.meanings.values)).joined(separator: " ")
    }
}
