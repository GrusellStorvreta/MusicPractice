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
        text.trimmed
    }

    private var matches: [Song] {
        guard !trimmedText.isEmpty else { return [] }
        return allSongs.filter { $0.name.localizedCaseInsensitiveContains(trimmedText) }
    }

    private var hasExactMatch: Bool {
        matches.contains { $0.name.localizedCaseInsensitiveCompare(trimmedText) == .orderedSame }
    }

    var body: some View {
        Group {
            if selectedSong == nil && !trimmedText.isEmpty {
                songSuggestions
            }
        }
        .onChange(of: text) { _, newValue in
            // The picked song no longer matches what's typed — treat it as free text again
            // so a suggestion (or "create new") reappears instead of silently keeping a stale link.
            if let selectedSong, selectedSong.name != newValue {
                self.selectedSong = nil
            }
        }
    }

    private var songSuggestions: some View {
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
