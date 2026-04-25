import StoreKit
import Foundation

@MainActor
final class SubscriptionManager: ObservableObject {

    // MARK: - Published state

    @Published private(set) var roundsUsedToday: Int = 0
    @Published private(set) var isSubscribed: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var purchaseError: String? = nil

    // MARK: - Constants

    static let freeLimit = 3
    static let productID = "ohrenspiel_monthly"

    // MARK: - Computed helpers

    var canPlay: Bool { isSubscribed || roundsUsedToday < Self.freeLimit }
    var roundsRemaining: Int { isSubscribed ? Int.max : max(0, Self.freeLimit - roundsUsedToday) }
    var roundsRemainingDisplay: String {
        isSubscribed ? "∞" : "\(roundsRemaining)"
    }

    // MARK: - Private

    private let defaults = UserDefaults.standard
    private let roundsKey = "sub_roundsUsedToday"
    private let dateKey   = "sub_lastPlayDate"

    // Long-running task — lives for the app lifetime (no deinit needed)
    private var transactionListenerTask: Task<Void, Never>?

    // MARK: - Init

    init() {
        resetIfNewDay()
        transactionListenerTask = makeTransactionListenerTask()
        Task { await refreshSubscriptionStatus() }
    }

    // MARK: - Round tracking

    /// Call once, just before navigating to GameView or calling resetGame().
    func recordRoundStarted() {
        resetIfNewDay()
        roundsUsedToday += 1
        defaults.set(roundsUsedToday, forKey: roundsKey)
    }

    /// Called on app foreground — resets count if the calendar day has changed.
    func resetIfNewDay() {
        let today = todayString()
        if defaults.string(forKey: dateKey) != today {
            defaults.set(today, forKey: dateKey)
            defaults.set(0, forKey: roundsKey)
            roundsUsedToday = 0
        } else {
            roundsUsedToday = defaults.integer(forKey: roundsKey)
        }
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: Date())
    }

    // MARK: - Purchase

    func purchase() async {
        purchaseError = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [Self.productID])
            guard let product = products.first else {
                purchaseError = "Product unavailable. Try again later."
                return
            }
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let tx) = verification {
                    await tx.finish()
                    isSubscribed = true
                } else {
                    purchaseError = "Purchase could not be verified."
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Your purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        purchaseError = nil
        isLoading = true
        defer { isLoading = false }
        await refreshSubscriptionStatus()
        if !isSubscribed {
            purchaseError = "No active subscription found."
        }
    }

    // MARK: - Subscription status

    func refreshSubscriptionStatus() async {
        var found = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result,
               tx.productID == Self.productID,
               tx.revocationDate == nil {
                found = true
                break
            }
        }
        isSubscribed = found
    }

    // MARK: - Transaction listener

    private func makeTransactionListenerTask() -> Task<Void, Never> {
        // Detached so it doesn't inherit @MainActor and can iterate freely.
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let tx) = result {
                    await tx.finish()
                    await self?.refreshSubscriptionStatus()
                }
            }
        }
    }
}
