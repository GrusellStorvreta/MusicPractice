import SwiftUI
import SwiftData

struct SongDetailView: View {
    @Bindable var song: Song

    var body: some View {
        Form {
            Section("Låt") {
                TextField("Namn", text: $song.name)
                TextField("Genre", text: $song.genre)
            }
            Section("Anteckningar") {
                TextField("Valfritt", text: $song.notes, axis: .vertical)
                    .lineLimit(3...8)
            }
            Section("Sammanfattning") {
                LabeledContent("Total övningstid", value: formattedTotal)
                if let lastPracticed {
                    LabeledContent("Senast övad") {
                        Text(lastPracticed, style: .date)
                    }
                }
            }
            Section("Historik") {
                if historyEntries.isEmpty {
                    Text("Inga övningspass kopplade till den här låten ännu.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(historyEntries) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(entry.date, style: .date)
                                Spacer()
                                Text("\(entry.durationMinutes) min")
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.sourceLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !entry.detail.isEmpty {
                                Text(entry.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle(song.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct HistoryEntry: Identifiable {
        let id = UUID()
        let date: Date
        let durationMinutes: Int
        let sourceLabel: String
        let detail: String
    }

    private var historyEntries: [HistoryEntry] {
        var entries: [HistoryEntry] = []

        for session in song.practiceSessions {
            entries.append(
                HistoryEntry(
                    date: session.date,
                    durationMinutes: session.durationMinutes,
                    sourceLabel: "Snabblogg",
                    detail: session.notes
                )
            )
        }

        for exercise in song.exercises {
            guard let completedAt = exercise.completedAt else { continue }
            let programName = exercise.session?.week?.program?.name
            entries.append(
                HistoryEntry(
                    date: completedAt,
                    durationMinutes: exercise.durationMinutes,
                    sourceLabel: programName ?? "Program",
                    detail: exercise.detail
                )
            )
        }

        return entries.sorted { $0.date > $1.date }
    }

    private var totalMinutes: Int {
        historyEntries.reduce(0) { $0 + $1.durationMinutes }
    }

    private var lastPracticed: Date? {
        historyEntries.first?.date
    }

    private var formattedTotal: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours) h \(minutes) min" : "\(minutes) min"
    }
}
