import Foundation

struct SoundDescriptor {
    let name: String
    let config: SynthConfig
}

enum SoundTheme: String, CaseIterable, Identifiable, Hashable {
    case musical
    case city
    case animals

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .musical:  return "pianokeys"
        case .city:     return "building.2.fill"
        case .animals:  return "pawprint.fill"
        }
    }

    var description: String {
        switch self {
        case .musical:  return "Classic do-re-mi notes across two octaves"
        case .city:     return "Horns, sirens, bells and urban soundscapes"
        case .animals:  return "Barks, chirps, moos and creatures of nature"
        }
    }

    // Up to 12 sounds — caller slices to difficulty.pairCount
    var allDescriptors: [SoundDescriptor] {
        switch self {
        case .musical:  return musicalSounds
        case .city:     return citySounds
        case .animals:  return animalSounds
        }
    }

    func tones(for difficulty: Difficulty) -> [SoundTone] {
        allDescriptors.prefix(difficulty.pairCount).enumerated().map { idx, desc in
            SoundTone(id: idx, name: desc.name, config: desc.config)
        }
    }
}

// MARK: - Musical (12 pure tones on C major, two octaves)

private let musicalSounds: [SoundDescriptor] = [
    SoundDescriptor(name: "Do",   config: .tone(261.63, duration: 0.70)),
    SoundDescriptor(name: "Re",   config: .tone(293.66, duration: 0.70)),
    SoundDescriptor(name: "Mi",   config: .tone(329.63, duration: 0.70)),
    SoundDescriptor(name: "Fa",   config: .tone(349.23, duration: 0.70)),
    SoundDescriptor(name: "Sol",  config: .tone(392.00, duration: 0.70)),
    SoundDescriptor(name: "La",   config: .tone(440.00, duration: 0.70)),
    SoundDescriptor(name: "Si",   config: .tone(493.88, duration: 0.70)),
    SoundDescriptor(name: "Do²",  config: .tone(523.25, duration: 0.70)),
    SoundDescriptor(name: "Re²",  config: .tone(587.33, duration: 0.70)),
    SoundDescriptor(name: "Mi²",  config: .tone(659.25, duration: 0.70)),
    SoundDescriptor(name: "Fa²",  config: .tone(698.46, duration: 0.70)),
    SoundDescriptor(name: "Sol²", config: .tone(783.99, duration: 0.70)),
]

// MARK: - City (12 synthesised urban sounds)

private let citySounds: [SoundDescriptor] = [
    // 1. Car Horn — dual-tone F#4 + Bb4
    SoundDescriptor(name: "Car Horn", config: SynthConfig(
        layers: [.sine(370, amp: 0.55), .sine(466, amp: 0.45)],
        duration: 0.65, attackTime: 0.025, releaseTime: 0.100
    )),
    // 2. Police Siren — FM sweep 770↔960 Hz
    SoundDescriptor(name: "Siren", config: SynthConfig(
        layers: [.fm(carrier: 865, depth: 95, rate: 1.3, amp: 0.9)],
        duration: 0.9, attackTime: 0.020, releaseTime: 0.120
    )),
    // 3. Train Whistle — G5 + octave harmonic
    SoundDescriptor(name: "Train Whistle", config: SynthConfig(
        layers: [.sine(784, amp: 0.65), .sine(1568, amp: 0.25)],
        duration: 0.85, attackTime: 0.050, releaseTime: 0.150
    )),
    // 4. Bicycle Bell — E6 with bright harmonic, fast decay
    SoundDescriptor(name: "Bicycle Bell", config: SynthConfig(
        layers: [.sine(1319, amp: 0.7), .sine(2638, amp: 0.2)],
        duration: 0.55, attackTime: 0.005, releaseTime: 0.450
    )),
    // 5. Subway Rumble — low sine + noise
    SoundDescriptor(name: "Subway", config: SynthConfig(
        layers: [.sine(80, amp: 0.55), .noise(amp: 0.30)],
        duration: 0.70, attackTime: 0.080, releaseTime: 0.120
    )),
    // 6. Jackhammer — noise pulsed at 14 Hz
    SoundDescriptor(name: "Jackhammer", config: SynthConfig(
        layers: [.pulsedNoise(pulseRate: 14, amp: 0.85)],
        duration: 0.70, attackTime: 0.010, releaseTime: 0.060
    )),
    // 7. Cash Register Bell — C6 + harmonics
    SoundDescriptor(name: "Cash Register", config: SynthConfig(
        layers: [.sine(1047, amp: 0.60), .sine(2093, amp: 0.28), .sine(3140, amp: 0.10)],
        duration: 0.60, attackTime: 0.005, releaseTime: 0.380
    )),
    // 8. Street Bell — A5 long ring
    SoundDescriptor(name: "Street Bell", config: SynthConfig(
        layers: [.sine(880, amp: 0.65), .sine(1320, amp: 0.20)],
        duration: 0.90, attackTime: 0.005, releaseTime: 0.500
    )),
    // 9. Taxi Honk — G4 short blast
    SoundDescriptor(name: "Taxi Honk", config: SynthConfig(
        layers: [.sine(392, amp: 0.90)],
        duration: 0.40, attackTime: 0.030, releaseTime: 0.080
    )),
    // 10. Truck Horn — low dual A2 + D3
    SoundDescriptor(name: "Truck Horn", config: SynthConfig(
        layers: [.sine(110, amp: 0.50), .sine(147, amp: 0.45)],
        duration: 0.80, attackTime: 0.040, releaseTime: 0.120
    )),
    // 11. Door Buzzer — buzzy FM on 160 Hz
    SoundDescriptor(name: "Door Buzzer", config: SynthConfig(
        layers: [.fm(carrier: 160, depth: 80, rate: 80, amp: 0.85)],
        duration: 0.50, attackTime: 0.008, releaseTime: 0.060
    )),
    // 12. Steam Hiss — filtered noise slow rise
    SoundDescriptor(name: "Steam Hiss", config: SynthConfig(
        layers: [.noise(amp: 0.80)],
        duration: 0.65, attackTime: 0.120, releaseTime: 0.200
    )),
]

