import Foundation

enum AppVersion {
    /// CFBundleShortVersionString, injecte par le workflow de release dans Info.plist.
    /// "dev" quand l'app tourne hors bundle .app (ex: `swift run` en local).
    static let string: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev"
    }()
}
