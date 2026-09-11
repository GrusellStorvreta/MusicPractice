import SwiftUI

struct AddSessionNameView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    let onSave: (String) -> Void

    init(suggestedName: String = "", onSave: @escaping (String) -> Void) {
        _name = State(initialValue: suggestedName)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Namn på passet, t.ex. Pass A", text: $name)
            }
            .navigationTitle("Nytt pass")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spara") {
                        onSave(name.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
