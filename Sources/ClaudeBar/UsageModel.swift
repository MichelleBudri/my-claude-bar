import Foundation

@MainActor
final class UsageModel: ObservableObject {
    @Published private(set) var usage: Usage?
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdated: Date?

    private let refreshInterval: TimeInterval = 120
    private var timer: Timer?

    init() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    var menuBarTitle: String {
        if let session = usage?.session { return "\(session.percent)%" }
        return errorMessage == nil ? "…" : "!"
    }

    var level: UsageLevel {
        guard let session = usage?.session else { return .normal }
        return UsageLevel(percent: session.percent)
    }

    func refresh() {
        Task {
            do {
                usage = try await UsageService.fetchUsage()
                errorMessage = nil
                lastUpdated = Date()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
