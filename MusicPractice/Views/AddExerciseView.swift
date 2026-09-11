import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Bindable var session: ProgramSession
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var detail = ""
    @State private var durationMinutes = 10

    var body: some View {
        NavigationStack {
            Form {
                Section("Vad ska övas?") {
                    TextField("T.ex. Drowsy Maggie", text: $name)
                    TextField("Detalj, t.ex. melodi/komp/playalong (valfritt)", text: $detail)
                }
                Section("Längd") {
                    Stepper("\(durationMinutes) min", value: $durationMinutes, in: 1...120, step: 1)
                }
            }
            .navigationTitle("Ny övning")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spara") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let exercise = ProgramExercise(
            name: name.trimmingCharacters(in: .whitespaces),
            detail: detail.trimmingCharacters(in: .whitespaces),
            durationMinutes: durationMinutes,
            orderIndex: session.exercises.count
        )
        exercise.session = session
        session.exercises.append(exercise)
        dismiss()
    }
}
