import SwiftUI

/// Shared shell for every "Add/Edit ___" sheet: a Form in a NavigationStack with the
/// standard Avbryt/Spara toolbar, so each call site only supplies its fields and a save action.
struct FormSheet<Content: View>: View {
    let title: String
    let isSaveDisabled: Bool
    let onSave: () -> Void
    @ViewBuilder let content: () -> Content

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                content()
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spara", action: onSave)
                        .disabled(isSaveDisabled)
                }
            }
        }
    }
}
