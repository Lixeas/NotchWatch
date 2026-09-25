import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @EnvironmentObject private var tracker: UsageTracker
    @ObservedObject private var languageManager = LanguageManager.shared

    @State private var tokenInput: String = ""
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var errorMessage: String?
    @State private var saveTask: Task<Void, Never>?

    private let keychainManager = KeychainManager()

    private static let intervalOptions: [(label: String, seconds: Int)] = [
        ("30 s", 30),
        ("1 min", 60),
        ("5 min", 300),
        ("15 min", 900),
        ("30 min", 1800)
    ]

    var body: some View {
        let lang = languageManager.language

        VStack(alignment: .leading, spacing: 16) {

            // Jeton d'authentification
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.authTokenTitle(lang))
                    .font(.hostGroteskSemiBold(14))

                Text(Strings.authTokenDescription(lang))
                    .font(.hostGrotesk(12))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                SecureField("sk-ant-oat01-...", text: $tokenInput)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: tokenInput) { newValue in
                        // Debounce : evite une ecriture Keychain (SecItemUpdate/Add) a chaque
                        // frappe, et n'enregistre pas les etats intermediaires d'un coller/tape.
                        saveTask?.cancel()
                        saveTask = Task {
                            try? await Task.sleep(nanoseconds: 400_000_000)
                            guard !Task.isCancelled else { return }
                            saveToken(newValue)
                        }
                    }
            }

            Divider()

            // Rafraichissement automatique
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.autoRefreshTitle(lang))
                    .font(.hostGroteskSemiBold(14))

                Picker(Strings.intervalLabel(lang), selection: $tracker.refreshInterval) {
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
                Text(Strings.startupTitle(lang))
                    .font(.hostGroteskSemiBold(14))

                Toggle(Strings.launchAtLoginLabel(lang), isOn: Binding(
                    get: { launchAtLogin },
                    set: { setLaunchAtLogin($0) }
                ))
            }

            Divider()

            // Langue
            VStack(alignment: .leading, spacing: 8) {
                Text(Strings.languageTitle(lang))
                    .font(.hostGroteskSemiBold(14))

                Picker(Strings.languageTitle(lang), selection: $languageManager.language) {
                    ForEach(AppLanguage.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 200)
            }

            if let errorMessage {
                Divider()
                Text(errorMessage)
                    .font(.hostGrotesk(12))
                    .foregroundColor(UsageColor.redText)
            }

            Divider()

            Text(Strings.versionLabel(AppVersion.string, lang))
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
            errorMessage = Strings.tokenErrorPrefix(error.localizedDescription, languageManager.language)
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
            errorMessage = Strings.startupErrorPrefix(error.localizedDescription, languageManager.language)
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
