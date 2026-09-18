import SwiftUI
import SwiftData

struct SongListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Song.name) private var songs: [Song]
    @State private var isPresentingAddSong = false

    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty {
                    ContentUnavailableView(
                        "Inga låtar ännu",
                        systemImage: "music.quarternote.3",
                        description: Text("Tryck på + för att lägga till en låt i din repertoar.")
                    )
                } else {
                    List {
                        ForEach(songs) { song in
                            NavigationLink(value: song) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.name)
                                        .font(.headline)
                                    if !song.genre.isEmpty {
                                        Text(song.genre)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .onDelete(perform: deleteSongs)
                    }
                }
            }
            .navigationTitle("Låtar")
            .navigationDestination(for: Song.self) { song in
                SongDetailView(song: song)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddSong = true
                    } label: {
                        Label("Ny låt", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddSong) {
                AddSongView()
            }
        }
    }

    private func deleteSongs(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(songs[index])
        }
    }
}

#Preview {
    SongListView()
        .modelContainer(for: Song.self, inMemory: true)
}
