import Foundation
import XCTest
@testable import ThiruppavaiCore

final class CalendarTests: XCTestCase {
    private let utc = TimeZone(secondsFromGMT: 0)!
    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
    func testEveryDayAcrossYearBoundary() {
        for day in 16...31 {
            XCTAssertEqual(DailyVerse.resolve(on: date(2026, 12, day), timeZone: utc).margazhiDay, day - 15)
        }
        for day in 1...14 {
            XCTAssertEqual(DailyVerse.resolve(on: date(2027, 1, day), timeZone: utc).margazhiDay, day + 16)
        }
    }
    func testOutsideWindowAndLeapDay() {
        XCTAssertNil(DailyVerse.resolve(on: date(2026, 12, 15), timeZone: utc).margazhiDay)
        XCTAssertNil(DailyVerse.resolve(on: date(2027, 1, 15), timeZone: utc).margazhiDay)
        XCTAssertEqual(DailyVerse.resolve(on: date(2028, 2, 29), timeZone: utc).verseID, 30)
        for month in 1...12 {
            XCTAssertTrue((1...30).contains(DailyVerse.resolve(on: date(2026, month, 15), timeZone: utc).verseID))
        }
    }
    func testDeviceTimezoneDecidesDate() {
        let instant = date(2026, 12, 16, hour: 2)
        let la = TimeZone(identifier: "America/Los_Angeles")!
        let chennai = TimeZone(identifier: "Asia/Kolkata")!
        XCTAssertFalse(DailyVerse.resolve(on: instant, timeZone: la).isMargazhi)
        XCTAssertEqual(DailyVerse.resolve(on: instant, timeZone: chennai).margazhiDay, 1)
    }
}

final class CollectionTests: XCTestCase {
    func testCompanionCollectionAndLanguageCoverage() throws {
        try CompanionContent.validate()
        let verses = try BundledLibrary.load()
        for verse in verses {
            for script in RecitationScript.allCases {
                XCTAssertEqual(verse.recitation(in: script).components(separatedBy: "\n").count, 8)
            }
            XCTAssertEqual(verse.recitation(in: .tamil), verse.tamil)
            XCTAssertEqual(verse.meaning(in: .english), verse.meaning)
            XCTAssertNotNil(verse.recording?.watchURL)
        }
        XCTAssertEqual(CompanionContent.story.count, 10)
        XCTAssertTrue(VerseSearch.filter(verses, query: "नारायण", filter: .all, bookmarks: [], read: []).contains { $0.id == 1 })
    }
    func testBundledCollection() throws {
        let verses = try BundledLibrary.load()
        XCTAssertEqual(verses.map(\.id), Array(1...30))
        for verse in verses {
            XCTAssertEqual(verse.tamilLines.count, 8)
            XCTAssertEqual(verse.romanLines.count, 8)
            XCTAssertTrue(verse.meaning.count > 150)
            XCTAssertTrue(verse.audio.hasSuffix(String(format: "temple_%02d.mp3", verse.id)))
            XCTAssertTrue(verse.audioPage.hasSuffix(String(format: "vstp%02d.html", verse.id)))
        }
        XCTAssertEqual(verses[15].calendarLabel, "December 31")
        XCTAssertEqual(verses[16].calendarLabel, "January 1")
        XCTAssertEqual(verses[29].calendarLabel, "January 14")
    }
    func testSearchAndFilters() throws {
        let verses = try BundledLibrary.load()
        func find(_ query: String, _ filter: LibraryFilter = .all) -> [Verse] {
            VerseSearch.filter(verses, query: query, filter: filter, bookmarks: [1, 29], read: [1])
        }
        XCTAssertEqual(find("03").map(\.id), [3])
        XCTAssertEqual(find("999").count, 0)
        XCTAssertTrue(find("மார்கழி").contains { $0.id == 1 })
        XCTAssertTrue(find("mārkaḻi").contains { $0.id == 1 })
        XCTAssertTrue(find("markali").contains { $0.id == 1 })
        XCTAssertFalse(find("lotus").isEmpty)
        XCTAssertEqual(find("", .bookmarked).map(\.id), [1, 29])
        XCTAssertEqual(find("", .unread).count, 29)
        XCTAssertEqual(find("Margazhi", .unread).contains { $0.id == 1 }, false)
    }
    func testMissingVerseRejected() throws {
        var verses = try BundledLibrary.load()
        verses.removeLast()
        XCTAssertThrowsError(try BundledLibrary.decode(JSONEncoder().encode(verses)))
    }
    func testDuplicateVerseRejected() throws {
        var verses = try BundledLibrary.load()
        verses[29] = verses[0]
        XCTAssertThrowsError(try BundledLibrary.decode(JSONEncoder().encode(verses)))
    }
}

