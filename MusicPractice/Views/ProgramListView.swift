import SwiftUI
import SwiftData

struct ProgramListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Program.createdAt) private var programs: [Program]
    @State private var isPresentingAddProgram = false

    var body: some View {
        NavigationStack {
            Group {
                if programs.isEmpty {
                    ContentUnavailableView(
                        "Inga program ännu",
                        systemImage: "list.bullet.rectangle.portrait",
                        description: Text("Tryck på + för att skapa ett träningsprogram.")
                    )
                } else {
                    List {
                        ForEach(programs) { program in
                            NavigationLink(value: program) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(program.name)
                                        .font(.headline)
                                    Text("\(program.weeks.count) veckor")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deletePrograms)
                    }
                }
            }
            .navigationTitle("Program")
            .navigationDestination(for: Program.self) { program in
                ProgramDetailView(program: program)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddProgram = true
                    } label: {
                        Label("Nytt program", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddProgram) {
                AddProgramView()
            }
        }
    }

    private func deletePrograms(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(programs[index])
        }
    }
}

#Preview {
    ProgramListView()
        .modelContainer(
            for: [Program.self, ProgramWeek.self, ProgramSession.self, ProgramExercise.self],
            inMemory: true
        )
}
