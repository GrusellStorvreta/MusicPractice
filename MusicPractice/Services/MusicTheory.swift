import Foundation

enum NaturalNote: String, CaseIterable {
    case c = "C", d = "D", e = "E", f = "F", g = "G", a = "A", b = "B"

    /// Position in the musical alphabet (C=0...B=6) — staff position moves one step per
    /// letter regardless of the actual semitone gap, since notation is diatonic, not chromatic.
    var diatonicIndex: Int {
        switch self {
        case .c: return 0
        case .d: return 1
        case .e: return 2
        case .f: return 3
        case .g: return 4
        case .a: return 5
        case .b: return 6
        }
    }

    /// Semitones above C within the octave — used for pitch matching, not staff position.
    var semitoneOffset: Int {
        switch self {
        case .c: return 0
        case .d: return 2
        case .e: return 4
        case .f: return 5
        case .g: return 7
        case .a: return 9
        case .b: return 11
        }
    }
}

struct StaffNote: Equatable {
    let letter: NaturalNote
    let octave: Int

    /// Absolute diatonic step (relative to some fixed origin), used to compute vertical
    /// staff position as an offset from a reference note like the treble clef's bottom line.
    var absoluteDiatonicStep: Int {
        octave * 7 + letter.diatonicIndex
    }

    var midiNote: Int {
        (octave + 1) * 12 + letter.semitoneOffset
    }

    var frequency: Double {
        440.0 * pow(2.0, (Double(midiNote) - 69.0) / 12.0)
    }

    /// A comfortable two-octave range for a beginner guitarist: middle C up past the treble staff.
    static let practiceRange: [StaffNote] = {
        let letters: [NaturalNote] = [.c, .d, .e, .f, .g, .a, .b]
        var notes: [StaffNote] = []
        for octave in 4...5 {
            for letter in letters {
                notes.append(StaffNote(letter: letter, octave: octave))
            }
        }
        return notes
    }()

    static func random(excluding excluded: StaffNote? = nil) -> StaffNote {
        var note = practiceRange.randomElement()!
        while note == excluded {
            note = practiceRange.randomElement()!
        }
        return note
    }
}
