import SwiftUI
import SwiftData

@main
struct MusicPracticeApp: App {
    private let container: ModelContainer
    @StateObject private var metronome = MetronomeEngine()

    init() {
        let schema = Schema([
            PracticeSession.self,
            Program.self,
            ProgramWeek.self,
            ProgramSession.self,
            ProgramExercise.self,
        ])
        let configuration = ModelConfiguration(schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Kunde inte skapa ModelContainer: \(error)")
        }
        SeedData.seedIfNeeded(context: container.mainContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(metronome)
        }
        .modelContainer(container)
    }
}
