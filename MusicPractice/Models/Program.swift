import Foundation
import SwiftData

@Model
final class Program {
    var id: UUID
    var name: String
    var notes: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ProgramWeek.program)
    var weeks: [ProgramWeek] = []

    init(name: String, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.notes = notes
        self.createdAt = .now
    }

    var sortedWeeks: [ProgramWeek] {
        weeks.sorted { $0.weekNumber < $1.weekNumber }
    }

    var nextWeekNumber: Int {
        (weeks.map(\.weekNumber).max() ?? 0) + 1
    }
}
