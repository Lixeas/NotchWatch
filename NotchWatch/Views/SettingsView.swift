import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject private var tracker: UsageTracker

    @State private var tokenInput: String = ""
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var errorMessage: String?

    private let keychainManager = KeychainManager()

    private static let intervalOptions: [(label: String, seconds: Int)] = [
        ("30 s", 30),
        ("1 min", 60),
        ("5 min", 300),
        ("15 min", 900),
        ("30 min", 1800)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Jeton d'authentification
            VStack(alignment: .leading, spacing: 8) {
                Text("Jeton d'authentification")
                    .font(.hostGroteskSemiBold(14))

                Text("Si le jeton recupere automatiquement (Claude Code) a expire, collez ici un jeton d'acces valide. Videz le champ pour revenir au jeton automatique. Enregistre automatiquement.")
                    .font(.hostGrotesk(12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                SecureField("sk-ant-oat01-...", text: $tokenInput)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: tokenInput) { newValue in
                        saveToken(newValue)
                    }
            }

            Divider()

            // Rafraichissement automatique
            VStack(alignment: .leading, spacing: 8) {
                Text("Rafraichissement automatique")
                    .font(.hostGroteskSemiBold(14))

                Picker("Intervalle :", selection: $tracker.refreshInterval) {
                    ForEach(Self.intervalOptions, id: \.seconds) { option in
                        Text(option.label).tag(option.seconds)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 200)
            }

            Divider()

            // Demarrage
            VStack(alignment: .leading, spacing: 8) {
                Text("Demarrage")
                    .font(.hostGroteskSemiBold(14))

                Toggle("Lancer NotchWatch a l'ouverture de session", isOn: Binding(
                    get: { launchAtLogin },
                    set: { setLaunchAtLogin($0) }
                ))
            }

            if let errorMessage {
                Divider()
                Text(errorMessage)
                    .font(.hostGrotesk(12))
                    .foregroundColor(UsageColor.red)
            }

            Divider()

            Text("NotchWatch \u{2022} version \(AppVersion.string)")
                .font(.hostGrotesk(11))
                .foregroundColor(.secondary)
        }
        .padding(20)
        .frame(width: 380)
        .environment(\.font, .hostGrotesk(13))
        .onAppear {
            tokenInput = keychainManager.getManualToken() ?? ""
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func saveToken(_ token: String) {
        do {
            try keychainManager.saveManualToken(token)
            errorMessage = nil
        } catch {
            errorMessage = "Erreur jeton : \(error.localizedDescription)"
        }
    }

    // ponytail: SMAppService.mainApp enregistre le binaire lui-meme comme item de connexion.
    // Fiable uniquement si l'app tourne depuis un vrai bundle .app signe ; sans build/run macOS
    // ici, non verifie en conditions reelles.
    private func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = enabled
            errorMessage = nil
        } catch {
            errorMessage = "Erreur demarrage auto : \(error.localizedDescription)"
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
