import SwiftUI
import SwiftData

struct AddSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var pieceName = ""
    @State private var selectedSong: Song?
    @State private var durationMinutes = 30
    @State private var notes = ""

    var body: some View {
        FormSheet(title: "Nytt övningspass", isSaveDisabled: pieceName.trimmed.isEmpty, onSave: save) {
            Section("Vad övade du på?") {
                TextField("Låt/stycke", text: $pieceName)
            }
            SongSuggestionsSection(text: $pieceName, selectedSong: $selectedSong)
            Section("Detaljer") {
                DatePicker("Datum", selection: $date, displayedComponents: .date)
                Stepper("Längd: \(durationMinutes) min", value: $durationMinutes, in: 5...240, step: 5)
            }
            Section("Anteckningar") {
                TextField("Valfritt", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    private func save() {
        let session = PracticeSession(
            date: date,
            pieceName: pieceName.trimmed,
            durationMinutes: durationMinutes,
            notes: notes.trimmed
        )
        session.song = selectedSong
        modelContext.insert(session)
        dismiss()
    }
}

#Preview {
    AddSessionView()
        .modelContainer(for: PracticeSession.self, inMemory: true)
}
