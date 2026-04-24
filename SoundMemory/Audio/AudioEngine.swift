import AVFoundation

@MainActor
final class AudioEngine {
    private let engine = AVAudioEngine()
    private var playerNodes: [Int: AVAudioPlayerNode] = [:]
    private var cachedBuffers: [Int: AVAudioPCMBuffer] = [:]
    private let mixer: AVAudioMixerNode

    init() {
        mixer = engine.mainMixerNode
        configureSession()
    }

    func preloadTones(_ tones: [SoundTone]) {
        engine.stop()
        for node in playerNodes.values { node.stop(); engine.detach(node) }
        playerNodes.removeAll()
        cachedBuffers.removeAll()

        for tone in tones {
            guard let buffer = loadBuffer(for: tone) else {
                print("AudioEngine: missing audio for '\(tone.name)' (id \(tone.id))")
                continue
            }
            cachedBuffers[tone.id] = buffer

            let node = AVAudioPlayerNode()
            engine.attach(node)
            // Connect with the buffer's own format so there is never a mismatch
            engine.connect(node, to: mixer, format: buffer.format)
            playerNodes[tone.id] = node
        }

        startEngine()
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
        }).first else { return nil }

        guard let audioFile = try? AVAudioFile(forReading: url) else { return nil }
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                      frameCapacity: AVAudioFrameCount(audioFile.length))
        guard let buffer else { return nil }
        try? audioFile.read(into: buffer)
        return buffer
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