// MARK: - Animals (12 synthesised creature sounds)

private let animalSounds: [SoundDescriptor] = [
    // 1. Dog Bark — low sine + noise burst
    SoundDescriptor(name: "Dog", config: SynthConfig(
        layers: [.sine(200, amp: 0.50), .noise(amp: 0.40)],
        duration: 0.40, attackTime: 0.005, releaseTime: 0.080
    )),
    // 2. Cat Meow — FM carrier 1000 Hz oscillates 800↔1200
    SoundDescriptor(name: "Cat", config: SynthConfig(
        layers: [.fm(carrier: 1000, depth: 200, rate: 1.5, amp: 0.80)],
        duration: 0.70, attackTime: 0.080, releaseTime: 0.150
    )),
    // 3. Bird Chirp — fast sweep 2000 → 3500 Hz
    SoundDescriptor(name: "Bird", config: SynthConfig(
        layers: [.sweep(from: 2000, to: 3500, amp: 0.75)],
        duration: 0.30, attackTime: 0.010, releaseTime: 0.060
    )),
    // 4. Cow Moo — 130 Hz with slow vibrato
    SoundDescriptor(name: "Cow", config: SynthConfig(
        layers: [.vibrato(freq: 130, depth: 8, rate: 3.0, amp: 0.85)],
        duration: 0.90, attackTime: 0.100, releaseTime: 0.200
    )),
    // 5. Frog Croak — 600 Hz pulsed at 8 Hz
    SoundDescriptor(name: "Frog", config: SynthConfig(
        layers: [.pulsedSine(600, pulseRate: 8, amp: 0.80)],
        duration: 0.55, attackTime: 0.010, releaseTime: 0.080
    )),
    // 6. Duck Quack — descending sweep 900 → 450 Hz + noise
    SoundDescriptor(name: "Duck", config: SynthConfig(
        layers: [.sweep(from: 900, to: 450, amp: 0.60), .noise(amp: 0.25)],
        duration: 0.42, attackTime: 0.010, releaseTime: 0.080
    )),
    // 7. Bee Buzz — FM ratio 1:1 on 220 Hz (classic buzzy timbre)
    SoundDescriptor(name: "Bee", config: SynthConfig(
        layers: [.fm(carrier: 220, depth: 110, rate: 220, amp: 0.75)],
        duration: 0.65, attackTime: 0.015, releaseTime: 0.100
    )),
    // 8. Horse Neigh — rising sweep 400 → 1400 Hz with slight tremolo
    SoundDescriptor(name: "Horse", config: SynthConfig(
        layers: [OscillatorLayer(startFreq: 400, endFreq: 1400, amplitude: 0.80,
                                 fmDepth: 20, fmRate: 8)],
        duration: 0.65, attackTime: 0.020, releaseTime: 0.120
    )),
    // 9. Pig Oink — descending sweep 380 → 260 Hz + noise
    SoundDescriptor(name: "Pig", config: SynthConfig(
        layers: [.sweep(from: 380, to: 260, amp: 0.60), .noise(amp: 0.20)],
        duration: 0.42, attackTime: 0.015, releaseTime: 0.100
    )),
    // 10. Owl Hoot — 200 Hz + 400 Hz octave, slow vibrato
    SoundDescriptor(name: "Owl", config: SynthConfig(
        layers: [.vibrato(freq: 200, depth: 5, rate: 5.0, amp: 0.55),
                 .vibrato(freq: 400, depth: 5, rate: 5.0, amp: 0.25)],
        duration: 0.85, attackTime: 0.080, releaseTime: 0.200
    )),
    // 11. Cricket — 3800 Hz pulsed at 20 Hz
    SoundDescriptor(name: "Cricket", config: SynthConfig(
        layers: [.pulsedSine(3800, pulseRate: 20, amp: 0.70)],
        duration: 0.55, attackTime: 0.005, releaseTime: 0.080
    )),
    // 12. Wolf Howl — rising sweep 300 → 700 Hz with vibrato
    SoundDescriptor(name: "Wolf", config: SynthConfig(
        layers: [OscillatorLayer(startFreq: 300, endFreq: 700, amplitude: 0.80,
                                 vibratoDepth: 15, vibratoRate: 5)],
        duration: 1.00, attackTime: 0.100, releaseTime: 0.250
    )),
]
