import SwiftUI

/// Barre de progression avec degrade vert -> orange -> rouge, memes seuils que UsageColor
/// (50% / 80%). Remplace ProgressView().tint() qui n'applique pas fiablement la couleur
/// dans ce contexte, et ne permettrait de toute facon pas un degrade (une seule couleur).
struct UsageProgressBar: View {
    let percentUsed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let gradient = Gradient(stops: [
        .init(color: UsageColor.green, location: 0.0),
        .init(color: UsageColor.orange, location: 0.5),
        .init(color: UsageColor.red, location: 0.8),
        .init(color: UsageColor.red, location: 1.0)
    ])

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(0.08))

                LinearGradient(gradient: Self.gradient, startPoint: .leading, endPoint: .trailing)
                    // Le degrade est dessine sur la largeur totale (0...100%) puis recadre a la
                    // largeur visible, pour ne pas re-comprimer les 3 couleurs dans le remplissage.
                    .frame(width: geo.size.width)
                    .frame(width: geo.size.width * fillRatio, alignment: .leading)
                    .clipped()
                    // Le remplissage glisse vers sa nouvelle valeur au lieu de sauter : l'aiguille
                    // d'un instrument de bord se deplace, elle ne se teleporte pas.
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.35), value: percentUsed)
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .frame(height: 6)
    }

    private var fillRatio: CGFloat {
        CGFloat(min(max(percentUsed, 0), 1))
    }
}
