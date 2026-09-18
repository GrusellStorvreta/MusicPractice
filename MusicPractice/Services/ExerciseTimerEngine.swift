import Foundation
import UIKit

/// App-global so an exercise's countdown survives closing and reopening the timer
/// sheet, and keeps running (with a Live Activity) while the app is backgrounded.
@MainActor
final class ExerciseTimerEngine: ObservableObject {
    @Published private(set) var activeExerciseID: UUID?
    @Published private(set) var remainingSeconds = 0
    @Published private(set) var isRunning = false
    @Published private(set) var hasFinished = false

    private var endDate: Date?
    private var exerciseName = ""
    private var exerciseDetail = ""
    private var displayTimer: Timer?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    deinit {
        displayTimer?.invalidate()
    }

    @objc private func handleDidBecomeActive() {
        refresh()
    }

    func isActive(_ exercise: ProgramExercise) -> Bool {
        activeExerciseID == exercise.id
    }

    func displaySeconds(for exercise: ProgramExercise) -> Int {
        isActive(exercise) ? remainingSeconds : exercise.durationMinutes * 60
    }

    func isRunning(for exercise: ProgramExercise) -> Bool {
        isActive(exercise) && isRunning
    }

    func hasFinished(for exercise: ProgramExercise) -> Bool {
        isActive(exercise) && hasFinished
    }

    func start(exercise: ProgramExercise) {
        if !isActive(exercise) {
            activeExerciseID = exercise.id
            exerciseName = exercise.displayName
            exerciseDetail = exercise.detail
            remainingSeconds = exercise.durationMinutes * 60
            hasFinished = false
        }
        guard remainingSeconds > 0 else { return }

        isRunning = true
        hasFinished = false
        let newEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        endDate = newEndDate
        startDisplayTimer()

        NotificationManager.shared.scheduleTimerAlarm(
            id: notificationID(for: exercise),
            title: "Övningen är klar",
            body: exerciseDetail.isEmpty ? exerciseName : "\(exerciseName) – \(exerciseDetail)",
            secondsFromNow: TimeInterval(remainingSeconds)
        )
        LiveActivityManager.shared.startOrUpdateRunning(
            exerciseID: exercise.id,
            exerciseName: exerciseName,
            exerciseDetail: exerciseDetail,
            endDate: newEndDate
        )
    }

    func pause(exercise: ProgramExercise) {
        guard isActive(exercise) else { return }
        if let endDate {
            remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow.rounded()))
        }
        endDate = nil
        isRunning = false
        stopDisplayTimer()
        NotificationManager.shared.cancelTimerAlarm(id: notificationID(for: exercise))
        LiveActivityManager.shared.updatePaused(exerciseID: exercise.id, remainingSeconds: remainingSeconds)
    }

    func reset(exercise: ProgramExercise) {
        pause(exercise: exercise)
        guard isActive(exercise) else { return }
        remainingSeconds = exercise.durationMinutes * 60
        hasFinished = false
        LiveActivityManager.shared.cancel(exerciseID: exercise.id)
    }

    private func notificationID(for exercise: ProgramExercise) -> String {
        "exercise-timer-\(exercise.id.uuidString)"
    }

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        let newTimer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        displayTimer = newTimer
    }

    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }

    private func refresh() {
        guard isRunning, let endDate else { return }
        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded()))
        remainingSeconds = remaining
        if remaining == 0 {
            isRunning = false
            hasFinished = true
            self.endDate = nil
            stopDisplayTimer()
            if let activeExerciseID {
                LiveActivityManager.shared.finish(exerciseID: activeExerciseID)
            }
        }
    }
}
