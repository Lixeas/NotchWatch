import SwiftUI
import AppKit

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

    // Pill pre-rendu, recalcule uniquement quand la valeur affichee change (fin de fetchUsage),
    // pas a chaque evaluation de body SwiftUI (isLoading bascule 2x par cycle de refresh sans
    // que le contenu du pill change).
    @Published private(set) var pillImage: NSImage

    private let keychainManager = KeychainManager()
    private let apiService = APIService()
    private var refreshTask: Task<Void, Never>?
    private static let refreshIntervalKey = "NotchWatch.refreshIntervalSeconds"

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
        pillImage = NSImage()
        updatePillImage()
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
            errorMessage = Strings.networkErrorPrefix(error.localizedDescription, LanguageManager.shared.language)
        }

        isLoading = false
        updatePillImage()
    }

    /// Description lue par VoiceOver pour l'icone de la barre de menu (seul affichage permanent
    /// du produit : sans ce label, l'info centrale de NotchWatch est invisible au lecteur d'ecran).
    var pillAccessibilityLabel: String {
        let lang = LanguageManager.shared.language
        if let errorMessage {
            return Strings.pillErrorLabel(errorMessage, lang)
        }
        let percent = Int((percentUsed * 100).rounded())
        return Strings.pillUsageLabel(
            percent: percent,
            used: String(format: "%.2f", used),
            limit: String(format: "%.2f", limit),
            lang
        )
    }

    private func updatePillImage() {
        let pill: MenuBarProgressLabel
        if errorMessage != nil {
            pill = MenuBarProgressLabel(percentUsed: 1, percentText: "!", valueText: nil, overrideColor: UsageColor.red)
        } else {
            let percent = Int((percentUsed * 100).rounded())
            pill = MenuBarProgressLabel(
                percentUsed: percentUsed,
                percentText: "\(percent)%",
                valueText: String(format: "$%.2f", used)
            )
        }
        let renderer = ImageRenderer(content: pill)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
        let image = renderer.nsImage ?? NSImage()
        image.isTemplate = false // sinon la barre de menus aplatit l'image en monochrome
        pillImage = image
    }

    private static func message(for error: KeychainError) -> String {
        let lang = LanguageManager.shared.language
        switch error {
        case .itemNotFound:
            return Strings.notConnected(lang)
        case .invalidData:
            return Strings.tokenUnreadable(lang)
        case .unexpectedStatus(let status):
            return Strings.keychainErrorCode(status, lang)
        }
    }
}