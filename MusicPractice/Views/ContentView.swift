import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PracticeSession.date, order: .reverse) private var sessions: [PracticeSession]

    @State private var isPresentingAddSession = false

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "Inga övningspass ännu",
                        systemImage: "music.note",
                        description: Text("Tryck på + för att logga ditt första pass.")
                    )
                } else {
                    List {
                        ForEach(sessions) { session in
                            SessionRow(session: session)
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("Övningslogg")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddSession = true
                    } label: {
                        Label("Nytt pass", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddSession) {
                AddSessionView()
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}

private struct SessionRow: View {
    let session: PracticeSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.pieceName)
                .font(.headline)
            HStack {
                Text(session.date, style: .date)
                Text("·")
                Text("\(session.durationMinutes) min")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PracticeSession.self, inMemory: true)
}
