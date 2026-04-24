import AVFoundation

enum ToneGenerator {

    static func buffer(config: SynthConfig, sampleRate: Double = 44100) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(max(1, sampleRate * config.duration))
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        let data = buffer.floatChannelData![0]
        let sr = Float(sampleRate)
        let total = Int(frameCount)

        // Zero-initialise
        for i in 0..<total { data[i] = 0 }

        for layer in config.layers {
            var phase: Float = 0
            for i in 0..<total {
                let t = Float(i) / sr
                let progress = total > 1 ? Float(i) / Float(total - 1) : 0.0
                let env = envelope(frame: i, total: total,
                                   attackTime: config.attackTime,
                                   releaseTime: config.releaseTime,
                                   sampleRate: sr)

                // Instantaneous frequency with sweep, FM, and vibrato
                let sweep = layer.startFreq + (layer.endFreq - layer.startFreq) * progress
                let fm = layer.fmDepth > 0 ? layer.fmDepth * sin(2 * .pi * layer.fmRate * t) : 0
                let vib = layer.vibratoDepth > 0 ? layer.vibratoDepth * sin(2 * .pi * layer.vibratoRate * t) : 0
                let instFreq = max(1, sweep + fm + vib)

                phase += 2 * .pi * instFreq / sr

                let raw: Float = layer.isNoise ? Float.random(in: -1...1) : sin(phase)

                // Half-wave pulse gate for rhythmic effects
                let gate: Float = layer.pulseRate > 0 ? max(0, sin(2 * .pi * layer.pulseRate * t)) : 1.0

                data[i] += raw * layer.amplitude * env * gate
            }
        }

        // Normalise to peak 0.9 to avoid clipping from layer summation
        var peak: Float = 0
        for i in 0..<total { peak = max(peak, abs(data[i])) }
        if peak > 0.9 {
            let scale = 0.9 / peak
            for i in 0..<total { data[i] *= scale }
        }

        return buffer
    }

    private static func envelope(frame: Int, total: Int,
                                 attackTime: TimeInterval, releaseTime: TimeInterval,
                                 sampleRate: Float) -> Float {
        let attackFrames = Int(attackTime * Double(sampleRate))
        let releaseFrames = Int(releaseTime * Double(sampleRate))
        let sustainEnd = max(attackFrames, total - releaseFrames)

        switch frame {
        case 0..<attackFrames:
            return attackFrames > 0 ? Float(frame) / Float(attackFrames) : 1.0
        case attackFrames..<sustainEnd:
            return 1.0
        default:
            let fromEnd = total - frame
            return releaseFrames > 0 ? max(0, Float(fromEnd) / Float(releaseFrames)) : 0.0
        }
    }
}
