import SwiftUI

/// Bloc "Consommation" du menu deroulant : extrait de NotchWatchApp pour lire
/// `accessibilityReduceMotion` (uniquement disponible depuis une View, pas depuis la Scene App).
struct UsageDetailSection: View {
    @ObservedObject var tracker: UsageTracker
    @ObservedObject private var languageManager = LanguageManager.shared

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let lang = languageManager.language

        VStack(alignment: .leading, spacing: 10) {
            if let errorMessage = tracker.errorMessage {
                Text(errorMessage)
                    .foregroundColor(UsageColor.redText)
                    .font(.hostGrotesk(12))
                    .transition(.opacity)
            } else if !tracker.extraUsageEnabled {
                Text(Strings.extraUsageDisabled(lang))
                    .font(.hostGrotesk(12))
                    .transition(.opacity)
            } else {
                HStack {
                    Text(Strings.consumptionLabel(lang))
                    Spacer()
                    Text(String(format: "$%.2f / $%.2f", tracker.used, tracker.limit))
                        .contentTransition(.numericText())
                }
                .font(.hostGrotesk(13))

                UsageProgressBar(percentUsed: tracker.percentUsed)

                HStack {
                    Text(Strings.billingCycleLabel(lang))
                    Spacer()
                    Text(Self.billingCycleRange(for: lang))
                }
                .font(.hostGrotesk(11))
                .foregroundColor(.secondary)
            }

            if let fiveHour = tracker.fiveHourUtilization {
                HStack {
                    Text(Strings.fiveHourWindowLabel(lang))
                    Spacer()
                    Text(String(format: "%.0f%%", fiveHour * 100))
                        .contentTransition(.numericText())
                }
                .font(.hostGrotesk(11))
            }

            if let sevenDay = tracker.sevenDayUtilization {
                HStack {
                    Text(Strings.sevenDayWindowLabel(lang))
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

    /// Approximation mois-calendaire : l'API n'expose aucune date de cycle reelle
    /// (`extra_usage` n'a pas de period_start/period_end). Recalcule a chaque affichage,
    /// pas mis en cache : couvre le changement de mois sans logique de rafraichissement dediee.
    private static func billingCycleRange(for lang: AppLanguage) -> String {
        let calendar = Calendar.current
        let now = Date()
        guard let interval = calendar.dateInterval(of: .month, for: now),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: interval.end) else {
            return ""
        }
        let formatter = DateIntervalFormatter()
        formatter.locale = Locale(identifier: lang == .en ? "en_US" : "fr_FR")
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: interval.start, to: lastDay) ?? ""
    }
}
