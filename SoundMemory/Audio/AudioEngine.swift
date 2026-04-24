import AVFoundation

@MainActor
final class AudioEngine {
    // Single format used for every player node — keeps the engine graph uniform
    static let standardFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

    private let engine = AVAudioEngine()
    private var playerNodes: [Int: AVAudioPlayerNode] = [:]
    private var cachedBuffers: [Int: AVAudioPCMBuffer] = [:]
    private let mixer: AVAudioMixerNode

    init() {
        mixer = engine.mainMixerNode
        configureSession()
    }

    func preloadTones(_ tones: [SoundTone]) {
        for node in playerNodes.values { node.stop(); engine.detach(node) }
        playerNodes.removeAll()
        cachedBuffers.removeAll()

        for tone in tones {
            guard let buffer = loadBuffer(for: tone) else {
                print("AudioEngine: no audio for '\(tone.name)' (id \(tone.id))")
                continue
            }
            cachedBuffers[tone.id] = buffer
            let node = AVAudioPlayerNode()
            engine.attach(node)
            // All nodes use the same format — no mixed-format graph issues
            engine.connect(node, to: mixer, format: Self.standardFormat)
            playerNodes[tone.id] = node
        }

        if !engine.isRunning { startEngine() }
    }

    func play(toneID: Int) {
        guard let buffer = cachedBuffers[toneID],
              let node = playerNodes[toneID] else { return }
        if !engine.isRunning { startEngine() }
        node.scheduleBuffer(buffer, at: nil, options: .interrupts)
        if !node.isPlaying { node.play() }
    }

    func stopAll() {
        playerNodes.values.forEach { $0.stop() }
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

        // Read the file in its native format first
        let fileFormat = audioFile.processingFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        guard let fileBuffer = AVAudioPCMBuffer(pcmFormat: fileFormat, frameCapacity: frameCount) else { return nil }
        guard (try? audioFile.read(into: fileBuffer)) != nil else { return nil }

        // If already in standard format, use directly
        if fileFormat == Self.standardFormat { return fileBuffer }

        // Otherwise convert to standard format so all nodes share one format
        guard let converter = AVAudioConverter(from: fileFormat, to: Self.standardFormat) else { return nil }
        let outputCapacity = AVAudioFrameCount(
            Double(frameCount) * Self.standardFormat.sampleRate / fileFormat.sampleRate
        )
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: Self.standardFormat,
                                                  frameCapacity: outputCapacity) else { return nil }
        var inputConsumed = false
        let status = converter.convert(to: outputBuffer, error: nil) { _, outStatus in
            if inputConsumed {
                outStatus.pointee = .endOfStream
                return nil
            }
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
