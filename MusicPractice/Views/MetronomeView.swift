import SwiftUI

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeEngine()

    var body: some View {
        NavigationStack {
            VStack(spacing: 36) {
                Spacer()

                BeatDotsView(
                    beatsPerBar: metronome.timeSignature.beatsPerBar,
                    currentBeat: metronome.currentBeat,
                    isPlaying: metronome.isPlaying
                )
                .frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(Int(metronome.bpm))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 24) {
                    Button {
                        adjustBPM(by: -1)
                    } label: {
                        Image(systemName: "minus")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Circle())

                    Slider(value: $metronome.bpm, in: 40...208, step: 1)

                    Button {
                        adjustBPM(by: 1)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Circle())
                }
                .padding(.horizontal, 24)

                Picker("Taktart", selection: $metronome.timeSignature) {
                    ForEach(MetronomeEngine.TimeSignature.allCases) { signature in
                        Text(signature.rawValue).tag(signature)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                Spacer()

                Button {
                    metronome.toggle()
                } label: {
                    Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 30))
                        .frame(width: 84, height: 84)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .padding(.bottom, 16)

                Spacer()
            }
            .navigationTitle("Metronom")
        }
    }

    private func adjustBPM(by delta: Double) {
        metronome.bpm = min(208, max(40, metronome.bpm + delta))
    }
}

private struct BeatDotsView: View {
    let beatsPerBar: Int
    let currentBeat: Int
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 14) {
            ForEach(0..<beatsPerBar, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .animation(.easeOut(duration: 0.1), value: currentBeat)
            }
        }
    }

    private func isActive(_ index: Int) -> Bool {
        isPlaying && currentBeat == index
    }

    private func dotSize(for index: Int) -> CGFloat {
        let base: CGFloat = index == 0 ? 16 : 12
        return isActive(index) ? base * 1.4 : base
    }

    private func dotColor(for index: Int) -> Color {
        guard isActive(index) else { return Color.secondary.opacity(0.25) }
        return index == 0 ? Color("CompletedColor") : Color.accentColor
    }
}

#Preview {
    MetronomeView()
}
