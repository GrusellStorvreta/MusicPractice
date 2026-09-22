import AVFoundation

@MainActor
final class PitchDetector: ObservableObject {
    @Published private(set) var isListening = false
    @Published private(set) var detectedFrequency: Double?
    @Published var permissionDenied = false

    private let engine = AVAudioEngine()
    private let minFrequency: Double = 70    // below guitar low E (~82 Hz), with margin
    private let maxFrequency: Double = 1200  // comfortably above guitar's practical fretted range

    func requestPermissionAndStart() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                if granted {
                    self.start()
                } else {
                    self.permissionDenied = true
                }
            }
        }
    }

    func start() {
        guard !isListening else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try session.setActive(true)

            let input = engine.inputNode
            let format = input.inputFormat(forBus: 0)
            let sampleRate = format.sampleRate
            let minFreq = minFrequency
            let maxFreq = maxFrequency

            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, _ in
                // Keep this real-time audio callback cheap: just copy the samples out and
                // do the actual pitch-detection math off the audio thread.
                guard let channelData = buffer.floatChannelData?[0] else { return }
                let frameCount = Int(buffer.frameLength)
                guard frameCount > 0 else { return }
                let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))

                Task.detached(priority: .userInitiated) {
                    let frequency = Self.detectPitch(
                        samples: samples,
                        sampleRate: sampleRate,
                        minFrequency: minFreq,
                        maxFrequency: maxFreq
                    )
                    await MainActor.run { [weak self] in
                        self?.detectedFrequency = frequency
                    }
                }
            }

            try engine.start()
            isListening = true
            permissionDenied = false
        } catch {
            print("PitchDetector: could not start: \(error)")
        }
    }

    func stop() {
        guard isListening else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isListening = false
        detectedFrequency = nil
    }

    /// Normalized autocorrelation pitch detector: finds the lag (within the expected frequency
    /// range) with the strongest self-similarity, which corresponds to the fundamental period.
    /// Works well for a single monophonic note; not meant for chords.
    nonisolated static func detectPitch(
        samples: [Float],
        sampleRate: Double,
        minFrequency: Double,
        maxFrequency: Double
    ) -> Double? {
        let frameCount = samples.count
        guard frameCount > 0 else { return nil }

        var sumSquares: Float = 0
        for sample in samples { sumSquares += sample * sample }
        let rms = sqrt(sumSquares / Float(frameCount))
        guard rms > 0.01 else { return nil } // treat near-silence as "no note"

        let minLag = Int(sampleRate / maxFrequency)
        let maxLag = min(Int(sampleRate / minFrequency), frameCount - 1)
        guard maxLag > minLag, minLag > 0 else { return nil }

        var bestLag = -1
        var bestCorrelation: Float = 0
        for lag in minLag...maxLag {
            var correlation: Float = 0
            for i in 0..<(frameCount - lag) {
                correlation += samples[i] * samples[i + lag]
            }
            if correlation > bestCorrelation {
                bestCorrelation = correlation
                bestLag = lag
            }
        }

        guard bestLag > 0 else { return nil }
        return sampleRate / Double(bestLag)
    }

    /// Pitch class 0-11 (0 = C) for the nearest equal-tempered semitone to this frequency.
    nonisolated static func pitchClass(forFrequency frequency: Double) -> Int {
        let midi = 69.0 + 12.0 * log2(frequency / 440.0)
        let rounded = Int(midi.rounded())
        return ((rounded % 12) + 12) % 12
    }

    nonisolated static func noteLabel(forFrequency frequency: Double) -> String {
        let labels = ["C", "C♯", "D", "D♯", "E", "F", "F♯", "G", "G♯", "A", "A♯", "B"]
        return labels[pitchClass(forFrequency: frequency)]
    }
}
