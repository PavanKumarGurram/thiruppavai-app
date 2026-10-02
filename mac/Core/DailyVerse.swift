import Foundation

public struct DailyVerse: Equatable {
    public let verseID: Int
    public let margazhiDay: Int?
    public var isMargazhi: Bool { margazhiDay != nil }
    public var label: String {
        margazhiDay.map { "Margazhi · Day \($0)" } ?? "A daily reflection · Outside Margazhi"
    }

    /// Fixed December 16–January 14 convention requested for this app.
    /// Calendar components, not elapsed hours, keep DST and timezone changes safe.
    public static func resolve(on date: Date, timeZone: TimeZone = .current) -> DailyVerse {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.month, .day], from: date)
        if parts.month == 12, let day = parts.day, day >= 16 {
            return DailyVerse(verseID: day - 15, margazhiDay: day - 15)
        }
        if parts.month == 1, let day = parts.day, day <= 14 {
            return DailyVerse(verseID: day + 16, margazhiDay: day + 16)
        }
        let ordinal = (calendar.ordinality(of: .day, in: .year, for: date) ?? 1) - 1
        return DailyVerse(verseID: ordinal % 30 + 1, margazhiDay: nil)
    }
}
