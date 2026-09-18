import SwiftUI
import SwiftData

struct AddSongView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var genre = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Namn") {
                    TextField("T.ex. Drowsy Maggie", text: $name)
                }
                Section("Genre") {
                    TextField("T.ex. reel, jig, vals (valfritt)", text: $genre)
                }
                Section("Anteckningar") {
                    TextField("Valfritt", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Ny låt")
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
        let song = Song(
            name: name.trimmingCharacters(in: .whitespaces),
            genre: genre.trimmingCharacters(in: .whitespaces),
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(song)
        dismiss()
    }
}