final class PreferenceTests: XCTestCase {
    func testOldBackupPreservesMarksAndGetsLanguageDefaults() throws {
        let old = """
        {"schemaVersion":1,"bookmarks":[1,30],"read":[2],"appearance":"dark","fontSize":24,"readingMode":"tamil","playbackRate":1.25,"volume":0.7,"lastVerseID":15}
        """
        let value = try PreferencesStore.decode(Data(old.utf8))
        XCTAssertEqual(value.bookmarks, [1,30])
        XCTAssertEqual(value.read, [2])
        XCTAssertEqual(value.appearance, .dark)
        XCTAssertEqual(value.lastVerseID, 15)
        XCTAssertEqual(value.recitationScript, .tamil)
        XCTAssertEqual(value.meaningLanguage, .english)
    }
    func testLanguagePreferencesRoundTrip() throws {
        var value = ReadingPreferences()
        value.recitationScript = .malayalam
        value.meaningLanguage = .hindi
        XCTAssertEqual(try PreferencesStore.decode(PreferencesStore.encode(value)), value)
    }
    func testRoundTripAndNormalization() throws {
        var value = ReadingPreferences()
        value.bookmarks = [-1, 1, 29, 31]
        value.read = [2, 3]
        value.fontSize = 100
        value.volume = -1
        value.lastVerseID = 999
        value.playbackRate = 4
        let restored = try PreferencesStore.decode(PreferencesStore.encode(value))
        XCTAssertEqual(restored.bookmarks, [1, 29])
        XCTAssertEqual(restored.read, [2, 3])
        XCTAssertEqual(restored.fontSize, 32)
        XCTAssertEqual(restored.volume, 0)
        XCTAssertEqual(restored.playbackRate, 1)
        XCTAssertEqual(restored.lastVerseID, 0)
    }
    func testDefaultsPersistenceAndRecovery() throws {
        let name = "ThiruppavaiTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let store = PreferencesStore(defaults: defaults)
        var value = ReadingPreferences()
        value.bookmarks = [7, 30]
        value.appearance = .dark
        try store.save(value)
        XCTAssertEqual(store.load().preferences, value)
        defaults.set(Data("broken".utf8), forKey: "thiruppavai.reading.v1")
        XCTAssertTrue(store.load().recovered)
        XCTAssertNotNil(defaults.data(forKey: "thiruppavai.reading.v1.unreadable-backup"))
    }
    func testFutureFormatAndOversizedFileRejected() throws {
        var value = ReadingPreferences()
        value.schemaVersion = 99
        XCTAssertThrowsError(try PreferencesStore.decode(PreferencesStore.encode(value)))
        XCTAssertThrowsError(try PreferencesStore.decode(Data(repeating: 0, count: 1_048_577)))
    }
    func testImportMergesMarksWithoutChangingStyle() {
        var original = ReadingPreferences()
        original.bookmarks = [1]
        original.appearance = .dark
        var imported = ReadingPreferences()
        imported.bookmarks = [2, 30]
        imported.read = [3]
        original.mergeMarks(from: imported)
        XCTAssertEqual(original.bookmarks, [1, 2, 30])
        XCTAssertEqual(original.read, [3])
        XCTAssertEqual(original.appearance, .dark)
    }
}
