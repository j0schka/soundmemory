import AVFoundation

@MainActor
final class AudioEngine {
    private let engine = AVAudioEngine()
    private var playerNodes: [Int: AVAudioPlayerNode] = [:]
    private var cachedBuffers: [Int: AVAudioPCMBuffer] = [:]
    private let mixer: AVAudioMixerNode

    // All buffers and node connections use this format explicitly
    static let bufferFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

    init() {
        mixer = engine.mainMixerNode
        configureSession()
    }

    func preloadTones(_ tones: [SoundTone]) {
        // Detach nodes for tones no longer needed
        let keepIDs = Set(tones.map(\.id))
        for id in playerNodes.keys where !keepIDs.contains(id) {
            playerNodes[id]?.stop()
            if let node = playerNodes[id] { engine.detach(node) }
            playerNodes.removeValue(forKey: id)
            cachedBuffers.removeValue(forKey: id)
        }

        // Stop engine while (re-)connecting nodes to avoid format negotiation issues
        engine.stop()

        for tone in tones {
            cachedBuffers[tone.id] = ToneGenerator.buffer(config: tone.config)
            _ = playerNode(for: tone.id)
        }

        startEngine()
    }

    func play(toneID: Int) {
        guard let buffer = cachedBuffers[toneID] else { return }
        if !engine.isRunning { startEngine() }
        let node = playerNode(for: toneID)
        node.scheduleBuffer(buffer, at: nil, options: .interrupts)
        if !node.isPlaying { node.play() }
    }

    func stopAll() {
        playerNodes.values.forEach { $0.stop() }
    }

    private func playerNode(for id: Int) -> AVAudioPlayerNode {
        if let existing = playerNodes[id] { return existing }
        let node = AVAudioPlayerNode()
        engine.attach(node)
        // Use explicit format so node ↔ buffer format always matches
        engine.connect(node, to: mixer, format: Self.bufferFormat)
        playerNodes[id] = node
        return node
    }

    private func startEngine() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("AudioEngine failed to start: \(error)")
        }
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }
}
