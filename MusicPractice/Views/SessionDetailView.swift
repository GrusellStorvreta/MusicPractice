import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Bindable var session: ProgramSession
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddExercise = false
    @State private var timerExercise: ProgramExercise?

    var body: some View {
        List {
            ForEach(session.sortedExercises) { exercise in
                ExerciseRow(exercise: exercise) {
                    timerExercise = exercise
                }
            }
            .onDelete(perform: deleteExercises)
        }
        .navigationTitle(session.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingAddExercise = true
                } label: {
                    Label("Ny övning", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddExercise) {
            AddExerciseView(session: session)
        }
        .sheet(item: $timerExercise) { exercise in
            ExerciseTimerView(exercise: exercise)
        }
    }

    private func deleteExercises(at offsets: IndexSet) {
        let exercises = session.sortedExercises
        for index in offsets {
            modelContext.delete(exercises[index])
        }
    }
}

private struct ExerciseRow: View {
    @Bindable var exercise: ProgramExercise
    let onStartTimer: () -> Void

    var body: some View {
        HStack {
            Button {
                exercise.isCompleted.toggle()
                exercise.completedAt = exercise.isCompleted ? .now : nil
            } label: {
                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(exercise.isCompleted ? Color("CompletedColor") : Color.secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)
                    .strikethrough(exercise.isCompleted)
                if !exercise.detail.isEmpty {
                    Text(exercise.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                onStartTimer()
            } label: {
                Label("\(exercise.durationMinutes) min", systemImage: "timer")
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}
