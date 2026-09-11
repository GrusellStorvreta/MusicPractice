import Foundation
import SwiftData

enum SeedData {
    private struct ExerciseSeed {
        let name: String
        let detail: String
        let minutes: Int
    }

    private struct SessionSeed {
        let name: String
        let exercises: [ExerciseSeed]
    }

    private struct WeekSeed {
        let week: Int
        let sessions: [SessionSeed]
    }

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Program>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        let program = Program(
            name: "Irish tunes – 8 veckor",
            notes: "Två pass i veckan, 30 minuter per pass."
        )
        context.insert(program)

        for weekSeed in weeks {
            let week = ProgramWeek(weekNumber: weekSeed.week)
            week.program = program
            program.weeks.append(week)

            for (sessionIndex, sessionSeed) in weekSeed.sessions.enumerated() {
                let session = ProgramSession(name: sessionSeed.name, orderIndex: sessionIndex)
                session.week = week
                week.sessions.append(session)

                for (exerciseIndex, exerciseSeed) in sessionSeed.exercises.enumerated() {
                    let exercise = ProgramExercise(
                        name: exerciseSeed.name,
                        detail: exerciseSeed.detail,
                        durationMinutes: exerciseSeed.minutes,
                        orderIndex: exerciseIndex
                    )
                    exercise.session = session
                    session.exercises.append(exercise)
                }
            }
        }
    }

    private static let weeks: [WeekSeed] = [
        WeekSeed(week: 1, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie", detail: "melodi", minutes: 10),
                ExerciseSeed(name: "Blackthorn Stick", detail: "melodi", minutes: 10),
                ExerciseSeed(name: "Drowsy Maggie", detail: "playalong", minutes: 10),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Rocky Road", detail: "spela igenom långsamt", minutes: 10),
                ExerciseSeed(name: "Little Beggarman", detail: "sång + komp", minutes: 10),
                ExerciseSeed(name: "Carlow", detail: "spela melodin utan noter", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 2, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie", detail: "playalong", minutes: 15),
                ExerciseSeed(name: "Blackthorn Stick", detail: "playalong", minutes: 15),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Rocky Road", detail: "fokusera på svåra övergångar", minutes: 10),
                ExerciseSeed(name: "Little Beggarman", detail: "håll jämnt tempo genom hela låten", minutes: 10),
                ExerciseSeed(name: "Carlow", detail: "spela endast ackord/komp", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 3, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie", detail: "melodi", minutes: 10),
                ExerciseSeed(name: "Drowsy Maggie", detail: "komp", minutes: 10),
                ExerciseSeed(name: "Drowsy Maggie", detail: "playalong", minutes: 10),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Rocky Road", detail: "sjung med inspelning", minutes: 10),
                ExerciseSeed(name: "Little Beggarman", detail: "sjung utan att titta på texten", minutes: 10),
                ExerciseSeed(name: "Carlow", detail: "växla melodi/komp mellan verserna", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 4, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Blackthorn Stick", detail: "melodi", minutes: 10),
                ExerciseSeed(name: "Blackthorn Stick", detail: "komp", minutes: 10),
                ExerciseSeed(name: "Blackthorn Stick", detail: "playalong", minutes: 10),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Rocky Road", detail: "spela och sjung hela låten utan stopp", minutes: 10),
                ExerciseSeed(name: "Little Beggarman", detail: "testa olika komprytmer", minutes: 10),
                ExerciseSeed(name: "Carlow", detail: "spela med Youtube-version", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 5, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie → Blackthorn Stick", detail: "som set", minutes: 20),
                ExerciseSeed(name: "Svår passage", detail: "", minutes: 10),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Little Beggarman → Carlow → Rocky Road", detail: "som set", minutes: 20),
                ExerciseSeed(name: "Svagaste övergången", detail: "identifiera och repetera", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 6, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie + Blackthorn Stick", detail: "med Youtube", minutes: 30),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Rocky Road", detail: "bara sång + komp", minutes: 10),
                ExerciseSeed(name: "Little Beggarman", detail: "spela till inspelning", minutes: 10),
                ExerciseSeed(name: "Carlow", detail: "spela till inspelning", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 7, sessions: [
            SessionSeed(name: "Pub-pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie → Blackthorn Stick", detail: "3 gånger utan stopp", minutes: 30),
            ]),
            SessionSeed(name: "Pub-pass B", exercises: [
                ExerciseSeed(name: "Hela sångsetet", detail: "utan stopp", minutes: 20),
                ExerciseSeed(name: "Svagaste låten", detail: "spela om den", minutes: 10),
            ]),
        ]),
        WeekSeed(week: 8, sessions: [
            SessionSeed(name: "Pass A", exercises: [
                ExerciseSeed(name: "Drowsy Maggie + Blackthorn Stick", detail: "spela in", minutes: 30),
            ]),
            SessionSeed(name: "Pass B", exercises: [
                ExerciseSeed(name: "Little Beggarman, Carlow, Rocky Road", detail: "spela in", minutes: 20),
                ExerciseSeed(name: "Lyssna igenom", detail: "anteckna 3 saker att förbättra", minutes: 10),
            ]),
        ]),
    ]
}
