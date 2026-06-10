import SwiftUI

@main
struct SoundMemoryApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(env)
                .task { env.gcManager.authenticate() }
                .onReceive(NotificationCenter.default.publisher(for: UIScene.didActivateNotification)) { _ in
                    // Give GKManager a valid window anchor as soon as the scene is ready
                    env.gcManager.presentationAnchor = UIApplication.shared
                        .connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .flatMap { $0.windows }
                        .first { $0.isKeyWindow }
                }
        }
    }
}
