import SwiftUI

struct NoteReadingView: View {
    @StateObject private var pitchDetector = PitchDetector()
    @State private var toneGenerator = NoteToneGenerator()

    @State private var currentNote = StaffNote.random()
    @State private var justCorrect = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                StaffView(note: currentNote)
                    .frame(height: 160)
                    .padding(.horizontal)

                statusText

                if justCorrect {
                    Text("Rätt! 🎉")
                        .font(.title3.bold())
                        .foregroundStyle(Color("CompletedColor"))
                }

                HStack(spacing: 16) {
                    Button {
                        playReference()
                    } label: {
                        Label("Lyssna", systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        nextNote()
                    } label: {
                        Label("Nästa", systemImage: "arrow.right.circle")
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }
            .padding(.top)
            .padding()
            .navigationTitle("Notläsning")
            .onAppear {
                pitchDetector.requestPermissionAndStart()
            }
            .onDisappear {
                pitchDetector.stop()
            }
            .onChange(of: pitchDetector.detectedFrequency) { _, newValue in
                guard let newValue, isMatch(newValue), !justCorrect else { return }
                justCorrect = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    nextNote()
                }
            }
            .alert(
                "Mikrofonåtkomst behövs",
                isPresented: Binding(get: { pitchDetector.permissionDenied }, set: { _ in })
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("För att appen ska kunna höra vilken ton du spelar behöver den tillgång till mikrofonen. Slå på det i Inställningar för MusicPractice.")
            }
        }
    }

    @ViewBuilder
    private var statusText: some View {
        if let frequency = pitchDetector.detectedFrequency {
            Text("Du spelar: \(PitchDetector.noteLabel(forFrequency: frequency))")
                .font(.subheadline)
                .foregroundStyle(isMatch(frequency) ? Color("CompletedColor") : .secondary)
        } else {
            Text(pitchDetector.isListening ? "Lyssnar …" : " ")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func isMatch(_ frequency: Double) -> Bool {
        PitchDetector.pitchClass(forFrequency: frequency) == currentNote.letter.semitoneOffset
    }

    private func nextNote() {
        justCorrect = false
        currentNote = StaffNote.random(excluding: currentNote)
    }

    private func playReference() {
        pitchDetector.stop()
        toneGenerator.play(frequency: currentNote.frequency)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            pitchDetector.start()
        }
    }
}

#Preview {
    NoteReadingView()
}
