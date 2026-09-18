import Foundation
import SwiftData

@Model
final class PracticeSession {
    var date: Date
    var pieceName: String
    var durationMinutes: Int
    var notes: String
    var song: Song?

    init(date: Date = .now, pieceName: String, durationMinutes: Int, notes: String = "") {
        self.date = date
        self.pieceName = pieceName
        self.durationMinutes = durationMinutes
        self.notes = notes
    }

    /// The linked song's name if one is set, otherwise the free-text name typed at log time.
    var displayName: String {
        song?.name ?? pieceName
    }
}
