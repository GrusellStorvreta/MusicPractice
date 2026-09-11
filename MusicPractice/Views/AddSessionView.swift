import SwiftUI
import SwiftData

struct AddSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var pieceName = ""
    @State private var durationMinutes = 30
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vad övade du på?") {
                    TextField("Låt/stycke", text: $pieceName)
                }
                Section("Detaljer") {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    Stepper("Längd: \(durationMinutes) min", value: $durationMinutes, in: 5...240, step: 5)
                }
                Section("Anteckningar") {
                    TextField("Valfritt", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nytt övningspass")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spara") { save() }
                        .disabled(pieceName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let session = PracticeSession(
            date: date,
            pieceName: pieceName.trimmingCharacters(in: .whitespaces),
            durationMinutes: durationMinutes,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(session)
        dismiss()
    }
}

#Preview {
    AddSessionView()
        .modelContainer(for: PracticeSession.self, inMemory: true)
}
