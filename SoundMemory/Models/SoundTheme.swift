import Foundation

struct SoundDescriptor {
    let name: String
    let source: SoundSource
}

enum SoundTheme: String, CaseIterable, Identifiable, Hashable {
    case musical
    case city
    case animals
    case household

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .musical:   return "pianokeys"
        case .city:      return "building.2.fill"
        case .animals:   return "pawprint.fill"
        case .household: return "house.fill"
        }
    }

    var description: String {
        switch self {
        case .musical:   return "Classic do-re-mi notes across two octaves"
        case .city:      return "Horns, sirens, bells and urban soundscapes"
        case .animals:   return "Barks, chirps, moos and creatures of nature"
        case .household: return "Beeps, buzzes and everyday home appliances"
        }
    }

    // Up to 12 sounds — caller slices to difficulty.pairCount
    var allDescriptors: [SoundDescriptor] {
        switch self {
        case .musical:   return musicalSounds
        case .city:      return citySounds
        case .animals:   return animalSounds
        case .household: return householdSounds
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

// MARK: - City (12 real audio files from Pixabay)

private let citySounds: [SoundDescriptor] = [
    SoundDescriptor(name: "Car Horn",     source: .file("city_car_horn")),
    SoundDescriptor(name: "Double Honk",  source: .file("city_double_honk")),
    SoundDescriptor(name: "Police Siren", source: .file("city_police_siren")),
    SoundDescriptor(name: "Bicycle Bell", source: .file("city_bicycle_bell")),
    SoundDescriptor(name: "Cash Register",source: .file("city_cash_register")),
    SoundDescriptor(name: "Bus Doors",    source: .file("city_bus_doors")),
    SoundDescriptor(name: "Church Bell",  source: .file("city_church_bell")),
    SoundDescriptor(name: "Subway Chime", source: .file("city_subway_chime")),
    SoundDescriptor(name: "Subway Door",  source: .file("city_subway_door")),
    SoundDescriptor(name: "Train Whistle",source: .file("city_train_whistle")),
    SoundDescriptor(name: "Jackhammer",   source: .file("city_jackhammer")),
    SoundDescriptor(name: "Vintage Horn", source: .file("city_vintage_horn")),
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

// MARK: - Household (12 synthesised home appliance sounds)

private let householdSounds: [SoundDescriptor] = [
    // Microwave beep — clean short electronic pip
    SoundDescriptor(name: "Microwave",    source: .synthesized(SynthConfig(layers: [.sine(1000, amp: 0.65)], duration: 0.28, attackTime: 0.005, releaseTime: 0.060))),
    // Doorbell — two-tone resonant chime
    SoundDescriptor(name: "Doorbell",     source: .synthesized(SynthConfig(layers: [.sine(587, amp: 0.70), .sine(494, amp: 0.40)], duration: 0.85, attackTime: 0.005, releaseTime: 0.500))),
    // Alarm clock — pulsed buzzing beep
    SoundDescriptor(name: "Alarm",        source: .synthesized(SynthConfig(layers: [.pulsedSine(880, pulseRate: 4, amp: 0.75)], duration: 0.80, attackTime: 0.010, releaseTime: 0.060))),
    // Kettle — rising steam whistle sweep
    SoundDescriptor(name: "Kettle",       source: .synthesized(SynthConfig(layers: [.sweep(from: 700, to: 1500, amp: 0.70)], duration: 0.80, attackTime: 0.080, releaseTime: 0.120))),
    // Phone ring — FM-modulated classic ring tone
    SoundDescriptor(name: "Phone",        source: .synthesized(SynthConfig(layers: [.fm(carrier: 480, depth: 60, rate: 25, amp: 0.70)], duration: 0.70, attackTime: 0.015, releaseTime: 0.100))),
    // Smoke alarm — shrill high-pitched pulsed beep
    SoundDescriptor(name: "Smoke Alarm",  source: .synthesized(SynthConfig(layers: [.pulsedSine(3000, pulseRate: 3, amp: 0.55)], duration: 0.80, attackTime: 0.005, releaseTime: 0.060))),
    // Blender — fast pulsed mechanical noise
    SoundDescriptor(name: "Blender",      source: .synthesized(SynthConfig(layers: [.pulsedNoise(pulseRate: 30, amp: 0.75)], duration: 0.65, attackTime: 0.020, releaseTime: 0.080))),
    // Washing machine — low-frequency rumble
    SoundDescriptor(name: "Washer",       source: .synthesized(SynthConfig(layers: [.sine(55, amp: 0.55), .noise(amp: 0.25)], duration: 0.80, attackTime: 0.120, releaseTime: 0.150))),
    // Clock tick — sharp percussive transient
    SoundDescriptor(name: "Clock Tick",   source: .synthesized(SynthConfig(layers: [.noise(amp: 0.80)], duration: 0.07, attackTime: 0.002, releaseTime: 0.025))),
    // Vacuum cleaner — mid-range drone with noise
    SoundDescriptor(name: "Vacuum",       source: .synthesized(SynthConfig(layers: [.noise(amp: 0.50), .sine(260, amp: 0.35)], duration: 0.75, attackTime: 0.150, releaseTime: 0.180))),
    // Dryer end-of-cycle buzz — FM buzz tone
    SoundDescriptor(name: "Dryer Buzz",   source: .synthesized(SynthConfig(layers: [.fm(carrier: 200, depth: 130, rate: 40, amp: 0.78)], duration: 0.55, attackTime: 0.008, releaseTime: 0.060))),
    // Coffee maker — low burble with slow pulsed noise
    SoundDescriptor(name: "Coffee Maker", source: .synthesized(SynthConfig(layers: [.sine(120, amp: 0.42), .pulsedNoise(pulseRate: 5, amp: 0.45)], duration: 0.75, attackTime: 0.060, releaseTime: 0.100))),
]
