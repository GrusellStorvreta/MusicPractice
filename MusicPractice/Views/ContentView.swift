import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ProgramListView()
                .tabItem {
                    Label("Program", systemImage: "list.bullet.rectangle.portrait")
                }
            SongListView()
                .tabItem {
                    Label("Låtar", systemImage: "music.quarternote.3")
                }
            MetronomeView()
                .tabItem {
                    Label("Metronom", systemImage: "metronome.fill")
                }
            QuickLogView()
                .tabItem {
                    Label("Snabblogg", systemImage: "note.text")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [PracticeSession.self, Program.self, ProgramWeek.self, ProgramSession.self, ProgramExercise.self, Song.self],
            inMemory: true
        )
}
