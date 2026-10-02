import Foundation

public enum LibraryError: LocalizedError {
    case missingResource
    case invalidCollection
    public var errorDescription: String? {
        switch self {
        case .missingResource:
            return "The bundled verse collection is missing. Check the app's Copy Bundle Resources build phase."
        case .invalidCollection:
            return "The verse collection is incomplete or malformed. Restore the original bundled verses.json."
        }
    }
}

public enum BundledLibrary {
    public static func load() throws -> [Verse] {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        guard let url = bundle.url(forResource: "verses", withExtension: "json") else {
            throw LibraryError.missingResource
        }
        return try decode(Data(contentsOf: url))
    }

    public static func decode(_ data: Data) throws -> [Verse] {
        let verses = try JSONDecoder().decode([Verse].self, from: data)
        guard verses.count == 30, Set(verses.map(\.id)) == Set(1...30),
              verses.allSatisfy({ verse in
                  verse.tamilLines.count == 8 && verse.romanLines.count == 8
                  && !verse.title.isEmpty && !verse.meaning.isEmpty
                  && verse.audioURL?.scheme == "https"
                  && verse.audioURL?.host == "ibiblio.org"
                  && verse.sourceURL?.scheme == "https"
                  && verse.sourceURL?.host == "ibiblio.org"
              }) else { throw LibraryError.invalidCollection }
        return verses.sorted { $0.id < $1.id }
    }
}
