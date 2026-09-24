import SwiftUI

/// Bloc "Consommation" du menu deroulant : extrait de NotchWatchApp pour lire
/// `accessibilityReduceMotion` (uniquement disponible depuis une View, pas depuis la Scene App).
struct UsageDetailSection: View {
    @ObservedObject var tracker: UsageTracker

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let errorMessage = tracker.errorMessage {
                Text(errorMessage)
                    .foregroundColor(UsageColor.redText)
                    .font(.hostGrotesk(12))
                    .transition(.opacity)
            } else if !tracker.extraUsageEnabled {
                Text("Credits supplementaires non actives sur ce compte.")
                    .font(.hostGrotesk(12))
                    .transition(.opacity)
            } else {
                HStack {
                    Text("Consommation :")
                    Spacer()
                    Text(String(format: "$%.2f / $%.2f", tracker.used, tracker.limit))
                        .contentTransition(.numericText())
                }
                .font(.hostGrotesk(13))

                UsageProgressBar(percentUsed: tracker.percentUsed)
            }

            if let fiveHour = tracker.fiveHourUtilization {
                HStack {
                    Text("Fenetre 5h :")
                    Spacer()
                    Text(String(format: "%.0f%%", fiveHour * 100))
                        .contentTransition(.numericText())
                }
                .font(.hostGrotesk(11))
            }

            if let sevenDay = tracker.sevenDayUtilization {
                HStack {
                    Text("Fenetre 7j :")
                    Spacer()
                    Text(String(format: "%.0f%%", sevenDay * 100))
                        .contentTransition(.numericText())
                }
                .font(.hostGrotesk(11))
            }
        }
        // Une seule animation pilote le defilement des chiffres, le glissement de la barre
        // (UsageProgressBar anime son propre remplissage) et le fondu entre etats : un seul
        // geste coherent a la fin de chaque fetch, pas des effets disperses.
        .animation(reduceMotion ? nil : .easeOut(duration: 0.35), value: tracker.used)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.35), value: tracker.errorMessage)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.35), value: tracker.extraUsageEnabled)
    }
}
