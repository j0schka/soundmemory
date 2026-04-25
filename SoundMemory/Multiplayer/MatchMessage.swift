import Foundation

// MARK: - Message type tag (first byte of every packet)

enum MessageType: UInt8 {
    case gameSetup  = 1   // host → guest: shuffled deck + theme + difficulty
    case cardTapped = 2   // either → other: card index
}

// MARK: - Payloads (JSON-encoded body after the type byte)

struct GameSetupPayload: Codable {
    let toneIDs: [Int]          // ordered list: toneID for each card position (pairs included)
    let themeName: String       // SoundTheme.rawValue
    let difficultyName: String  // Difficulty.rawValue
}

struct CardTappedPayload: Codable {
    let cardIndex: Int
}

// MARK: - Envelope

struct MatchMessage {
    let type: MessageType
    let body: Data

    // Encode to raw Data for GKMatch.sendData
    func encode() -> Data {
        var packet = Data([type.rawValue])
        packet.append(body)
        return packet
    }

    // Decode from received GKMatch data
    static func decode(from data: Data) -> MatchMessage? {
        guard data.count > 1, let type = MessageType(rawValue: data[0]) else { return nil }
        return MatchMessage(type: type, body: data.dropFirst())
    }

    // Factory helpers
    static func gameSetup(_ payload: GameSetupPayload) -> MatchMessage? {
        guard let body = try? JSONEncoder().encode(payload) else { return nil }
        return MatchMessage(type: .gameSetup, body: body)
    }

    static func cardTapped(index: Int) -> MatchMessage? {
        guard let body = try? JSONEncoder().encode(CardTappedPayload(cardIndex: index)) else { return nil }
        return MatchMessage(type: .cardTapped, body: body)
    }

    // Typed payload accessors
    func gameSetupPayload() -> GameSetupPayload? {
        try? JSONDecoder().decode(GameSetupPayload.self, from: body)
    }

    func cardTappedPayload() -> CardTappedPayload? {
        try? JSONDecoder().decode(CardTappedPayload.self, from: body)
    }
}
