import SwiftUI

/// Icone repliee de la menu bar : pourcentage colore + point + montant, sur un fond neutre
/// fixe (pas de remplissage proportionnel). Le pourcentage exact porte lui-meme le signal de
/// couleur (Regle Jamais-Seule : la couleur n'est jamais seule, le chiffre l'accompagne toujours).
struct MenuBarProgressLabel: View {
    let percentUsed: Double
    let percentText: String
    let valueText: String?
    var overrideColor: Color?

    private let height: CGFloat = 16

    var body: some View {
        HStack(spacing: 4) {
            Text(percentText)
                .foregroundStyle(percentColor)

            if let valueText {
                Text("\u{2022}")
                    .foregroundStyle(Color.primary.opacity(0.35))
                Text(valueText)
                    .foregroundStyle(Color.primary)
            }
        }
        .font(.hostGroteskBold(10))
        .monospacedDigit()
        .padding(.horizontal, 8)
        .frame(height: height)
        .background(Capsule().fill(Color.primary.opacity(0.12)))
        .fixedSize()
    }

    private var percentColor: Color {
        overrideColor ?? UsageColor.textColor(forPercent: percentUsed)
    }
}
