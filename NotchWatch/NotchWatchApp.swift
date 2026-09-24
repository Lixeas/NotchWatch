import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar-only app: no Dock icon, no Cmd+Tab entry.
        NSApp.setActivationPolicy(.accessory)
        AppFonts.register()
    }
}

@main
struct NotchWatchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var tracker = UsageTracker()
    @Environment(\.openWindow) private var openWindow

    // Color.gray est une teinte fixe (ne suit pas clair/sombre) : Color.primary s'adapte
    // (noir en clair, blanc en sombre), meme pattern que le track de MenuBarProgressLabel.
    private let chromeTint = Color.primary.opacity(0.06)
    private let contentTint = Color.primary.opacity(0.02)

    // MenuBarExtra's `label:` closure is hosted by NSStatusItem.button, which ignores
    // custom Shape fills/colors when the view is passed in directly (confirmed AppKit
    // constraint, not a bug in MenuBarProgressLabel). Workaround: pre-render it to an
    // NSImage via ImageRenderer *outside* the label closure, then display that image.
    // Le rendu lui-meme vit dans UsageTracker.pillImage (recalcule seulement quand la valeur
    // affichee change, pas a chaque evaluation de ce body).

    var body: some Scene {
        MenuBarExtra {
            VStack(spacing: 0) {
                // Section titre : logo + nom a gauche, refresh a droite
                HStack(spacing: 8) {
                    Image(systemName: "cpu")
                        .foregroundColor(.secondary)
                    Text("NotchWatch")
                        .font(.hostGroteskBold(12))
                    Spacer()
                    Button {
                        Task { await tracker.fetchUsage() }
                    } label: {
                        Group {
                            if tracker.isLoading {
                                ProgressView().controlSize(.mini)
                            } else {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.system(size: 15))
                            }
                        }
                        // Fondu seul (pas de mouvement) entre icone et spinner : reste legible
                        // meme reduction de mouvement activee, sert juste a confirmer l'action.
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.15), value: tracker.isLoading)
                    }
                    .buttonStyle(.plain)
                    .help("Rafraichir")
                    .accessibilityLabel("Rafraichir la consommation")
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(chromeTint)

                Divider()

                // Section centrale : credits
                UsageDetailSection(tracker: tracker)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(contentTint)

                Divider()

                // Section bas : reglages a gauche, quitter a droite
                HStack {
                    Button("Reglages...") {
                        // App .accessory (pas d'icone Dock) : ne devient jamais frontmost
                        // automatiquement, sinon la fenetre s'ouvre sans focus (derriere le Terminal en dev).
                        NSApp.activate(ignoringOtherApps: true)
                        openWindow(id: "settings")
                    }
                    Spacer()
                    Button("Quitter") {
                        NSApplication.shared.terminate(nil)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(chromeTint)
            }
            .frame(width: 250)
            .environment(\.font, .hostGrotesk(13))
            .task {
                tracker.startAutoRefresh()
            }
        } label: {
            Image(nsImage: tracker.pillImage)
                .accessibilityLabel(tracker.pillAccessibilityLabel)
        }
        .menuBarExtraStyle(.window)

        Window("Reglages", id: "settings") {
            SettingsView()
                .environmentObject(tracker)
        }
        .windowResizability(.contentSize)
    }
}