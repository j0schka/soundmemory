import AVFoundation

@MainActor
final class AudioEngine {
    static let standardFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    private static let nodeCount = 12  // covers Hard difficulty (max 12 pairs)

    private let engine = AVAudioEngine()
    private var nodes: [AVAudioPlayerNode] = []   // index == toneID
    private var cachedBuffers: [Int: AVAudioPCMBuffer] = [:]

    init() {
        // Set the category now so it's ready, but do NOT activate the session yet.
        // Activation (and engine start) is deferred to the first play() call so that
        // background audio (Spotify, Podcasts, etc.) is not interrupted on launch.
        configureSession()

        // Build the graph once — never change it again.
        // This does not require an active audio session.
        let mixer = engine.mainMixerNode
        for _ in 0..<Self.nodeCount {
            let node = AVAudioPlayerNode()
            engine.attach(node)
            engine.connect(node, to: mixer, format: Self.standardFormat)
            nodes.append(node)
        }
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
        ensureEngineRunning()
        nodes[toneID].scheduleBuffer(buffer, at: nil, options: .interrupts)
    }

    func stopAll() {
        nodes.forEach { $0.stop() }
        // Relinquish the audio session so background audio (Spotify, Podcasts, etc.)
        // can resume between games.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
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

    /// Activates the audio session and starts the engine + nodes on first play.
    /// Safe to call repeatedly — does nothing if everything is already running.
    private func ensureEngineRunning() {
        if !engine.isRunning {
            try? AVAudioSession.sharedInstance().setActive(true)
            startEngine()
        }
        // Nodes may have been stopped by stopAll() — restart any that aren't running.
        nodes.forEach { if !$0.isPlaying { $0.play() } }
    }

    private func startEngine() {
        guard !engine.isRunning else { return }
        do { try engine.start() } catch {
            print("AudioEngine failed to start: \(error)")
        }
    }

    private func configureSession() {
        // Set category only — do NOT activate the session here.
        // Activation is deferred to ensureEngineRunning() so background audio
        // is not interrupted until the user actually starts playing a sound.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    }
}
