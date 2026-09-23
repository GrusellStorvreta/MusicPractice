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
        FormSheet(title: "Nytt pass", isSaveDisabled: name.trimmed.isEmpty, onSave: save) {
            TextField("Namn på passet, t.ex. Pass A", text: $name)
        }
    }

    private func save() {
        onSave(name.trimmed)
        dismiss()
    }
}
