import Foundation

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var elapsedSeconds: Int = 0

    private var task: Task<Void, Never>?

    func start() {
        guard task == nil else { return }
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if !Task.isCancelled {
                    elapsedSeconds += 1
                }
            }
        }
    }

    func pause() {
        task?.cancel()
        task = nil
    }

    func resume() {
        pause()
        start()
    }

    func stop() {
        pause()
    }

    func reset() {
        pause()
        elapsedSeconds = 0
    }

    var displayString: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
