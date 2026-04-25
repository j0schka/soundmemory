import SwiftUI

@main
struct SoundMemoryApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(env)
                .task { env.gcManager.authenticate() }
        }
    }
}
