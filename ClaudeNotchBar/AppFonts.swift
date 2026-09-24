import SwiftUI
import CoreText

enum AppFonts {
    static let family = "Host Grotesk"

    /// A appeler une fois au lancement : enregistre les .ttf embarques (Resources/Fonts) aupres de CoreText.
    static func register() {
        let names = ["HostGrotesk-Regular", "HostGrotesk-SemiBold", "HostGrotesk-Bold"]
        for name in names {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension Font {
    static func hostGrotesk(_ size: CGFloat) -> Font {
        .custom(AppFonts.family, size: size)
    }
}
