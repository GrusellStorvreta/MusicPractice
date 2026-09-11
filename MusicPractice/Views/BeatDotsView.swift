import SwiftUI

struct BeatDotsView: View {
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
