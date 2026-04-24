import AVFoundation

@MainActor
final class AudioEngine {
    static let standardFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    private static let nodeCount = 12  // covers Hard difficulty (max 12 pairs)

    private let engine = AVAudioEngine()
    private var nodes: [AVAudioPlayerNode] = []   // index == toneID
    private var cachedBuffers: [Int: AVAudioPCMBuffer] = [:]

    init() {
        configureSession()

        // Build the graph once — never change it again
        let mixer = engine.mainMixerNode
        for _ in 0..<Self.nodeCount {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: mixer, format: Self.standardFormat)
            nodes.append(node)
        }

        startEngine()

        // Pre-start all nodes so buffers can be scheduled at any time
        nodes.forEach { $0.play() }
    }

    // Only updates buffers — no graph changes, no HAL reconfiguration
    func preloadTones(_ tones: [SoundTone]) {
        cachedBuffers.removeAll()
        for tone in tones {
            guard let buffer = loadBuffer(for: tone) else {
                print("AudioEngine: no audio for '\(tone.name)' (id \(tone.id))")
                continue
            }
            cachedBuffers[tone.id] = buffer
        }
    }

    func play(toneID: Int) {
        guard let buffer = cachedBuffers[toneID], toneID < nodes.count else { return }
        nodes[toneID].scheduleBuffer(buffer, at: nil, options: .interrupts)
    }

    func stopAll() {
        nodes.forEach { $0.stop() }
    }

    // MARK: - Private

    private func loadBuffer(for tone: SoundTone) -> AVAudioPCMBuffer? {
        switch tone.source {
        case .synthesized(let config):
            return ToneGenerator.buffer(config: config)
        case .file(let name):
            return loadFileBuffer(named: name)
        }
    }

    private func loadFileBuffer(named name: String) -> AVAudioPCMBuffer? {
        let extensions = ["mp3", "caf", "wav", "m4a"]
        guard let url = extensions.lazy.compactMap({
            Bundle.main.url(forResource: name, withExtension: $0)
        }).first else {
            print("AudioEngine: '\(name)' not found in bundle")
            return nil
        }

        guard let audioFile = try? AVAudioFile(forReading: url) else { return nil }
        let fileFormat = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)

        guard let fileBuffer = AVAudioPCMBuffer(pcmFormat: fileFormat, frameCapacity: frameCount),
              (try? audioFile.read(into: fileBuffer)) != nil else { return nil }

        if fileFormat == Self.standardFormat { return fileBuffer }

        // Convert to standard format so every buffer matches the graph's node format
        guard let converter = AVAudioConverter(from: fileFormat, to: Self.standardFormat) else { return nil }
        let outputCapacity = AVAudioFrameCount(
            Double(frameCount) * Self.standardFormat.sampleRate / fileFormat.sampleRate
        )
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: Self.standardFormat,
                                                  frameCapacity: outputCapacity) else { return nil }
        var inputConsumed = false
        let status = converter.convert(to: outputBuffer, error: nil) { _, outStatus in
            if inputConsumed { outStatus.pointee = .endOfStream; return nil }
            inputConsumed = true
            outStatus.pointee = .haveData
            return fileBuffer
        }
        return status != .error ? outputBuffer : nil
    }

    private func startEngine() {
        guard !engine.isRunning else { return }
        do { try engine.start() } catch {
            print("AudioEngine failed to start: \(error)")
        }
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }
}
