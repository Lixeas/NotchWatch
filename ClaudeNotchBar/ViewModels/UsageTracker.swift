import SwiftUI

@MainActor
class UsageTracker: ObservableObject {
    @Published var used: Double = 0.0
    @Published var limit: Double = 20.0
    @Published var percentUsed: Double = 0.0
    @Published var extraUsageEnabled = true
    @Published var fiveHourUtilization: Double?
    @Published var sevenDayUtilization: Double?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let keychainManager = KeychainManager()
    private let apiService = APIService()
    private var refreshTask: Task<Void, Never>?
    private static let refreshIntervalKey = "ClaudeNotchBar.refreshIntervalSeconds"

    /// Secondes entre deux rafraichissements auto. Modifiable depuis Reglages ; persiste en UserDefaults.
    @Published var refreshInterval: Int {
        didSet {
            guard oldValue != refreshInterval else { return }
            UserDefaults.standard.set(refreshInterval, forKey: Self.refreshIntervalKey)
            restartAutoRefresh()
        }
    }

    init() {
        let saved = UserDefaults.standard.integer(forKey: Self.refreshIntervalKey)
        refreshInterval = saved > 0 ? saved : 60
    }

    func startAutoRefresh() {
        guard refreshTask == nil else { return }
        scheduleRefreshLoop()
    }

    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    private func restartAutoRefresh() {
        guard refreshTask != nil else { return }
        refreshTask?.cancel()
        refreshTask = nil
        scheduleRefreshLoop()
    }

    private func scheduleRefreshLoop() {
        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.fetchUsage()
                let seconds = max(self.refreshInterval, 5)
                try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
            }
        }
    }

    func fetchUsage() async {
        isLoading = true
        errorMessage = nil

        do {
            let token = try keychainManager.resolveAccessToken()
            let usage = try await apiService.fetchUsage(token: token)

            fiveHourUtilization = usage.fiveHour?.utilization
            sevenDayUtilization = usage.sevenDay?.utilization

            if let extra = usage.extraUsage {
                extraUsageEnabled = extra.isEnabled
                used = extra.usedUSD
                limit = extra.limitUSD
                percentUsed = extra.percentUsed
            } else {
                extraUsageEnabled = false
            }
        } catch let error as KeychainError {
            errorMessage = Self.message(for: error)
        } catch let error as APIServiceError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Erreur reseau : \(error.localizedDescription)"
        }

        isLoading = false
    }

    private static func message(for error: KeychainError) -> String {
        switch error {
        case .itemNotFound:
            return "Non connecte. Lancez `claude login` dans le terminal."
        case .invalidData:
            return "Jeton illisible. Relancez `claude login`."
        case .unexpectedStatus(let status):
            return "Erreur Trousseau (code \(status))."
        }
    }
}