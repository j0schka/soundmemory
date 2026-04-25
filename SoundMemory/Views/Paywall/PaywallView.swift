import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var env: AppEnvironment
    /// Called after a successful purchase so the caller can proceed directly.
    let onPurchased: () -> Void
    /// Called for "Maybe Later" — navigates back to Home.
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.coral)
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 28)

                // Headline
                Text("Daily limit reached")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appNavy)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                // Body
                Text("You've played \(SubscriptionManager.freeLimit) rounds today.\nGo Premium for unlimited play every day.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.navyLight)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)

                // Perks list
                VStack(alignment: .leading, spacing: 12) {
                    perkRow(icon: "infinity", text: "Unlimited rounds per day")
                    perkRow(icon: "music.note.list", text: "All 4 themes")
                    perkRow(icon: "iphone.and.arrow.forward", text: "All game modes")
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

                // Subscribe button
                subscribeButton

                // Restore / Maybe Later
                Button {
                    Task { await env.subscriptionManager.restorePurchases() }
                } label: {
                    Text("Restore Purchase")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.navyLight)
                        .padding(.vertical, 8)
                }

                Button(action: onDismiss) {
                    Text("Maybe Later")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.muted)
                        .padding(.vertical, 8)
                }

                Spacer(minLength: 24)
            }
        }
        .onChange(of: env.subscriptionManager.isSubscribed) { subscribed in
            if subscribed { onPurchased() }
        }
    }

    // MARK: - Subscribe button

    @ViewBuilder
    private var subscribeButton: some View {
        let sub = env.subscriptionManager
        Button {
            Task { await sub.purchase() }
        } label: {
            ZStack {
                if sub.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Subscribe — $0.99 / month")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(Color.coral)
            .clipShape(Capsule())
            .shadow(color: Color.coral.opacity(0.35), radius: 6, x: 0, y: 4)
        }
        .disabled(sub.isLoading)
        .padding(.horizontal, 40)
        .padding(.bottom, 8)

        if let error = sub.purchaseError {
            Text(error)
                .font(.system(size: 13))
                .foregroundStyle(Color.coral)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Perk row

    private func perkRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.coral)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Color.appNavy)
        }
    }
}

#Preview {
    PaywallView(onPurchased: {}, onDismiss: {})
        .environmentObject(AppEnvironment())
}
