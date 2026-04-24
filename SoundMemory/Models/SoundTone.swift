import Foundation

enum SoundSource: Hashable {
    case synthesized(SynthConfig)
    case file(String)  // resource name in bundle without extension; tries .mp3, .caf, .wav
}

struct SoundTone: Hashable, Identifiable {
    let id: Int
    let name: String
    let source: SoundSource
}
