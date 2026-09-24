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
struct ClaudeNotchBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var tracker = UsageTracker()
    @Environment(\.openWindow) private var openWindow

    private let chromeTint = Color.gray.opacity(0.09)
    private let contentTint = Color.gray.opacity(0.03)

    // MenuBarExtra's `label:` closure is hosted by NSStatusItem.button, which ignores
    // custom Shape fills/colors when the view is passed in directly (confirmed AppKit
    // constraint, not a bug in MenuBarProgressLabel). Workaround: pre-render it to an
    // NSImage via ImageRenderer *outside* the label closure, then display that image.
    @MainActor
    private func renderPillImage() -> NSImage {
        let pill: MenuBarProgressLabel
        if tracker.errorMessage != nil {
            pill = MenuBarProgressLabel(percentUsed: 1, valueText: "!", overrideColor: UsageColor.red)
        } else {
            pill = MenuBarProgressLabel(
                percentUsed: tracker.percentUsed,
                valueText: String(format: "$%.0f", tracker.used)
            )
        }
        let renderer = ImageRenderer(content: pill)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
        let image = renderer.nsImage ?? NSImage()
        image.isTemplate = false // sinon la barre de menus aplatit l'image en monochrome
        return image
    }

    var body: some Scene {
        let pillImage = renderPillImage()

        MenuBarExtra {
            VStack(spacing: 0) {
                // Section titre : logo + nom a gauche, refresh a droite
                HStack(spacing: 8) {
                    Image(systemName: "cpu")
                        .foregroundColor(.secondary)
                    Text("ClaudeNotchBar")
                        .font(.hostGroteskBold(12))
                    Spacer()
                    Button {
                        Task { await tracker.fetchUsage() }
                    } label: {
                        if tracker.isLoading {
                            ProgressView().controlSize(.mini)
                        } else {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.system(size: 15))
                        }
                    }
                    .buttonStyle(.plain)
                    .help("Rafraichir")
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(chromeTint)

                Divider()

                // Section centrale : credits
                VStack(alignment: .leading, spacing: 10) {
                    if let errorMessage = tracker.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(UsageColor.red)
                            .font(.hostGrotesk(12))
                    } else if !tracker.extraUsageEnabled {
                        Text("Credits supplementaires non actives sur ce compte.")
                            .font(.hostGrotesk(12))
                    } else {
                        HStack {
                            Text("Consommation :")
                            Spacer()
                            Text(String(format: "$%.2f / $%.2f", tracker.used, tracker.limit))
                        }
                        .font(.hostGrotesk(13))

                        ProgressView(value: tracker.percentUsed)
                            .tint(UsageColor.forPercent(tracker.percentUsed))
                    }

                    if let fiveHour = tracker.fiveHourUtilization {
                        HStack {
                            Text("Fenetre 5h :")
                            Spacer()
                            Text(String(format: "%.0f%%", fiveHour * 100))
                        }
                        .font(.hostGrotesk(11))
                    }

                    if let sevenDay = tracker.sevenDayUtilization {
                        HStack {
                            Text("Fenetre 7j :")
                            Spacer()
                            Text(String(format: "%.0f%%", sevenDay * 100))
                        }
                        .font(.hostGrotesk(11))
                    }
                }
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
            Image(nsImage: pillImage)
        }
        .menuBarExtraStyle(.window)

        Window("Reglages", id: "settings") {
            SettingsView()
                .environmentObject(tracker)
        }
        .windowResizability(.contentSize)
    }
}