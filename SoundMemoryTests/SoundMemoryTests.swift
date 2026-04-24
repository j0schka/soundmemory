import XCTest
@testable import SoundMemory

final class CardTests: XCTestCase {
    func testShuffledDeckCount() {
        for difficulty in Difficulty.allCases {
            let deck = Card.shuffledDeck(for: difficulty)
            XCTAssertEqual(deck.count, difficulty.cardCount)
        }
    }

    func testShuffledDeckHasPairs() {
        let deck = Card.shuffledDeck(for: .medium)
        for toneID in 0..<Difficulty.medium.pairCount {
            let matching = deck.filter { $0.toneID == toneID }
            XCTAssertEqual(matching.count, 2, "toneID \(toneID) should appear exactly twice")
        }
    }
}

final class ToneGeneratorTests: XCTestCase {
    func testBufferFrameCount() {
        let sampleRate: Double = 44100
        let duration: TimeInterval = 0.7
        let config = SynthConfig.tone(440, duration: duration)
        let buffer = ToneGenerator.buffer(config: config, sampleRate: sampleRate)
        XCTAssertEqual(Int(buffer.frameLength), Int(sampleRate * duration))
    }

    func testNoClipping() {
        let config = SynthConfig.tone(440, duration: 0.5)
        let buffer = ToneGenerator.buffer(config: config)
        let data = buffer.floatChannelData![0]
        for i in 0..<Int(buffer.frameLength) {
            XCTAssertLessThanOrEqual(abs(data[i]), 1.0, "Sample \(i) clips: \(data[i])")
        }
    }

    func testMultiLayerNoClipping() {
        // Car horn — two sine layers summed
        let config = SynthConfig(
            layers: [.sine(370, amp: 0.55), .sine(466, amp: 0.45)],
            duration: 0.5
        )
        let buffer = ToneGenerator.buffer(config: config)
        let data = buffer.floatChannelData![0]
        for i in 0..<Int(buffer.frameLength) {
            XCTAssertLessThanOrEqual(abs(data[i]), 1.0, "Multi-layer sample \(i) clips: \(data[i])")
        }
    }

    func testAllThemeSoundsGenerateBuffers() {
        for theme in SoundTheme.allCases {
            let tones = theme.tones(for: .hard) // hard = all 12 sounds
            XCTAssertEqual(tones.count, 12)
            for tone in tones {
                let buffer = ToneGenerator.buffer(config: tone.config)
                XCTAssertGreaterThan(buffer.frameLength, 0, "\(theme.displayName)/\(tone.name) produced empty buffer")
            }
        }
    }
}

@MainActor
final class GameStateTests: XCTestCase {
    func testGameOverWhenAllMatched() {
        var state = GameState(
            cards: Card.shuffledDeck(for: .easy),
            players: [Player(id: 1), Player(id: 2)],
            difficulty: .easy,
            theme: .musical
        )
        XCTAssertFalse(state.isGameOver)
        for i in state.cards.indices {
            state.cards[i].isMatched = true
        }
        XCTAssertTrue(state.isGameOver)
    }

    func testWinnerIsHigherScore() {
        let state = GameState(
            cards: [],
            players: [Player(id: 1, matchedPairCount: 3), Player(id: 2, matchedPairCount: 1)],
            difficulty: .easy,
            theme: .musical
        )
        XCTAssertEqual(state.winner?.id, 1)
    }

    func testTieHasNoWinner() {
        let state = GameState(
            cards: [],
            players: [Player(id: 1, matchedPairCount: 2), Player(id: 2, matchedPairCount: 2)],
            difficulty: .easy,
            theme: .musical
        )
        XCTAssertNil(state.winner)
    }
}

final class SoundThemeTests: XCTestCase {
    func testAllThemesHave12Descriptors() {
        for theme in SoundTheme.allCases {
            XCTAssertEqual(theme.allDescriptors.count, 12,
                           "\(theme.displayName) should have exactly 12 sound descriptors")
        }
    }

    func testTonesSlicedByDifficulty() {
        for theme in SoundTheme.allCases {
            for difficulty in Difficulty.allCases {
                let tones = theme.tones(for: difficulty)
                XCTAssertEqual(tones.count, difficulty.pairCount)
            }
        }
    }
}
