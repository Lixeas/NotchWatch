import SwiftUI

/// Icone repliee de la menu bar : barre de progression avec la valeur au centre.
/// Couleur : vert < 50%, orange < 80%, rouge au-dela (limite proche/depassee).
struct MenuBarProgressLabel: View {
    let percentUsed: Double
    let valueText: String
    var overrideColor: Color?

    private let width: CGFloat = 54
    private let height: CGFloat = 16

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: height / 2)
                .fill(Color.primary.opacity(0.12))

            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(barColor)
                    .frame(width: width * fillRatio)
                Spacer(minLength: 0)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: height / 2))

            Text(valueText)
                .font(.hostGroteskBold(10))
                .monospacedDigit()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 1)
        }
        .frame(width: width, height: height)
    }

    private var fillRatio: CGFloat {
        CGFloat(min(max(percentUsed, 0), 1))
    }

    private var barColor: Color {
        overrideColor ?? UsageColor.forPercent(percentUsed)
    }
}
