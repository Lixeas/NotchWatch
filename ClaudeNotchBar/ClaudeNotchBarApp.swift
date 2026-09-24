import SwiftUI

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

    var body: some Scene {
        MenuBarExtra {
            VStack(spacing: 0) {
                // Section titre : logo + nom a gauche, refresh a droite
                HStack(spacing: 8) {
                    Image(systemName: "cpu")
                        .foregroundColor(.secondary)
                    Text("ClaudeNotchBar")
                        .font(.hostGrotesk(12))
                        .fontWeight(.bold)
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
            if tracker.errorMessage != nil {
                MenuBarProgressLabel(percentUsed: 1, valueText: "!", overrideColor: UsageColor.red)
            } else {
                MenuBarProgressLabel(
                    percentUsed: tracker.percentUsed,
                    valueText: String(format: "$%.0f", tracker.used)
                )
            }
        }
        .menuBarExtraStyle(.window)

        Window("Reglages", id: "settings") {
            SettingsView()
                .environmentObject(tracker)
        }
        .windowResizability(.contentSize)
    }
}