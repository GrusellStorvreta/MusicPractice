import SwiftUI
import SwiftData

/// Drop into a Form right below a free-text name field: shows matching existing songs to
/// link to, plus a "create new song" row, so picking or creating a Song happens inline.
struct SongSuggestionsSection: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Song.name) private var allSongs: [Song]

    @Binding var text: String
    @Binding var selectedSong: Song?

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespaces)
    }

    private var matches: [Song] {
        guard !trimmedText.isEmpty else { return [] }
        return allSongs.filter { $0.name.localizedCaseInsensitiveContains(trimmedText) }
    }

    private var hasExactMatch: Bool {
        matches.contains { $0.name.localizedCaseInsensitiveCompare(trimmedText) == .orderedSame }
    }

    var body: some View {
        if selectedSong == nil && !trimmedText.isEmpty {
            Section("Låtar") {
                ForEach(matches) { song in
                    Button {
                        select(song)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.name)
                                    .foregroundStyle(.primary)
                                if !song.genre.isEmpty {
                                    Text(song.genre)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                }

                if !hasExactMatch {
                    Button {
                        createAndSelect()
                    } label: {
                        Label("Skapa ny låt: \"\(trimmedText)\"", systemImage: "plus.circle")
                    }
                }
            }
        }
    }

    private func select(_ song: Song) {
        text = song.name
        selectedSong = song
    }

    private func createAndSelect() {
        let song = Song(name: trimmedText)
        modelContext.insert(song)
        text = trimmedText
        selectedSong = song
    }
}
