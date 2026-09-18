import Foundation
import SwiftData

@Model
final class ProgramExercise {
    var id: UUID
    var name: String
    var detail: String
    var durationMinutes: Int
    var orderIndex: Int
    var isCompleted: Bool
    var completedAt: Date?
    var session: ProgramSession?
    var song: Song?

    init(name: String, detail: String = "", durationMinutes: Int, orderIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.detail = detail
        self.durationMinutes = durationMinutes
        self.orderIndex = orderIndex
        self.isCompleted = false
        self.completedAt = nil
    }

    /// The linked song's name if one is set, otherwise the free-text name typed for this exercise.
    var displayName: String {
        song?.name ?? name
    }
}
