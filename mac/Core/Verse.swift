import Foundation

public struct Verse: Codable, Identifiable, Hashable {
    public let id: Int
    public let tamil: String
    public let roman: String
    public let title: String
    public let theme: String
    public let meaning: String
    public let short: String
    public let audio: String
    public let audioPage: String

    public var audioURL: URL? { URL(string: audio) }
    public var sourceURL: URL? { URL(string: audioPage) }
    public var tamilLines: [String] { tamil.components(separatedBy: "\n") }
    public var romanLines: [String] { roman.components(separatedBy: "\n") }
    public var calendarLabel: String {
        id <= 16 ? "December \(id + 15)" : "January \(id - 16)"
    }
    public var chapter: String {
        switch id {
        case 1...5: return "The invitation"
        case 6...15: return "Awakening the companions"
        case 16...23: return "At the Lord's doorway"
        default: return "Praise and surrender"
        }
    }
    public var searchText: String {
        [title, theme, tamil, roman, meaning].joined(separator: " ").searchFolded
    }
}

public enum LibraryFilter: String, CaseIterable, Identifiable, Codable {
    case all, bookmarked, unread
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .all: return "All"
        case .bookmarked: return "Saved"
        case .unread: return "Unread"
        }
    }
}

public enum VerseSearch {
    public static func filter(
        _ verses: [Verse], query: String, filter: LibraryFilter,
        bookmarks: Set<Int>, read: Set<Int>
    ) -> [Verse] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines).searchFolded
        let numeric = !term.isEmpty && term.allSatisfy(\.isNumber)
        return verses.filter { verse in
            let included = filter == .all
                || (filter == .bookmarked && bookmarks.contains(verse.id))
                || (filter == .unread && !read.contains(verse.id))
            let matches = term.isEmpty
                || (numeric ? Int(term) == verse.id : verse.searchText.contains(term))
            return included && matches
        }
    }
}

private extension String {
    var searchFolded: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive],
                locale: Locale(identifier: "en_US_POSIX"))
    }
}
