import Foundation

struct SoundDescriptor {
    let name: String
    let source: SoundSource
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
            SoundTone(id: idx, name: desc.name, source: desc.source)
        }
    }
}

// MARK: - Musical (12 pure tones on C major, two octaves)

private let musicalSounds: [SoundDescriptor] = [
    SoundDescriptor(name: "Do",   source: .synthesized(.tone(261.63, duration: 0.70))),
    SoundDescriptor(name: "Re",   source: .synthesized(.tone(293.66, duration: 0.70))),
    SoundDescriptor(name: "Mi",   source: .synthesized(.tone(329.63, duration: 0.70))),
    SoundDescriptor(name: "Fa",   source: .synthesized(.tone(349.23, duration: 0.70))),
    SoundDescriptor(name: "Sol",  source: .synthesized(.tone(392.00, duration: 0.70))),
    SoundDescriptor(name: "La",   source: .synthesized(.tone(440.00, duration: 0.70))),
    SoundDescriptor(name: "Si",   source: .synthesized(.tone(493.88, duration: 0.70))),
    SoundDescriptor(name: "Do²",  source: .synthesized(.tone(523.25, duration: 0.70))),
    SoundDescriptor(name: "Re²",  source: .synthesized(.tone(587.33, duration: 0.70))),
    SoundDescriptor(name: "Mi²",  source: .synthesized(.tone(659.25, duration: 0.70))),
    SoundDescriptor(name: "Fa²",  source: .synthesized(.tone(698.46, duration: 0.70))),
    SoundDescriptor(name: "Sol²", source: .synthesized(.tone(783.99, duration: 0.70))),
]

// MARK: - City (12 synthesised urban sounds)

private let citySounds: [SoundDescriptor] = [
    SoundDescriptor(name: "Car Horn",     source: .synthesized(SynthConfig(layers: [.sine(370, amp: 0.55), .sine(466, amp: 0.45)], duration: 0.65, attackTime: 0.025, releaseTime: 0.100))),
    SoundDescriptor(name: "Siren",        source: .synthesized(SynthConfig(layers: [.fm(carrier: 865, depth: 95, rate: 1.3, amp: 0.9)], duration: 0.9, attackTime: 0.020, releaseTime: 0.120))),
    SoundDescriptor(name: "Train",        source: .synthesized(SynthConfig(layers: [.sine(784, amp: 0.65), .sine(1568, amp: 0.25)], duration: 0.85, attackTime: 0.050, releaseTime: 0.150))),
    SoundDescriptor(name: "Bicycle Bell", source: .synthesized(SynthConfig(layers: [.sine(1319, amp: 0.7), .sine(2638, amp: 0.2)], duration: 0.55, attackTime: 0.005, releaseTime: 0.450))),
    SoundDescriptor(name: "Subway",       source: .synthesized(SynthConfig(layers: [.sine(80, amp: 0.55), .noise(amp: 0.30)], duration: 0.70, attackTime: 0.080, releaseTime: 0.120))),
    SoundDescriptor(name: "Jackhammer",   source: .synthesized(SynthConfig(layers: [.pulsedNoise(pulseRate: 14, amp: 0.85)], duration: 0.70, attackTime: 0.010, releaseTime: 0.060))),
    SoundDescriptor(name: "Cash Register",source: .synthesized(SynthConfig(layers: [.sine(1047, amp: 0.60), .sine(2093, amp: 0.28), .sine(3140, amp: 0.10)], duration: 0.60, attackTime: 0.005, releaseTime: 0.380))),
    SoundDescriptor(name: "Street Bell",  source: .synthesized(SynthConfig(layers: [.sine(880, amp: 0.65), .sine(1320, amp: 0.20)], duration: 0.90, attackTime: 0.005, releaseTime: 0.500))),
    SoundDescriptor(name: "Taxi Honk",    source: .synthesized(SynthConfig(layers: [.sine(392, amp: 0.90)], duration: 0.40, attackTime: 0.030, releaseTime: 0.080))),
    SoundDescriptor(name: "Truck Horn",   source: .synthesized(SynthConfig(layers: [.sine(110, amp: 0.50), .sine(147, amp: 0.45)], duration: 0.80, attackTime: 0.040, releaseTime: 0.120))),
    SoundDescriptor(name: "Door Buzzer",  source: .synthesized(SynthConfig(layers: [.fm(carrier: 160, depth: 80, rate: 80, amp: 0.85)], duration: 0.50, attackTime: 0.008, releaseTime: 0.060))),
    SoundDescriptor(name: "Steam Hiss",   source: .synthesized(SynthConfig(layers: [.noise(amp: 0.80)], duration: 0.65, attackTime: 0.120, releaseTime: 0.200))),
]

// MARK: - Animals (12 real audio files bundled in the app)
// Expected files in the app bundle: animal_dog, animal_cat, animal_bird, animal_cow,
// animal_frog, animal_duck, animal_bee, animal_horse, animal_pig, animal_owl,
// animal_cricket, animal_wolf  (.mp3 / .caf / .wav — first match is used)

private let animalSounds: [SoundDescriptor] = [
    SoundDescriptor(name: "Dog",     source: .file("animal_dog")),
    SoundDescriptor(name: "Cat",     source: .file("animal_cat")),
    SoundDescriptor(name: "Bird",    source: .file("animal_bird")),
    SoundDescriptor(name: "Cow",     source: .file("animal_cow")),
    SoundDescriptor(name: "Frog",    source: .file("animal_frog")),
    SoundDescriptor(name: "Duck",    source: .file("animal_duck")),
    SoundDescriptor(name: "Bee",     source: .file("animal_bee")),
    SoundDescriptor(name: "Horse",   source: .file("animal_horse")),
    SoundDescriptor(name: "Pig",     source: .file("animal_pig")),
    SoundDescriptor(name: "Owl",     source: .file("animal_owl")),
    SoundDescriptor(name: "Lion",    source: .file("animal_lion")),
    SoundDescriptor(name: "Wolf",    source: .file("animal_wolf")),
]
