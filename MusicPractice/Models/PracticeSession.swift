import Foundation
import SwiftData

@Model
final class PracticeSession {
    var date: Date
    var pieceName: String
    var durationMinutes: Int
    var notes: String

    init(date: Date = .now, pieceName: String, durationMinutes: Int, notes: String = "") {
        self.date = date
        self.pieceName = pieceName
        self.durationMinutes = durationMinutes
        self.notes = notes
    }
}
