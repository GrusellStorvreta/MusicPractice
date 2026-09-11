import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var activity: Activity<ExerciseTimerAttributes>?
    private var currentExerciseID: UUID?

    private init() {}

    func startOrUpdateRunning(exerciseID: UUID, exerciseName: String, exerciseDetail: String, endDate: Date) {
        let state = ExerciseTimerAttributes.ContentState(
            endDate: endDate,
            pausedRemainingSeconds: 0,
            isRunning: true,
            isFinished: false
        )

        if let activity, currentExerciseID == exerciseID {
            Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
            return
        }

        if let activity {
            Task { await activity.end(nil, dismissalPolicy: .immediate) }
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            activity = nil
            currentExerciseID = nil
            return
        }

        let attributes = ExerciseTimerAttributes(exerciseName: exerciseName, exerciseDetail: exerciseDetail)
        do {
            activity = try Activity.request(attributes: attributes, content: ActivityContent(state: state, staleDate: nil))
            currentExerciseID = exerciseID
        } catch {
            print("LiveActivityManager: could not start activity: \(error)")
            activity = nil
            currentExerciseID = nil
        }
    }

    func updatePaused(exerciseID: UUID, remainingSeconds: Int) {
        guard let activity, currentExerciseID == exerciseID else { return }
        let state = ExerciseTimerAttributes.ContentState(
            endDate: .now,
            pausedRemainingSeconds: remainingSeconds,
            isRunning: false,
            isFinished: false
        )
        Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
    }

    func finish(exerciseID: UUID) {
        guard let activity, currentExerciseID == exerciseID else { return }
        let state = ExerciseTimerAttributes.ContentState(
            endDate: .now,
            pausedRemainingSeconds: 0,
            isRunning: false,
            isFinished: true
        )
        Task {
            await activity.update(ActivityContent(state: state, staleDate: nil))
            try? await Task.sleep(for: .seconds(3))
            await activity.end(ActivityContent(state: state, staleDate: nil), dismissalPolicy: .default)
        }
        self.activity = nil
        currentExerciseID = nil
    }

    func cancel(exerciseID: UUID) {
        guard let activity, currentExerciseID == exerciseID else { return }
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
        self.activity = nil
        currentExerciseID = nil
    }
}
