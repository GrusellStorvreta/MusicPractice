import SwiftUI
import SwiftData

struct AddSongView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var genre = ""
    @State private var notes = ""

    var body: some View {
        FormSheet(title: "Ny låt", isSaveDisabled: name.trimmed.isEmpty, onSave: save) {
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
    }

    private func save() {
        let song = Song(
            name: name.trimmed,
            genre: genre.trimmed,
            notes: notes.trimmed
        )
        modelContext.insert(song)
        dismiss()
    }
}
