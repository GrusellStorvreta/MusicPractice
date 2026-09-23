import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Bindable var session: ProgramSession
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedSong: Song?
    @State private var detail = ""
    @State private var durationMinutes = 10

    var body: some View {
        FormSheet(title: "Ny övning", isSaveDisabled: name.trimmed.isEmpty, onSave: save) {
            Section("Vad ska övas?") {
                TextField("T.ex. Drowsy Maggie", text: $name)
                TextField("Detalj, t.ex. melodi/komp/playalong (valfritt)", text: $detail)
            }
            SongSuggestionsSection(text: $name, selectedSong: $selectedSong)
            Section("Längd") {
                Stepper("\(durationMinutes) min", value: $durationMinutes, in: 1...120, step: 1)
            }
        }
    }

    private func save() {
        let exercise = ProgramExercise(
            name: name.trimmed,
            detail: detail.trimmed,
            durationMinutes: durationMinutes,
            orderIndex: session.exercises.count
        )
        exercise.session = session
        exercise.song = selectedSong
        session.exercises.append(exercise)
        dismiss()
    }
}
