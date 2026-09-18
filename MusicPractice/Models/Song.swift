import Foundation
import SwiftData

@Model
final class Song {
    var id: UUID
    var name: String
    var genre: String
    var notes: String
    var createdAt: Date

    @Relationship(inverse: \PracticeSession.song)
    var practiceSessions: [PracticeSession] = []

    @Relationship(inverse: \ProgramExercise.song)
    var exercises: [ProgramExercise] = []

    init(name: String, genre: String = "", notes: String = "") {
        self.id = UUID()
        self.name = name
        self.genre = genre
        self.notes = notes
        self.createdAt = .now
    }
}
