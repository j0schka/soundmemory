import Foundation

struct OscillatorLayer: Hashable {
    var startFreq: Float = 440
    var endFreq: Float = 440     // same as startFreq = no frequency sweep
    var amplitude: Float = 1.0
    var isNoise: Bool = false    // white noise instead of sine
    var fmDepth: Float = 0       // frequency modulation depth in Hz
    var fmRate: Float = 0        // frequency modulation rate in Hz
    var vibratoDepth: Float = 0  // vibrato pitch deviation in Hz
    var vibratoRate: Float = 0   // vibrato rate in Hz
    var pulseRate: Float = 0     // half-wave amplitude gating rate in Hz (0 = none)
}

struct SynthConfig: Hashable {
    var layers: [OscillatorLayer]
    var duration: TimeInterval
    var attackTime: TimeInterval = 0.010
    var releaseTime: TimeInterval = 0.080

    static func tone(_ freq: Float, duration: TimeInterval = 0.7,
                     attack: TimeInterval = 0.010, release: TimeInterval = 0.080) -> SynthConfig {
        SynthConfig(
            layers: [OscillatorLayer(startFreq: freq, endFreq: freq)],
            duration: duration, attackTime: attack, releaseTime: release
        )
    }
}

// MARK: - Convenience factories

extension OscillatorLayer {
    static func sine(_ freq: Float, amp: Float = 1.0) -> OscillatorLayer {
        OscillatorLayer(startFreq: freq, endFreq: freq, amplitude: amp)
    }

    static func sweep(from: Float, to: Float, amp: Float = 1.0) -> OscillatorLayer {
        OscillatorLayer(startFreq: from, endFreq: to, amplitude: amp)
    }

    static func fm(carrier: Float, depth: Float, rate: Float, amp: Float = 1.0) -> OscillatorLayer {
        OscillatorLayer(startFreq: carrier, endFreq: carrier, amplitude: amp,
                        fmDepth: depth, fmRate: rate)
    }

    static func vibrato(freq: Float, depth: Float, rate: Float, amp: Float = 1.0) -> OscillatorLayer {
        OscillatorLayer(startFreq: freq, endFreq: freq, amplitude: amp,
                        vibratoDepth: depth, vibratoRate: rate)
    }

    static func noise(amp: Float = 0.5) -> OscillatorLayer {
        OscillatorLayer(startFreq: 0, endFreq: 0, amplitude: amp, isNoise: true)
    }

    static func pulsedSine(_ freq: Float, pulseRate: Float, amp: Float = 1.0) -> OscillatorLayer {
        OscillatorLayer(startFreq: freq, endFreq: freq, amplitude: amp, pulseRate: pulseRate)
    }

    static func pulsedNoise(pulseRate: Float, amp: Float = 0.5) -> OscillatorLayer {
        OscillatorLayer(startFreq: 0, endFreq: 0, amplitude: amp, isNoise: true, pulseRate: pulseRate)
    }
}
