import SwiftUI
import SwiftData

struct ExerciseTimerView: View {
    @Bindable var exercise: ProgramExercise
    @Environment(\.dismiss) private var dismiss

    @State private var remainingSeconds: Int
    @State private var isRunning = false
    @State private var hasFinished = false

    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(exercise: ProgramExercise) {
        self.exercise = exercise
        _remainingSeconds = State(initialValue: exercise.durationMinutes * 60)
    }

    private var notificationID: String {
        "exercise-timer-\(exercise.id.uuidString)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text(exercise.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    if !exercise.detail.isEmpty {
                        Text(exercise.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(timeString)
                    .font(.system(size: 64, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(hasFinished ? Color("CompletedColor") : Color.primary)

                if hasFinished {
                    Text("Tiden är slut! 🎉")
                        .font(.headline)
                        .foregroundStyle(Color("CompletedColor"))
                }

                HStack(spacing: 16) {
                    Button(isRunning ? "Pausa" : "Starta") {
                        isRunning ? pause() : start()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(remainingSeconds == 0)

                    Button("Nollställ") {
                        reset()
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    exercise.isCompleted.toggle()
                    exercise.completedAt = exercise.isCompleted ? .now : nil
                } label: {
                    Label(
                        exercise.isCompleted ? "Markerad som klar" : "Markera som klar",
                        systemImage: exercise.isCompleted ? "checkmark.circle.fill" : "checkmark.circle"
                    )
                }
                .buttonStyle(.bordered)
                .tint(exercise.isCompleted ? Color("CompletedColor") : Color.accentColor)
            }
            .padding()
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Stäng") {
                        pause()
                        dismiss()
                    }
                }
            }
            .onReceive(tick) { _ in
                guard isRunning, remainingSeconds > 0 else { return }
                remainingSeconds -= 1
                if remainingSeconds == 0 {
                    isRunning = false
                    hasFinished = true
                }
            }
            .onAppear {
                NotificationManager.shared.requestAuthorizationIfNeeded()
            }
        }
    }

    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func start() {
        guard remainingSeconds > 0 else { return }
        isRunning = true
        hasFinished = false
        NotificationManager.shared.scheduleTimerAlarm(
            id: notificationID,
            title: "Övningen är klar",
            body: exercise.detail.isEmpty ? exercise.name : "\(exercise.name) – \(exercise.detail)",
            secondsFromNow: TimeInterval(remainingSeconds)
        )
    }

    private func pause() {
        isRunning = false
        NotificationManager.shared.cancelTimerAlarm(id: notificationID)
    }

    private func reset() {
        pause()
        remainingSeconds = exercise.durationMinutes * 60
        hasFinished = false
    }
}
