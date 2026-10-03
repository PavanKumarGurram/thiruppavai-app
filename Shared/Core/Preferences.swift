import Foundation

public enum Appearance: String, Codable, CaseIterable, Identifiable {
    case system, light, dark
    public var id: String { rawValue }
    public var label: String { rawValue.capitalized }
}

public enum ReadingMode: String, Codable, CaseIterable, Identifiable {
    case all, tamil, roman, meaning
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .all: return "All"
        case .tamil: return "Recitation"
        case .roman: return "Roman"
        case .meaning: return "Meaning"
        }
    }
}

public struct ReadingPreferences: Codable, Equatable {
    public var schemaVersion = 1
    public var bookmarks: Set<Int> = []
    public var read: Set<Int> = []
    public var appearance: Appearance = .system
    public var fontSize: Double = 20
    public var readingMode: ReadingMode = .all
    public var playbackRate: Double = 1
    public var volume: Double = 0.85
    public var lastVerseID: Int = 0
    public var recitationScript: RecitationScript = .tamil
    public var meaningLanguage: MeaningLanguage = .english

    public init() {}
    private enum CodingKeys: String, CodingKey {
        case schemaVersion, bookmarks, read, appearance, fontSize, readingMode
        case playbackRate, volume, lastVerseID, recitationScript, meaningLanguage
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try c.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        bookmarks = try c.decodeIfPresent(Set<Int>.self, forKey: .bookmarks) ?? []
        read = try c.decodeIfPresent(Set<Int>.self, forKey: .read) ?? []
        appearance = try c.decodeIfPresent(Appearance.self, forKey: .appearance) ?? .system
        fontSize = try c.decodeIfPresent(Double.self, forKey: .fontSize) ?? 20
        readingMode = try c.decodeIfPresent(ReadingMode.self, forKey: .readingMode) ?? .all
        playbackRate = try c.decodeIfPresent(Double.self, forKey: .playbackRate) ?? 1
        volume = try c.decodeIfPresent(Double.self, forKey: .volume) ?? 0.85
        lastVerseID = try c.decodeIfPresent(Int.self, forKey: .lastVerseID) ?? 0
        recitationScript = try c.decodeIfPresent(RecitationScript.self, forKey: .recitationScript) ?? .tamil
        meaningLanguage = try c.decodeIfPresent(MeaningLanguage.self, forKey: .meaningLanguage) ?? .english
    }

    public mutating func normalize() {
        bookmarks = bookmarks.intersection(Set(1...30))
        read = read.intersection(Set(1...30))
        fontSize = fontSize.isFinite ? min(32, max(16, fontSize)) : 20
        volume = volume.isFinite ? min(1, max(0, volume)) : 0.85
        if ![0.75, 1.0, 1.25, 1.5].contains(playbackRate) { playbackRate = 1 }
        if !(0...30).contains(lastVerseID) { lastVerseID = 0 }
    }

    public mutating func mergeMarks(from other: ReadingPreferences) {
        bookmarks.formUnion(other.bookmarks)
        read.formUnion(other.read)
        normalize()
    }
}

public enum BackupError: LocalizedError {
    case unsupportedVersion
    case tooLarge
    public var errorDescription: String? {
        switch self {
        case .unsupportedVersion: return "This reading backup uses an unsupported format version."
        case .tooLarge: return "This file is too large to be a reading backup. Choose an exported Thiruppavai JSON backup."
        }
    }
}

public final class PreferencesStore {
    private let defaults: UserDefaults
    private let key = "thiruppavai.reading.v1"
    public init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    public func load() -> (preferences: ReadingPreferences, recovered: Bool) {
        guard let data = defaults.data(forKey: key) else { return (ReadingPreferences(), false) }
        do { return (try Self.decode(data), false) }
        catch {
            // Preserve the original bytes instead of silently destroying a bad or future-format save.
            defaults.set(data, forKey: key + ".unreadable-backup")
            return (ReadingPreferences(), true)
        }
    }

    public func save(_ preferences: ReadingPreferences) throws {
        defaults.set(try Self.encode(preferences), forKey: key)
    }
    public static func encode(_ preferences: ReadingPreferences) throws -> Data {
        var normalized = preferences
        normalized.normalize()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(normalized)
    }
    public static func decode(_ data: Data) throws -> ReadingPreferences {
        guard data.count <= 1_048_576 else { throw BackupError.tooLarge }
        var value = try JSONDecoder().decode(ReadingPreferences.self, from: data)
        guard value.schemaVersion == 1 else { throw BackupError.unsupportedVersion }
        value.normalize()
        return value
    }
}
