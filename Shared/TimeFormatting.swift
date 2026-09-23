import Foundation

enum TimeFormatting {
    /// Formats a duration in seconds as "MM:SS" — used by both the app's exercise timer
    /// and the Live Activity widget's countdown, which need to render it identically.
    static func minutesAndSeconds(_ totalSeconds: Int) -> String {
        String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
