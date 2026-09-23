import Foundation

extension String {
    /// Leading/trailing whitespace trimmed — used everywhere a typed value is saved as a model field.
    var trimmed: String {
        trimmingCharacters(in: .whitespaces)
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
