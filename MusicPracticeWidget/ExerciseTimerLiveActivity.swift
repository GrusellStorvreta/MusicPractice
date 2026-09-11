import ActivityKit
import WidgetKit
import SwiftUI

struct ExerciseTimerLiveActivity: Widget {
    private let backgroundTint = Color(red: 0.243, green: 0.361, blue: 0.345) // matches AccentColor

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExerciseTimerAttributes.self) { context in
            LockScreenView(attributes: context.attributes, state: context.state)
                .activityBackgroundTint(backgroundTint)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CountdownText(state: context.state)
                        .font(.title3.monospacedDigit())
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.attributes.exerciseName)
                            .font(.headline)
                        if !context.attributes.exerciseDetail.isEmpty {
                            Text(context.attributes.exerciseDetail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
            } compactTrailing: {
                CountdownText(state: context.state)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}

private struct LockScreenView: View {
    let attributes: ExerciseTimerAttributes
    let state: ExerciseTimerAttributes.ContentState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(attributes.exerciseName)
                    .font(.headline)
                if !attributes.exerciseDetail.isEmpty {
                    Text(attributes.exerciseDetail)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                if state.isFinished {
                    Text("Klar! 🎉")
                        .font(.subheadline.weight(.semibold))
                } else if !state.isRunning {
                    Text("Pausad")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            Spacer()
            CountdownText(state: state)
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .padding()
        .foregroundStyle(.white)
    }
}

private struct CountdownText: View {
    let state: ExerciseTimerAttributes.ContentState

    var body: some View {
        if state.isFinished {
            Text("00:00")
        } else if state.isRunning, state.endDate > .now {
            Text(timerInterval: Date.now...state.endDate, countsDown: true, showsHours: false)
        } else {
            Text(staticTime(state.pausedRemainingSeconds))
        }
    }

    private func staticTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
