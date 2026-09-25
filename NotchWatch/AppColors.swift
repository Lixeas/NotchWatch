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

    // Variantes texte : chaque couleur de statut n'a un contraste AA (4.5:1) garanti que sur
    // *une* des deux apparences systeme a l'etat brut. L'autre apparence recoit une teinte
    // eclaircie ou assombrie de la meme famille de teinte plutot que la couleur du fill.
    static let greenText = Color.adaptive(light: green, dark: Color(hex: "7FBFA0"))
    static let orangeText = Color.adaptive(light: Color(hex: "A8541F"), dark: orange)
    static let redText = Color.adaptive(light: red, dark: Color(hex: "FF6B9D"))

    static func forPercent(_ percent: Double) -> Color {
        switch percent {
        case ..<0.5: return green
        case 0.5..<0.8: return orange
        default: return red
        }
    }

    /// Version texte de `forPercent`, a utiliser quand la couleur de statut colore un chiffre
    /// (pill, labels) plutot qu'un remplissage : garantit le contraste AA dans les deux modes.
    static func textColor(forPercent percent: Double) -> Color {
        switch percent {
        case ..<0.5: return greenText
        case 0.5..<0.8: return orangeText
        default: return redText
        }
    }
}
