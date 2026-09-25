import SwiftUI
import AppKit

/// Icone de marque du menu deroulant (remplace le SF Symbol "cpu"). Deux SVG pre-dessines
/// clair/sombre chargees depuis Bundle.module -- pas d'asset catalog dans ce package SPM, donc
/// pas de bascule automatique par apparence : on lit `colorScheme` nous-memes.
struct BrandMark: View {
    @Environment(\.colorScheme) private var colorScheme

    private static let size: CGFloat = 16
    private static var cache: [ColorScheme: NSImage] = [:]

    var body: some View {
        Image(nsImage: Self.image(for: colorScheme))
            .resizable()
            .frame(width: Self.size, height: Self.size)
    }

    private static func image(for scheme: ColorScheme) -> NSImage {
        if let cached = cache[scheme] { return cached }

        let name = scheme == .dark ? "notchwatch-corbeau-sombre-modified" : "notchwatch-corbeau-clair-modified"
        guard let url = Bundle.module.url(forResource: name, withExtension: "svg", subdirectory: "Images"),
              let image = NSImage(contentsOf: url) else {
            return NSImage()
        }
        cache[scheme] = image
        return image
    }
}
