import SwiftUI
import SwiftData

struct ExerciseTimerView: View {
    @Bindable var exercise: ProgramExercise
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var metronome: MetronomeEngine

    @State private var remainingSeconds: Int
    @State private var endDate: Date?
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

                metronomeControl
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
                refreshRemainingTime()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    refreshRemainingTime()
                }
            }
            .onAppear {
                NotificationManager.shared.requestAuthorizationIfNeeded()
            }
        }
    }

    private var metronomeControl: some View {
        VStack(spacing: 12) {
            Text("Metronom")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            BeatDotsView(
                beatsPerBar: metronome.timeSignature.beatsPerBar,
                currentBeat: metronome.currentBeat,
                isPlaying: metronome.isPlaying
            )
            .frame(height: 20)

            HStack(spacing: 20) {
                Button {
                    metronome.bpm = max(40, metronome.bpm - 1)
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())

                Text("\(Int(metronome.bpm)) BPM")
                    .font(.headline)
                    .monospacedDigit()
                    .frame(minWidth: 92)

                Button {
                    metronome.bpm = min(208, metronome.bpm + 1)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())

                Button {
                    metronome.toggle()
                } label: {
                    Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(metronome.isPlaying ? Color("CompletedColor") : Color.accentColor)
                .clipShape(Circle())
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Recomputes `remainingSeconds` from the absolute `endDate` rather than counting ticks,
    /// so the countdown is always correct even after the app spent time backgrounded/suspended.
    private func refreshRemainingTime() {
        guard isRunning, let endDate else { return }
        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded()))
        remainingSeconds = remaining
        if remaining == 0 {
            isRunning = false
            hasFinished = true
            self.endDate = nil
        }
    }

    private func start() {
        guard remainingSeconds > 0 else { return }
        isRunning = true
        hasFinished = false
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        NotificationManager.shared.scheduleTimerAlarm(
            id: notificationID,
            title: "Övningen är klar",
            body: exercise.detail.isEmpty ? exercise.name : "\(exercise.name) – \(exercise.detail)",
            secondsFromNow: TimeInterval(remainingSeconds)
        )
    }

    private func pause() {
        if let endDate {
            remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow.rounded()))
        }
        endDate = nil
        isRunning = false
        NotificationManager.shared.cancelTimerAlarm(id: notificationID)
    }

    private func reset() {
        pause()
        remainingSeconds = exercise.durationMinutes * 60
        hasFinished = false
    }
}
