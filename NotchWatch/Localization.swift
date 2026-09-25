import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case en, fr

    var id: String { rawValue }

    var label: String {
        switch self {
        case .en: return "English"
        case .fr: return "Francais"
        }
    }
}

/// Choix de langue explicite de l'utilisateur (independant de la locale systeme).
/// Par defaut EN. Persiste en UserDefaults.
final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    private static let key = "NotchWatch.language"

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Self.key) }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.key)
        language = saved.flatMap(AppLanguage.init(rawValue:)) ?? .en
    }
}

enum Strings {
    static func refresh(_ l: AppLanguage) -> String {
        l == .en ? "Refresh" : "Rafraichir"
    }

    static func refreshAccessibilityLabel(_ l: AppLanguage) -> String {
        l == .en ? "Refresh usage" : "Rafraichir la consommation"
    }

    static func settingsButton(_ l: AppLanguage) -> String {
        l == .en ? "Settings..." : "Reglages..."
    }

    static func quitButton(_ l: AppLanguage) -> String {
        l == .en ? "Quit" : "Quitter"
    }

    static func extraUsageDisabled(_ l: AppLanguage) -> String {
        l == .en ? "Extra credits not enabled on this account." : "Credits supplementaires non actives sur ce compte."
    }

    static func consumptionLabel(_ l: AppLanguage) -> String {
        l == .en ? "Usage:" : "Consommation :"
    }

    static func fiveHourWindowLabel(_ l: AppLanguage) -> String {
        l == .en ? "5h window:" : "Fenetre 5h :"
    }

    // Anthropic's usage API does not return real billing-period dates (extra_usage has no
    // period_start/period_end) -- this is a calendar-month approximation, labeled as such.
    static func billingCycleLabel(_ l: AppLanguage) -> String {
        l == .en ? "Billing cycle (est.):" : "Cycle facturation (estim.) :"
    }

    static func sevenDayWindowLabel(_ l: AppLanguage) -> String {
        l == .en ? "7d window:" : "Fenetre 7j :"
    }

    static func authTokenTitle(_ l: AppLanguage) -> String {
        l == .en ? "Authentication Token" : "Jeton d'authentification"
    }

    static func authTokenDescription(_ l: AppLanguage) -> String {
        l == .en
            ? "If the token retrieved automatically (Claude Code) has expired, paste a valid access token here. Clear the field to go back to the automatic token. Saved automatically."
            : "Si le jeton recupere automatiquement (Claude Code) a expire, collez ici un jeton d'acces valide. Videz le champ pour revenir au jeton automatique. Enregistre automatiquement."
    }

    static func autoRefreshTitle(_ l: AppLanguage) -> String {
        l == .en ? "Automatic Refresh" : "Rafraichissement automatique"
    }

    static func intervalLabel(_ l: AppLanguage) -> String {
        l == .en ? "Interval:" : "Intervalle :"
    }

    static func startupTitle(_ l: AppLanguage) -> String {
        l == .en ? "Startup" : "Demarrage"
    }

    static func launchAtLoginLabel(_ l: AppLanguage) -> String {
        l == .en ? "Launch NotchWatch at login" : "Lancer NotchWatch a l'ouverture de session"
    }

    static func languageTitle(_ l: AppLanguage) -> String {
        l == .en ? "Language" : "Langue"
    }

    static func versionLabel(_ version: String, _ l: AppLanguage) -> String {
        "NotchWatch \u{2022} version \(version)"
    }

    static func tokenErrorPrefix(_ message: String, _ l: AppLanguage) -> String {
        l == .en ? "Token error: \(message)" : "Erreur jeton : \(message)"
    }

    static func startupErrorPrefix(_ message: String, _ l: AppLanguage) -> String {
        l == .en ? "Startup error: \(message)" : "Erreur demarrage auto : \(message)"
    }

    static func notConnected(_ l: AppLanguage) -> String {
        l == .en ? "Not signed in. Run `claude login` in the terminal." : "Non connecte. Lancez `claude login` dans le terminal."
    }

    static func tokenUnreadable(_ l: AppLanguage) -> String {
        l == .en ? "Unreadable token. Run `claude login` again." : "Jeton illisible. Relancez `claude login`."
    }

    static func keychainErrorCode(_ status: Int32, _ l: AppLanguage) -> String {
        l == .en ? "Keychain error (code \(status))." : "Erreur Trousseau (code \(status))."
    }

    static func networkErrorPrefix(_ message: String, _ l: AppLanguage) -> String {
        l == .en ? "Network error: \(message)" : "Erreur reseau : \(message)"
    }

    static func tokenInvalidOrExpired(_ l: AppLanguage) -> String {
        l == .en
            ? "Invalid or expired token. Run `claude login` again, or paste a new token in Settings."
            : "Jeton invalide ou expire. Relancez `claude login`, ou collez un nouveau jeton dans Reglages."
    }

    static func rateLimited(_ l: AppLanguage) -> String {
        l == .en ? "Rate limit reached (429). Try again later." : "Limite atteinte (429). Reessayez plus tard."
    }

    static func serverErrorCode(_ code: Int, _ l: AppLanguage) -> String {
        l == .en ? "The server responded with code \(code)." : "Le serveur a repondu avec le code \(code)."
    }

    static func pillErrorLabel(_ message: String, _ l: AppLanguage) -> String {
        l == .en ? "NotchWatch, error: \(message)" : "NotchWatch, erreur : \(message)"
    }

    static func pillUsageLabel(percent: Int, used: String, limit: String, _ l: AppLanguage) -> String {
        l == .en
            ? "NotchWatch, \(percent) percent of credits used, \(used) dollars of \(limit)"
            : "NotchWatch, \(percent) pourcent des credits utilises, \(used) dollars sur \(limit)"
    }
}
