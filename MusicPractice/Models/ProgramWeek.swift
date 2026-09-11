import Foundation
import SwiftData

@Model
final class ProgramWeek {
    var id: UUID
    var weekNumber: Int
    var program: Program?

    @Relationship(deleteRule: .cascade, inverse: \ProgramSession.week)
    var sessions: [ProgramSession] = []

    init(weekNumber: Int) {
        self.id = UUID()
        self.weekNumber = weekNumber
    }

    var sortedSessions: [ProgramSession] {
        sessions.sorted { $0.orderIndex < $1.orderIndex }
    }

    var isCompleted: Bool {
        !sessions.isEmpty && sessions.allSatisfy(\.isCompleted)
    }
}
