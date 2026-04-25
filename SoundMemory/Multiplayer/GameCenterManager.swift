import GameKit
import SwiftUI

// MARK: - Events published to the game layer

enum OnlineMatchEvent: Equatable {
    case gameSetup(GameSetupPayload)
    case cardTapped(Int)
    case playerDisconnected

    static func == (lhs: OnlineMatchEvent, rhs: OnlineMatchEvent) -> Bool {
        switch (lhs, rhs) {
        case (.cardTapped(let a), .cardTapped(let b)): return a == b
        case (.playerDisconnected, .playerDisconnected): return true
        case (.gameSetup, .gameSetup): return false  // always treat as new
        default: return false
        }
    }
}

// MARK: - Manager

@MainActor
final class GameCenterManager: NSObject, ObservableObject {

    @Published private(set) var isAuthenticated = false
    @Published private(set) var localPlayerName = ""
    @Published var latestEvent: OnlineMatchEvent?

    private(set) var match: GKMatch?
    private(set) var isHost = false
    private(set) var opponentDisplayName = "Opponent"

    // MARK: Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, _ in
            Task { @MainActor [weak self] in
                if let vc = viewController {
                    UIApplication.shared.topViewController?.present(vc, animated: true)
                } else if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                    self?.localPlayerName = GKLocalPlayer.local.displayName
                } else {
                    self?.isAuthenticated = false
                }
            }
        }
    }

    // MARK: Match lifecycle

    func startMatch(_ match: GKMatch, isHost: Bool) {
        self.match = match
        self.isHost = isHost
        self.opponentDisplayName = match.players.first?.displayName ?? "Opponent"
        match.delegate = self
        latestEvent = nil
    }

    func send(_ message: MatchMessage) {
        guard let match else { return }
        let data = message.encode()
        try? match.sendData(toAllPlayers: data, with: .reliable)
    }

    func endMatch() {
        match?.disconnect()
        match = nil
        latestEvent = nil
    }
}

// MARK: - GKMatchDelegate (called on background thread → dispatch to MainActor)

extension GameCenterManager: GKMatchDelegate {

    nonisolated func match(_ match: GKMatch,
                           didReceive data: Data,
                           fromRemotePlayer player: GKPlayer) {
        guard let message = MatchMessage.decode(from: data) else { return }
        Task { @MainActor [weak self] in
            switch message.type {
            case .gameSetup:
                if let payload = message.gameSetupPayload() {
                    self?.latestEvent = .gameSetup(payload)
                }
            case .cardTapped:
                if let payload = message.cardTappedPayload() {
                    self?.latestEvent = .cardTapped(payload.cardIndex)
                }
            }
        }
    }

    nonisolated func match(_ match: GKMatch,
                           player: GKPlayer,
                           didChange state: GKPlayerConnectionState) {
        if state == .disconnected {
            Task { @MainActor [weak self] in
                self?.latestEvent = .playerDisconnected
            }
        }
    }
}

// MARK: - UIApplication helper

private extension UIApplication {
    var topViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMost
    }
}

private extension UIViewController {
    var topMost: UIViewController {
        if let presented = presentedViewController { return presented.topMost }
        if let nav = self as? UINavigationController { return nav.visibleViewController?.topMost ?? self }
        return self
    }
}
