import SwiftUI
import SwiftData

struct WeekDetailView: View {
    @Bindable var week: ProgramWeek
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddSession = false

    var body: some View {
        List {
            ForEach(week.sortedSessions) { session in
                NavigationLink(value: session) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.name)
                                .font(.headline)
                            Text("\(session.sortedExercises.count) övningar · \(session.totalMinutes) min")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if session.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color("CompletedColor"))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteSessions)
        }
        .navigationTitle("Vecka \(week.weekNumber)")
        .navigationDestination(for: ProgramSession.self) { session in
            SessionDetailView(session: session)
        }
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
            AddSessionNameView(suggestedName: suggestedSessionName) { name in
                addSession(named: name)
            }
        }
    }

    private var suggestedSessionName: String {
        let letterIndex = week.sessions.count
        if letterIndex < 26, let scalar = UnicodeScalar(65 + letterIndex) {
            return "Pass \(Character(scalar))"
        }
        return "Pass \(letterIndex + 1)"
    }

    private func addSession(named name: String) {
        let session = ProgramSession(name: name, orderIndex: week.sessions.count)
        session.week = week
        week.sessions.append(session)
    }

    private func deleteSessions(at offsets: IndexSet) {
        let sessions = week.sortedSessions
        for index in offsets {
            modelContext.delete(sessions[index])
        }
    }
}
