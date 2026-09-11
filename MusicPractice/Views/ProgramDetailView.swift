import SwiftUI
import SwiftData

struct ProgramDetailView: View {
    @Bindable var program: Program
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(program.sortedWeeks) { week in
                NavigationLink(value: week) {
                    HStack {
                        Text("Vecka \(week.weekNumber)")
                            .font(.headline)
                        if week.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        Spacer()
                        Text("\(week.sortedSessions.count) pass")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteWeeks)
        }
        .navigationTitle(program.name)
        .navigationDestination(for: ProgramWeek.self) { week in
            WeekDetailView(week: week)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    addWeek()
                } label: {
                    Label("Ny vecka", systemImage: "plus")
                }
            }
        }
    }

    private func addWeek() {
        let week = ProgramWeek(weekNumber: program.nextWeekNumber)
        week.program = program
        program.weeks.append(week)
    }

    private func deleteWeeks(at offsets: IndexSet) {
        let weeks = program.sortedWeeks
        for index in offsets {
            modelContext.delete(weeks[index])
        }
    }
}
