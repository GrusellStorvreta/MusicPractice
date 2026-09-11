import SwiftUI
import SwiftData

@main
struct MusicPracticeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PracticeSession.self)
    }
}
