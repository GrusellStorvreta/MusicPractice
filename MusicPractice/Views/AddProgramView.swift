import SwiftUI
import SwiftData

struct AddProgramView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var notes = ""

    var body: some View {
        FormSheet(title: "Nytt program", isSaveDisabled: name.trimmed.isEmpty, onSave: save) {
            Section("Namn") {
                TextField("T.ex. Irish tunes – 8 veckor", text: $name)
            }
            Section("Anteckningar") {
                TextField("Valfritt", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    private func save() {
        let program = Program(
            name: name.trimmed,
            notes: notes.trimmed
        )
        modelContext.insert(program)
        dismiss()
    }
}
