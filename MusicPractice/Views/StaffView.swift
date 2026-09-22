import SwiftUI

/// Draws a treble-clef staff with a single note (plus ledger lines if it falls outside the staff).
struct StaffView: View {
    let note: StaffNote

    private let lineSpacing: CGFloat = 16
    private let numberOfLines = 5
    private static let referenceNote = StaffNote(letter: .e, octave: 4) // treble clef bottom line

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let midY = geometry.size.height / 2
            let topLineY = midY - lineSpacing * 2
            let bottomLineY = midY + lineSpacing * 2
            let step = note.absoluteDiatonicStep - Self.referenceNote.absoluteDiatonicStep
            let noteY = bottomLineY - CGFloat(step) * (lineSpacing / 2)
            let noteX = width * 0.62

            ZStack {
                Path { path in
                    for i in 0..<numberOfLines {
                        let y = topLineY + CGFloat(i) * lineSpacing
                        path.move(to: CGPoint(x: width * 0.08, y: y))
                        path.addLine(to: CGPoint(x: width * 0.92, y: y))
                    }
                }
                .stroke(Color.primary, lineWidth: 1.5)

                Text("𝄞")
                    .font(.system(size: lineSpacing * 6.4))
                    .position(x: width * 0.16, y: midY + lineSpacing * 0.3)

                ForEach(ledgerLineSteps(for: step), id: \.self) { ledgerStep in
                    let y = bottomLineY - CGFloat(ledgerStep) * (lineSpacing / 2)
                    Path { path in
                        path.move(to: CGPoint(x: noteX - lineSpacing * 0.9, y: y))
                        path.addLine(to: CGPoint(x: noteX + lineSpacing * 0.9, y: y))
                    }
                    .stroke(Color.primary, lineWidth: 1.5)
                }

                Ellipse()
                    .fill(Color.primary)
                    .frame(width: lineSpacing * 1.1, height: lineSpacing * 0.8)
                    .rotationEffect(.degrees(-20))
                    .position(x: noteX, y: noteY)
            }
        }
    }

    /// Ledger lines sit at the same step spacing as the staff lines (every 2 diatonic steps),
    /// starting just outside the staff (step 0...8), extending out to the note's own step.
    private func ledgerLineSteps(for step: Int) -> [Int] {
        var steps: [Int] = []
        if step < 0 {
            var s = -2
            while s >= step {
                if s % 2 == 0 { steps.append(s) }
                s -= 1
            }
        } else if step > 8 {
            var s = 10
            while s <= step {
                if s % 2 == 0 { steps.append(s) }
                s += 1
            }
        }
        return steps
    }
}

#Preview {
    StaffView(note: StaffNote(letter: .c, octave: 4))
        .frame(height: 160)
        .padding()
}
