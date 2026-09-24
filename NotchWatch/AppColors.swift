import SwiftUI
import AppKit

extension Color {
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        s.removeAll { $0 == "#" }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }

    /// Couleur qui bascule selon l'apparence systeme (clair/sombre), independamment de Color.primary.
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? NSColor(dark) : NSColor(light)
        }))
    }
}

enum UsageColor {
    static let green = Color(hex: "48655D")
    static let orange = Color(hex: "F09E7F")
    static let red = Color(hex: "D61B66")

    // Texte uniquement : D61B66 tombe a ~4.2:1 sur fond sombre (sous le seuil AA 4.5:1).
    // Le remplissage (pill, barre de progression) garde `red` tel quel : pas de texte dessus,
    // pas d'exigence de contraste WCAG.
    static let redText = Color.adaptive(light: red, dark: Color(hex: "FF6B9D"))

    static func forPercent(_ percent: Double) -> Color {
        switch percent {
        case ..<0.5: return green
        case 0.5..<0.8: return orange
        default: return red
        }
    }
}
