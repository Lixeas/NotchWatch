import SwiftUI

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
}

enum UsageColor {
    static let green = Color(hex: "48655D")
    static let orange = Color(hex: "F09E7F")
    static let red = Color(hex: "D61B66")

    static func forPercent(_ percent: Double) -> Color {
        switch percent {
        case ..<0.5: return green
        case 0.5..<0.8: return orange
        default: return red
        }
    }
}
