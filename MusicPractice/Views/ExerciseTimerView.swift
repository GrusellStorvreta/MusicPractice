import SwiftUI
import SwiftData

struct ExerciseTimerView: View {
    @Bindable var exercise: ProgramExercise
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var metronome: MetronomeEngine
    @EnvironmentObject private var exerciseTimer: ExerciseTimerEngine

    private var remainingSeconds: Int { exerciseTimer.displaySeconds(for: exercise) }
    private var isRunning: Bool { exerciseTimer.isRunning(for: exercise) }
    private var hasFinished: Bool { exerciseTimer.hasFinished(for: exercise) }

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
                } else if isRunning {
                    Label("Fortsätter i bakgrunden om du byter app", systemImage: "checkmark.shield")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 16) {
                    Button(isRunning ? "Pausa" : "Starta") {
                        isRunning ? exerciseTimer.pause(exercise: exercise) : exerciseTimer.start(exercise: exercise)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(remainingSeconds == 0)

                    Button("Nollställ") {
                        exerciseTimer.reset(exercise: exercise)
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
                        dismiss()
                    }
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
}
