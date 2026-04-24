import Foundation

struct SoundTone: Hashable, Identifiable {
    let id: Int
    let name: String
    let config: SynthConfig
}
