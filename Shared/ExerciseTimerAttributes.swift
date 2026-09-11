import ActivityKit
import Foundation

/// Shared between the app and the widget extension so both can speak the same
/// Live Activity shape. Keep this file free of anything app- or widget-only.
struct ExerciseTimerAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// Meaningful while `isRunning` is true; the system renders the live countdown from this.
        var endDate: Date
        /// Meaningful while `isRunning` is false (paused, not yet finished).
        var pausedRemainingSeconds: Int
        var isRunning: Bool
        var isFinished: Bool
    }

    var exerciseName: String
    var exerciseDetail: String
}
