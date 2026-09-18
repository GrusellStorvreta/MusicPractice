import AVFoundation

@MainActor
final class MetronomeEngine: ObservableObject {
    enum TimeSignature: String, CaseIterable, Identifiable, Hashable {
        case twoFour = "2/4"
        case threeFour = "3/4"
        case fourFour = "4/4"
        case sixEight = "6/8"
        case nineEight = "9/8"

        var id: String { rawValue }

        var beatsPerBar: Int {
            switch self {
            case .twoFour: return 2
            case .threeFour: return 3
            case .fourFour: return 4
            case .sixEight: return 6
            case .nineEight: return 9
            }
        }
    }

    @Published var bpm: Double = 90
    @Published var timeSignature: TimeSignature = .fourFour
    @Published private(set) var isPlaying = false
    @Published private(set) var currentBeat = 0

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var accentBuffer: AVAudioPCMBuffer?
    private var normalBuffer: AVAudioPCMBuffer?

    private var timer: DispatchSourceTimer?
    private var nextTickTime: DispatchTime = .now()
    private var beatIndex = 0

    init() {
        setupAudio()
    }

    deinit {
        timer?.cancel()
    }

    private func setupAudio() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        accentBuffer = Self.makeClickBuffer(frequency: 1500, durationMs: 35, format: format)
        normalBuffer = Self.makeClickBuffer(frequency: 900, durationMs: 30, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            print("Metronome: could not start audio engine: \(error)")
        }
    }

    func toggle() {
        isPlaying ? stop() : start()
    }

    func start() {
        guard !isPlaying, engine.isRunning else { return }
        isPlaying = true
        beatIndex = 0
        currentBeat = 0
        playerNode.play()
        nextTickTime = .now()
        scheduleNextTick(at: nextTickTime)
    }

    func stop() {
        guard isPlaying else { return }
        isPlaying = false
        timer?.cancel()
        timer = nil
        playerNode.stop()
    }

    private func scheduleNextTick(at deadline: DispatchTime) {
        let source = DispatchSource.makeTimerSource(queue: .main)
        source.schedule(deadline: deadline, leeway: .milliseconds(2))
        source.setEventHandler { [weak self] in
            self?.handleTick()
        }
        source.resume()
        timer = source
    }

    private func handleTick() {
        guard isPlaying else { return }
        let beatsPerBar = timeSignature.beatsPerBar
        let beat = beatIndex % beatsPerBar
        playClick(accent: beat == 0)
        currentBeat = beat

        beatIndex += 1
        let intervalNanos = UInt64((60.0 / bpm) * 1_000_000_000)
        nextTickTime = DispatchTime(uptimeNanoseconds: nextTickTime.uptimeNanoseconds + intervalNanos)
        scheduleNextTick(at: nextTickTime)
    }

    private func playClick(accent: Bool) {
        guard let buffer = accent ? accentBuffer : normalBuffer else { return }
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    private static func makeClickBuffer(frequency: Double, durationMs: Double, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * durationMs / 1000.0)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData?[0] else { return nil }
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let envelope = exp(-t * 45.0)
            channelData[frame] = Float(sin(2.0 * .pi * frequency * t) * envelope)
        }
        return buffer
    }
}
