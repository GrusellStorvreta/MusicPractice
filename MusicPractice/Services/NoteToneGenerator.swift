import AVFoundation

/// Plays a short synthesized reference tone so you can hear the target note before playing it.
@MainActor
final class NoteToneGenerator {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var isSetUp = false

    func play(frequency: Double, durationSeconds: Double = 1.0) {
        setupIfNeeded()
        guard let buffer = Self.makeToneBuffer(frequency: frequency, durationSeconds: durationSeconds, sampleRate: 44_100) else {
            return
        }
        if !playerNode.isPlaying {
            playerNode.play()
        }
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    private func setupIfNeeded() {
        guard !isSetUp else { return }
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try session.setActive(true)
            try engine.start()
            isSetUp = true
        } catch {
            print("NoteToneGenerator: could not start engine: \(error)")
        }
    }

    private static func makeToneBuffer(frequency: Double, durationSeconds: Double, sampleRate: Double) -> AVAudioPCMBuffer? {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(sampleRate * durationSeconds)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData?[0] else { return nil }

        let attack = 0.02
        let release = 0.15
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            var envelope = 1.0
            if t < attack {
                envelope = t / attack
            } else if t > durationSeconds - release {
                envelope = max(0, (durationSeconds - t) / release)
            }
            channelData[frame] = Float(sin(2.0 * .pi * frequency * t) * envelope * 0.3)
        }
        return buffer
    }
}
