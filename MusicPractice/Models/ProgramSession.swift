import Foundation
import SwiftData

@Model
final class ProgramSession {
    var id: UUID
    var name: String
    var orderIndex: Int
    var week: ProgramWeek?

    @Relationship(deleteRule: .cascade, inverse: \ProgramExercise.session)
    var exercises: [ProgramExercise] = []

    init(name: String, orderIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.orderIndex = orderIndex
    }

    var sortedExercises: [ProgramExercise] {
        exercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    var isCompleted: Bool {
        !exercises.isEmpty && exercises.allSatisfy(\.isCompleted)
    }

    var totalMinutes: Int {
        exercises.reduce(0) { $0 + $1.durationMinutes }
    }
}
